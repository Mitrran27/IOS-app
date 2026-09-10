import BackgroundTasks
import UserNotifications

/// Secondary fallback poll for missed pushes, within whatever execution
/// window iOS grants a background app refresh task. Diffs the pending list
/// against previously-seen event IDs and fires a local notification for
/// anything new, so a silently-dropped push still surfaces to the nurse.
enum BackgroundRefreshScheduler {
    static let taskIdentifier = "com.careapp.carealert.refresh"
    private static let seenEventIDsKey = "backgroundRefresh.seenEventIDs"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: taskIdentifier, using: nil) { task in
            guard let appRefreshTask = task as? BGAppRefreshTask else {
                task.setTaskCompleted(success: false)
                return
            }
            handle(task: appRefreshTask)
        }
    }

    static func scheduleNextRefresh() {
        let request = BGAppRefreshTaskRequest(identifier: taskIdentifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
        try? BGTaskScheduler.shared.submit(request)
    }

    private static func handle(task: BGAppRefreshTask) {
        // Always resubmit first — BGTaskScheduler tasks are one-shot.
        scheduleNextRefresh()

        let refreshTask = Task {
            await pollForMissedAlarms()
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = {
            refreshTask.cancel()
        }
    }

    private static func pollForMissedAlarms() async {
        guard KeychainWrapper.get(forKey: SessionManager.tokenKey) != nil else { return }

        guard let response: NotificationListResponse = try? await APIClient.shared.request("get_pending_notifications") else {
            return
        }

        let defaults = UserDefaults.standard
        var seenIDs = Set(defaults.stringArray(forKey: seenEventIDsKey) ?? [])
        let newEvents = response.data.filter { !seenIDs.contains($0.id) }

        for event in newEvents {
            await notifyLocally(for: event)
            seenIDs.insert(event.id)
        }

        defaults.set(Array(seenIDs), forKey: seenEventIDsKey)
    }

    private static func notifyLocally(for event: NotificationEvent) async {
        let content = UNMutableNotificationContent()
        content.title = event.event_name
        content.body = "\(event.hospital_name) · \(event.ward_name) · Bed \(event.bed_name)"
        content.sound = .default

        let request = UNNotificationRequest(identifier: event.id, content: content, trigger: nil)
        try? await UNUserNotificationCenter.current().add(request)
    }
}
