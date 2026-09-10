import Foundation

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

/// Thin async/await wrapper over URLSession. Resolves every path against
/// `Config.baseURL` and auto-attaches `Authorization: Bearer <token>` from
/// the Keychain unless the caller opts out via `requiresAuth`.
final class APIClient {
    static let shared = APIClient()

    private let session: URLSession
    private let baseURL: URL
    private let tokenProvider: () -> String?

    init(
        session: URLSession = .shared,
        baseURL: URL = Config.baseURL,
        tokenProvider: @escaping () -> String? = { KeychainWrapper.get(forKey: SessionManager.tokenKey) }
    ) {
        self.session = session
        self.baseURL = baseURL
        self.tokenProvider = tokenProvider
    }

    /// Request with a JSON-encodable body (POST endpoints), decoding a JSON response.
    func request<Response: Decodable, Body: Encodable>(
        _ path: String,
        method: HTTPMethod = .post,
        body: Body?,
        requiresAuth: Bool = true
    ) async throws -> Response {
        let (data, _) = try await perform(path, method: method, body: body, requiresAuth: requiresAuth)
        return try decode(data)
    }

    /// Request with no body (GET endpoints), decoding a JSON response.
    func request<Response: Decodable>(
        _ path: String,
        method: HTTPMethod = .get,
        requiresAuth: Bool = true
    ) async throws -> Response {
        try await request(path, method: method, body: Optional<NoBody>.none, requiresAuth: requiresAuth)
    }

    /// Request whose response body isn't needed — only the HTTP status is validated.
    @discardableResult
    func requestNoContent<Body: Encodable>(
        _ path: String,
        method: HTTPMethod = .post,
        body: Body?,
        requiresAuth: Bool = true
    ) async throws -> Data {
        let (data, _) = try await perform(path, method: method, body: body, requiresAuth: requiresAuth)
        return data
    }

    /// Request whose response body isn't needed and has no request body (e.g. `/logout`).
    @discardableResult
    func requestNoContent(
        _ path: String,
        method: HTTPMethod = .post,
        requiresAuth: Bool = true
    ) async throws -> Data {
        try await requestNoContent(path, method: method, body: Optional<NoBody>.none, requiresAuth: requiresAuth)
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
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed(error.localizedDescription)
        }
    }
}

private struct NoBody: Encodable {}
