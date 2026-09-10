import SwiftUI

/// Card layout shared by Alarms and History — they differ only in what
/// goes in the trailing area (an Acknowledge button vs. a status badge).
struct EventCardView<Trailing: View>: View {
    let event: NotificationEvent
    let trailing: () -> Trailing

    init(event: NotificationEvent, @ViewBuilder trailing: @escaping () -> Trailing) {
        self.event = event
        self.trailing = trailing
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Circle()
                    .fill(Color(hex: event.color))
                    .frame(width: 10, height: 10)
                Text(event.event_name)
                    .font(.headline)
                Spacer()
                notifiedBadge
            }

            Text(event.hospital_name)
                .font(.subheadline)
            Text("\(event.ward_name) · Bed \(event.bed_name)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(event.occurred_at.formattedEventTimestamp)
                .font(.caption)
                .foregroundStyle(.secondary)

            trailing()
        }
        .padding()
        .background(Color.secondary.opacity(0.12), in: RoundedRectangle(cornerRadius: 12))
    }

    private var notifiedBadge: some View {
        Text(event.notify_sent ? "Notified" : "Not Notified")
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(event.notify_sent ? Color.green.opacity(0.15) : Color.gray.opacity(0.15))
            .foregroundStyle(event.notify_sent ? Color.green : Color.secondary)
            .clipShape(Capsule())
    }
}
