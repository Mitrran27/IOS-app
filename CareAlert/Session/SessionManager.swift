import Foundation

/// Owns the app's authentication session. Backed by the Keychain so the
/// token survives relaunches; publishes `isLoggedIn` so views can react to
/// login/logout without polling.
@MainActor
final class SessionManager: ObservableObject {
    static let tokenKey = "authToken"

    @Published private(set) var isLoggedIn: Bool

    init() {
        isLoggedIn = KeychainWrapper.get(forKey: Self.tokenKey) != nil
    }

    func saveSession(token: String) {
        KeychainWrapper.set(token, forKey: Self.tokenKey)
        isLoggedIn = true
    }

    func getToken() -> String? {
        KeychainWrapper.get(forKey: Self.tokenKey)
    }

    func clearSession() {
        KeychainWrapper.delete(forKey: Self.tokenKey)
        isLoggedIn = false
    }
}
