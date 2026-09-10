import Foundation

@MainActor
final class HistoryViewModel: ObservableObject {
    @Published private(set) var events: [NotificationEvent] = []
    @Published var searchText = ""
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let apiClient: APIClient

    init(apiClient: APIClient = .shared) {
        self.apiClient = apiClient
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

    func loadHistory() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let response: NotificationListResponse = try await apiClient.request("get_history_notifications")
            events = response.data
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to load history. Please try again."
        }
    }
}
