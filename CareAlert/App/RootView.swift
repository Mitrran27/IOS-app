import SwiftUI

/// Always shows Login for now. Session-aware routing (`/validate_token` on
/// cold launch, deciding between this and AlarmsView) is a Step 11 concern.
struct RootView: View {
    var body: some View {
        LoginView()
    }
}

#Preview {
    RootView()
}
