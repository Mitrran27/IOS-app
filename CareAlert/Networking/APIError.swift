import Foundation

enum APIError: Error, Equatable {
    case invalidURL
    case transport(String)
    case invalidResponse
    case decodingFailed(String)
    case encodingFailed(String)
    case unauthorized
    case server(statusCode: Int, message: String?)
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL was invalid."
        case .transport(let message):
            return message
        case .invalidResponse:
            return "The server returned an unexpected response."
        case .decodingFailed:
            return "Failed to read the server's response."
        case .encodingFailed:
            return "Failed to prepare the request."
        case .unauthorized:
            return "Your session has expired. Please log in again."
        case .server(_, let message):
            return message ?? "The server returned an error."
        }
    }
}
