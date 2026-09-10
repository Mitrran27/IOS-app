import Foundation

/// A single locally-stored push notification. There is no backend API for
/// this inbox — it's intentionally local-only (see CLAUDE.md Step 10 notes).
struct InboxAlert: Identifiable, Codable, Equatable {
    let id: UUID
    let title: String
    let message: String
    let receivedAt: Date
    var isRead: Bool
}

@MainActor
final class NotificationInboxStore: ObservableObject {
    @Published private(set) var alerts: [InboxAlert] = []

    private let storageKey = "notificationInbox"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        alerts = Self.load(from: defaults, key: storageKey)
    }

    var unreadCount: Int {
        alerts.filter { !$0.isRead }.count
    }

    func record(title: String, message: String) {
        let alert = InboxAlert(id: UUID(), title: title, message: message, receivedAt: Date(), isRead: false)
        alerts.insert(alert, at: 0)
        persist()
    }

    func markAllRead() {
        for index in alerts.indices {
            alerts[index].isRead = true
        }
        persist()
    }

    func clearAll() {
        alerts.removeAll()
        persist()
    }

    private func persist() {
        guard let data = try? JSONEncoder().encode(alerts) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private static func load(from defaults: UserDefaults, key: String) -> [InboxAlert] {
        guard let data = defaults.data(forKey: key),
              let alerts = try? JSONDecoder().decode([InboxAlert].self, from: data) else {
            return []
        }
        return alerts
    }
}
