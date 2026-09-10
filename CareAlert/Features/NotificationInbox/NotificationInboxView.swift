import SwiftUI

/// Local-only "Latest Alerts" panel — there is no backend API for this
/// inbox (see CLAUDE.md Step 10 notes); it reflects pushes recorded on-device
/// by `PushNotificationRouter`.
struct NotificationInboxView: View {
    @EnvironmentObject private var inboxStore: NotificationInboxStore
    @Environment(\.dismiss) private var dismiss
    @State private var showAllAlerts = false

    var body: some View {
        NavigationStack {
            List {
                if inboxStore.alerts.isEmpty {
                    Text("No alerts yet")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(previewAlerts) { alert in
                        AlertRow(alert: alert)
                    }
                }
            }
            .navigationTitle("Latest Alerts")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button("View All Alerts") {
                            showAllAlerts = true
                        }
                        Button("Clear All", role: .destructive) {
                            inboxStore.clearAll()
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .navigationDestination(isPresented: $showAllAlerts) {
                List(inboxStore.alerts) { alert in
                    AlertRow(alert: alert)
                }
                .navigationTitle("All Alerts (\(inboxStore.alerts.count))")
            }
            // Mark read on close, not on open, so "New" badges stay visible while browsing.
            .onDisappear {
                inboxStore.markAllRead()
            }
        }
    }

    private var previewAlerts: [InboxAlert] {
        Array(inboxStore.alerts.prefix(5))
    }
}

private struct AlertRow: View {
    let alert: InboxAlert

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(alert.title)
                    .font(.headline)
                if !alert.isRead {
                    Text("New")
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                }
                Spacer()
            }
            Text(alert.message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(alert.receivedAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

#Preview {
    NotificationInboxView()
        .environmentObject(NotificationInboxStore())
}
