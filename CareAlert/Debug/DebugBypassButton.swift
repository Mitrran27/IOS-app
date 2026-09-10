#if DEBUG
import SwiftUI

/// DEBUG-only "skip login" button embedded in LoginView. Injects a fake
/// session so `RootView` swaps straight to the logged-in tab shell, with
/// Alarms/History serving `DebugMockData` instead of hitting the real API.
///
/// Compiled out entirely in Release: `SWIFT_ACTIVE_COMPILATION_CONDITIONS`
/// only includes `DEBUG` for the Debug config in project.yml, and the
/// archive scheme is pinned to Release — so this can't reach TestFlight or
/// the App Store even by accident.
struct DebugBypassButton: View {
    @EnvironmentObject private var sessionManager: SessionManager

    var body: some View {
        Button("Skip to Alarms (Debug)") {
            DebugMockData.isActive = true
            sessionManager.saveSession(token: DebugMockData.token, user: DebugMockData.user)
        }
        .font(.footnote)
        .foregroundStyle(.orange)
    }
}
#endif
