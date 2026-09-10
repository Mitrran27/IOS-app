import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Thin async/await wrapper over URLSession. Resolves every path against
/// `Config.baseURL` and auto-attaches `Authorization: Bearer <token>` from
/// the Keychain unless the caller opts out via `requiresAuth`.
///
/// On a 401, it transparently tries `/renew_token` once and retries the
/// original request; if renewal also fails, it clears the session so
/// `RootView` falls back to Login. Pass `allowsSessionRenewal: false` for
/// `/renew_token` itself and `/logout` to avoid recursion/pointless retries.
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let tokenProvider: () -> String?
    private weak var sessionManager: SessionManager?

    init(
        session: URLSession = .shared,
        baseURL: URL = Config.baseURL,
        tokenProvider: @escaping () -> String? = { KeychainWrapper.get(forKey: SessionManager.tokenKey) }
    ) {
        self.session = session
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
    }

    func configureSessionManager(_ sessionManager: SessionManager) {
        self.sessionManager = sessionManager
    }

    /// Request with a JSON-encodable body (POST endpoints), decoding a JSON response.
    func request<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: HTTPMethod = .post,
        body: Body?,
        requiresAuth: Bool = true,
        allowsSessionRenewal: Bool = true
    ) async throws -> Response {
        let (data, _) = try await performWithRenewal(
            path, method: method, body: body, requiresAuth: requiresAuth, allowsSessionRenewal: allowsSessionRenewal
        )
        return try decode(data)
    }

    /// Request with no body (GET endpoints), decoding a JSON response. Retries
    /// transient transport failures with backoff — safe here since GETs have
    /// no side effects to duplicate.
    func request<Response: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        requiresAuth: Bool = true,
        allowsSessionRenewal: Bool = true
    ) async throws -> Response {
        try await withTransportRetry {
            try await self.request(
                path, method: method, body: Optional<NoBody>.none,
                requiresAuth: requiresAuth, allowsSessionRenewal: allowsSessionRenewal
            )
        }
    }

    /// Request whose response body isn't needed — only the HTTP status is validated.
    @discardableResult
    func requestNoContent<Body: Encodable>(
        _ path: String,
        method: HTTPMethod = .post,
        body: Body?,
        requiresAuth: Bool = true,
        allowsSessionRenewal: Bool = true
    ) async throws -> Data {
        let (data, _) = try await performWithRenewal(
            path, method: method, body: body, requiresAuth: requiresAuth, allowsSessionRenewal: allowsSessionRenewal
        )
        return data
    }

    /// Request whose response body isn't needed and has no request body (e.g. `/logout`).
    @discardableResult
    func requestNoContent(
        _ path: String,
        method: HTTPMethod = .post,
        requiresAuth: Bool = true,
        allowsSessionRenewal: Bool = true
    ) async throws -> Data {
        try await requestNoContent(
            path, method: method, body: Optional<NoBody>.none,
            requiresAuth: requiresAuth, allowsSessionRenewal: allowsSessionRenewal
        )
    }

    private func performWithRenewal<Body: Encodable>(
        _ path: String,
        method: HTTPMethod,
        body: Body?,
        requiresAuth: Bool,
        allowsSessionRenewal: Bool
    ) async throws -> (Data, HTTPURLResponse) {
        do {
            return try await perform(path, method: method, body: body, requiresAuth: requiresAuth)
        } catch APIError.unauthorized {
            guard allowsSessionRenewal, requiresAuth, let sessionManager else {
                throw APIError.unauthorized
            }

            if let newToken = await renewSessionToken() {
                await MainActor.run { sessionManager.updateToken(newToken) }
                return try await perform(path, method: method, body: body, requiresAuth: requiresAuth)
            } else {
                await MainActor.run { sessionManager.clearSession() }
                throw APIError.unauthorized
            }
        }
    }

    private func renewSessionToken() async -> String? {
        do {
            let response: RenewTokenResponse = try await request(
                "renew_token", method: .post, requiresAuth: true, allowsSessionRenewal: false
            )
            return response.token
        } catch {
            return nil
        }
    }

    private func withTransportRetry<T>(
        maxAttempts: Int = 3,
        _ operation: () async throws -> T
    ) async throws -> T {
        var lastError: Error = APIError.transport("Unknown error")
        for attempt in 0..<maxAttempts {
            do {
                return try await operation()
            } catch APIError.transport(let message) {
                lastError = APIError.transport(message)
                if attempt < maxAttempts - 1 {
                    let delaySeconds = pow(2.0, Double(attempt))
                    try? await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                }
            }
        }
        throw lastError
    }

    private func perform<Body: Encodable>(
        _ path: String,
        method: HTTPMethod,
        body: Body?,
        requiresAuth: Bool
    ) async throws -> (Data, HTTPURLResponse) {
        let url = baseURL.appendingPathComponent(path)

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.rawValue
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        if requiresAuth, let token = tokenProvider() {
            urlRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        if let body {
            do {
                urlRequest.httpBody = try JSONEncoder().encode(body)
            } catch {
                throw APIError.encodingFailed(error.localizedDescription)
            }
        }

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: urlRequest)
        } catch {
            throw APIError.transport(error.localizedDescription)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }

        guard (200..<300).contains(httpResponse.statusCode) else {
            if httpResponse.statusCode == 401 {
                throw APIError.unauthorized
            }
            throw APIError.server(statusCode: httpResponse.statusCode, message: String(data: data, encoding: .utf8))
        }

        return (data, httpResponse)
    }

    private func decode<Response: Decodable>(_ data: Data) throws -> Response {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom(Self.decodeISO8601)
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }

    // Backend timestamps (e.g. "2026-11-16T01:29:05.000Z") include fractional
    // seconds, which the default `.iso8601` strategy's formatter can't parse.
    private static func decodeISO8601(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        if let date = isoFormatterWithFractionalSeconds.date(from: string) {
            return date
        }
        if let date = isoFormatter.date(from: string) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid ISO8601 date: \(string)")
    }

    private static let isoFormatterWithFractionalSeconds: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()

    private static let isoFormatter = ISO8601DateFormatter()
}

private struct NoBody: Encodable {}

struct RenewTokenResponse: Decodable {
    let token: String
}
