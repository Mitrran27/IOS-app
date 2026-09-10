import SwiftUI

@main
struct CareAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @StateObject private var sessionManager = SessionManager()
    @StateObject private var inboxStore = NotificationInboxStore()
    @StateObject private var pushRouter = PushNotificationRouter.shared
    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(inboxStore)
                .environmentObject(pushRouter)
                .onAppear {
                    pushRouter.configure(sessionManager: sessionManager, inboxStore: inboxStore)
                    APIClient.shared.configureSessionManager(sessionManager)
                }
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .background {
                BackgroundRefreshScheduler.scheduleNextRefresh()
            }
        }
    }
}
