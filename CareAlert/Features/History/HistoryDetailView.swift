import SwiftUI

/// No separate detail API — displays the already-fetched record passed
/// through navigation from History.
struct HistoryDetailView: View {
    let event: NotificationEvent

    var body: some View {
        Form {
            Section("Event") {
                LabeledContent("Event", value: event.event_name)
                LabeledContent("Hospital", value: event.hospital_name)
                LabeledContent("Ward", value: event.ward_name)
                LabeledContent("Bed", value: event.bed_name)
            }

            Section("Timing") {
                LabeledContent("Occurred", value: event.occurred_at.formattedEventTimestamp)
                LabeledContent("Ended", value: event.ended_at?.formattedEventTimestamp ?? "-")
            }

            Section("Status") {
                LabeledContent("Status", value: statusLabel)
                LabeledContent("Ack By", value: event.ack_by ?? "-")
                LabeledContent("Ack At", value: event.ack_at?.formattedEventTimestamp ?? "-")
            }
        }
        .navigationTitle(event.event_name)
    }

    private var statusLabel: String {
        switch event.event_status {
        case 1: return "Acknowledged"
        case 2: return "Closed"
        default: return "Status \(event.event_status)"
        }
    }
}

#Preview {
    NavigationStack {
        HistoryDetailView(event: NotificationEvent(
            id: "1", occurred_at: "2026-08-18T09:10:14.000Z", ended_at: "2026-08-18T09:10:51.000Z",
            event_status: 2, event_type: 2, ack_by: nil, ack_at: nil, notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "123A", bed_code: "123A", event_uuid: nil, event_name: "123A-HK",
            color: "#2563EB", priority: 6, master_event_type: 2, nurse_list: nil
        ))
    }
}
