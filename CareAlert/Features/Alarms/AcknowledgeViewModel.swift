import Foundation

@MainActor
final class AcknowledgeViewModel: ObservableObject {
    let event: NotificationEvent

    @Published var selectedNurseID: String?
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didAcknowledge = false

    private let apiClient: APIClient

    init(event: NotificationEvent, apiClient: APIClient = .shared) {
        self.event = event
        self.apiClient = apiClient
    }

    var nurses: [NurseListItem] {
        event.nurse_list ?? []
    }

    var canSubmit: Bool {
        !nurses.isEmpty && selectedNurseID != nil && !isSubmitting
    }

    func acknowledge() async {
        guard let selectedNurseID, !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            try await apiClient.requestNoContent(
                "acknowledge",
                body: AcknowledgeRequest(event_log_id: event.id, nurse_uuid: selectedNurseID)
            )
            didAcknowledge = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to acknowledge. Please try again."
        }
    }
}
