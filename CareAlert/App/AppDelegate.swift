import UIKit
import FirebaseCore
import FirebaseMessaging
import UserNotifications

/// Bridges Firebase/APNs setup into the SwiftUI app lifecycle via
/// `@UIApplicationDelegateAdaptor` — Firebase needs this hook, not a full
/// UIKit rewrite.
final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        Messaging.messaging().delegate = PushNotificationRouter.shared
        UNUserNotificationCenter.current().delegate = PushNotificationRouter.shared
        application.registerForRemoteNotifications()

        BackgroundRefreshScheduler.register()
        BackgroundRefreshScheduler.scheduleNextRefresh()

        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        // APNs registration failing (no network, simulator without push entitlement,
        // etc.) is non-fatal — Firebase will retry, and foreground polling covers
        // the gap in the meantime.
    }
}
