import Foundation

@MainActor
final class AlarmsViewModel: ObservableObject {
    @Published private(set) var events: [NotificationEvent] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedEventForAcknowledge: NotificationEvent?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
    }

    /// Top 4 event names by count, descending — shown above the search box.
    var topEventCounts: [(name: String, count: Int)] {
        let counts = Dictionary(grouping: events, by: \.event_name).mapValues(\.count)
        return counts
            .map { (name: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(4)
            .map { $0 }
    }

    var filteredEvents: [NotificationEvent] {
        let query = searchText.trimmingCharacters(in: .whitespaces).lowercased()
        guard !query.isEmpty else { return events }
        return events.filter {
            $0.hospital_name.lowercased().contains(query) ||
            $0.ward_name.lowercased().contains(query) ||
            $0.bed_name.lowercased().contains(query) ||
            $0.event_name.lowercased().contains(query)
        }
    }

    func loadPendingAlarms() async {
        #if DEBUG
        if DebugMockData.isActive {
            events = DebugMockData.pendingEvents
            return
        }
        #endif

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: NotificationListResponse = try await apiClient.request("get_pending_notifications")
            events = response.data
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load alarms. Please try again."
        }
    }
}
