import SwiftUI

enum MainTab: Hashable {
    case alarms
    case history
}

/// The logged-in app's tab shell. `RootView` swaps into this once
/// `SessionManager.isLoggedIn` is true, and drives `selectedTab` so a tapped
/// push notification can jump straight to Alarms regardless of which tab
/// was showing.
struct MainTabView: View {
    @Binding var selectedTab: MainTab

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                AlarmsView()
            }
            .tabItem { Label("Alarms", systemImage: "bell.fill") }
            .tag(MainTab.alarms)

            NavigationStack {
                HistoryView()
            }
            .tabItem { Label("History", systemImage: "clock.arrow.circlepath") }
            .tag(MainTab.history)
        }
    }
}
