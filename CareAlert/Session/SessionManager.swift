import Foundation

/// Owns the app's authentication session. Backed by the Keychain so the
/// token and user survive relaunches; publishes `isLoggedIn` so views can
/// react to login/logout without polling.
@MainActor
final class SessionManager: ObservableObject {
    static let tokenKey = "authToken"
    private static let userKey = "currentUser"

    @Published private(set) var isLoggedIn: Bool
    @Published private(set) var currentUser: User?

    init() {
        isLoggedIn = KeychainWrapper.get(forKey: Self.tokenKey) != nil
        currentUser = Self.loadUser()
    }

    func saveSession(token: String, user: User) {
        KeychainWrapper.set(token, forKey: Self.tokenKey)
        if let data = try? JSONEncoder().encode(user), let json = String(data: data, encoding: .utf8) {
            KeychainWrapper.set(json, forKey: Self.userKey)
        }
        currentUser = user
        isLoggedIn = true
    }

    func getToken() -> String? {
        KeychainWrapper.get(forKey: Self.tokenKey)
    }

    /// Replaces just the token after a `/renew_token` refresh — the user and
    /// login state are unaffected.
    func updateToken(_ token: String) {
        KeychainWrapper.set(token, forKey: Self.tokenKey)
    }

    func clearSession() {
        KeychainWrapper.delete(forKey: Self.tokenKey)
        KeychainWrapper.delete(forKey: Self.userKey)
        currentUser = nil
        isLoggedIn = false
    }

    private static func loadUser() -> User? {
        guard let json = KeychainWrapper.get(forKey: userKey), let data = json.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(User.self, from: data)
    }
}
