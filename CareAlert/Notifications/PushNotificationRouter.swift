import Foundation
import FirebaseMessaging
import UserNotifications

/// Singleton because it's the delegate target for both `Messaging` and
/// `UNUserNotificationCenter`, which are wired up once at launch in
/// `AppDelegate` — before SwiftUI's view hierarchy necessarily exists.
/// Holds references to the app's single `SessionManager`/`NotificationInboxStore`
/// instances so these delegate callbacks can still act on shared app state.
final class PushNotificationRouter: NSObject, ObservableObject {
    static let shared = PushNotificationRouter()

    /// Flips to true when a push is tapped — foreground, background, or a
    /// cold/terminated launch. `RootView` observes this to switch to the
    /// Alarms tab regardless of app state.
    @Published var didTapAlarmNotification = false

    private var sessionManager: SessionManager?
    private var inboxStore: NotificationInboxStore?
    private let apiClient: APIClient = .shared

    private override init() {
        super.init()
    }

    func configure(sessionManager: SessionManager, inboxStore: NotificationInboxStore) {
        self.sessionManager = sessionManager
        self.inboxStore = inboxStore
    }
}

extension PushNotificationRouter: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken else { return }
        Task { @MainActor in
            guard let sessionManager, sessionManager.isLoggedIn else { return }
            try? await apiClient.requestNoContent(
                "update_mobile_token",
                body: UpdateMobileTokenRequest(mobile_token: fcmToken)
            )
        }
    }
}

extension PushNotificationRouter: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        recordAlert(from: notification.request.content)
        completionHandler([.banner, .list, .sound])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        recordAlert(from: response.notification.request.content)
        DispatchQueue.main.async {
            self.didTapAlarmNotification = true
        }
        completionHandler()
    }

    private func recordAlert(from content: UNNotificationContent) {
        Task { @MainActor in
            inboxStore?.record(
                title: content.title.isEmpty ? "New alert" : content.title,
                message: content.body
            )
        }
    }
}
