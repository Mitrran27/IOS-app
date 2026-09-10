import SwiftUI

struct AcknowledgeView: View {
    @StateObject private var viewModel: AcknowledgeViewModel
    @Environment(\.dismiss) private var dismiss
    let onAcknowledged: () -> Void

    init(event: NotificationEvent, onAcknowledged: @escaping () -> Void) {
        _viewModel = StateObject(wrappedValue: AcknowledgeViewModel(event: event))
        self.onAcknowledged = onAcknowledged
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Event") {
                    LabeledContent("Event", value: viewModel.event.event_name)
                    LabeledContent("Hospital", value: viewModel.event.hospital_name)
                    LabeledContent("Ward", value: viewModel.event.ward_name)
                    LabeledContent("Bed", value: viewModel.event.bed_name)
                }

                Section("Assigned To") {
                    if viewModel.nurses.isEmpty {
                        Text("No nurse available for this event")
                            .foregroundStyle(.secondary)
                    } else {
                        Picker("Nurse", selection: $viewModel.selectedNurseID) {
                            Text("Select a nurse").tag(String?.none)
                            ForEach(viewModel.nurses) { nurse in
                                Text(nurse.name).tag(String?.some(nurse.user_id))
                            }
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }
            }
            .navigationTitle("Acknowledge Alarm")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        Task { await viewModel.acknowledge() }
                    } label: {
                        if viewModel.isSubmitting {
                            ProgressView()
                        } else {
                            Text("Submit")
                        }
                    }
                    .disabled(!viewModel.canSubmit)
                }
            }
            .onChange(of: viewModel.didAcknowledge) { didAcknowledge in
                guard didAcknowledge else { return }
                onAcknowledged()
                dismiss()
            }
        }
    }
}

#Preview {
    AcknowledgeView(
        event: NotificationEvent(
            id: "1", occurred_at: "2026-08-19T10:15:00.000Z", ended_at: nil,
            event_status: 0, event_type: 2, ack_by: nil, ack_at: nil, notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "120A", bed_code: "120A", event_uuid: nil, event_name: "120A-WTR",
            color: "#2563EB", priority: 6, master_event_type: 2,
            nurse_list: [NurseListItem(name: "Mani Nurse", email: nil, user_id: "u1", shift_time: "08:00-16:00", phone_number: nil)]
        )
    ) {}
}
