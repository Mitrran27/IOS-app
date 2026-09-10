import SwiftUI

/// Top-level session switch: logged out shows Login, logged in shows the
/// tab shell. A tapped push notification (foreground, background, or a
/// cold/terminated launch) flips `pushRouter.didTapAlarmNotification`, which
/// jumps the tab shell to Alarms regardless of app state.
///
/// On cold launch with a stored token, validates it via `/validate_token`
/// before committing to the logged-in state — `APIClient` already retries
/// once via `/renew_token` on a 401, so reaching the catch block here means
/// the session is genuinely unsalvageable.
struct RootView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var pushRouter: PushNotificationRouter
    @State private var selectedTab: MainTab = .alarms
    @State private var isValidatingSession = false

    var body: some View {
        Group {
            if isValidatingSession {
                ProgressView()
            } else if sessionManager.isLoggedIn {
                MainTabView(selectedTab: $selectedTab)
            } else {
                LoginView()
            }
        }
        .task {
            await validateSessionIfNeeded()
        }
        .onChange(of: pushRouter.didTapAlarmNotification) { didTap in
            guard didTap else { return }
            selectedTab = .alarms
            pushRouter.didTapAlarmNotification = false
        }
    }

    private func validateSessionIfNeeded() async {
        guard sessionManager.isLoggedIn else { return }
        isValidatingSession = true
        defer { isValidatingSession = false }

        do {
            try await APIClient.shared.requestNoContent("validate_token", method: .get)
        } catch {
            sessionManager.clearSession()
        }
    }
}

#Preview {
    RootView()
        .environmentObject(SessionManager())
        .environmentObject(PushNotificationRouter.shared)
}
