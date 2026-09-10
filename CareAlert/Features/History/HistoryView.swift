import SwiftUI

struct HistoryView: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject private var inboxStore: NotificationInboxStore
    @State private var showNotifications = false
    @State private var showProfile = false

    var body: some View {
        content
            .searchable(text: $viewModel.searchText, prompt: "Search hospital, ward, bed, event")
            .navigationTitle("History")
            .mainScreenToolbar(showNotifications: $showNotifications, showProfile: $showProfile, unreadCount: inboxStore.unreadCount)
            .task { await viewModel.loadHistory() }
            .navigationDestination(for: NotificationEvent.self) { event in
                HistoryDetailView(event: event)
            }
            .sheet(isPresented: $showNotifications) {
                NotificationInboxView()
            }
            .sheet(isPresented: $showProfile) {
                ProfileView()
            }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            ProgressView()
        } else if let errorMessage = viewModel.errorMessage, viewModel.events.isEmpty {
            Text(errorMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
        } else if viewModel.filteredEvents.isEmpty {
            Text("No history yet")
                .foregroundStyle(.secondary)
        } else {
            List(viewModel.filteredEvents) { event in
                NavigationLink(value: event) {
                    EventCardView(event: event) {
                        statusBadge(for: event.event_status)
                    }
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .listStyle(.plain)
            .refreshable { await viewModel.loadHistory() }
        }
    }

    private func statusBadge(for status: Int) -> some View {
        let label: String
        switch status {
        case 1: label = "Acknowledged"
        case 2: label = "Closed"
        default: label = "Status \(status)"
        }
        return Text(label)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.gray.opacity(0.15))
            .clipShape(Capsule())
    }
}

#Preview {
    NavigationStack { HistoryView() }
        .environmentObject(NotificationInboxStore())
        .environmentObject(SessionManager())
}
