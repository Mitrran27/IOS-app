import SwiftUI

struct AlarmsView: View {
    @StateObject private var viewModel = AlarmsViewModel()
    @EnvironmentObject private var inboxStore: NotificationInboxStore
    @Environment(\.scenePhase) private var scenePhase
    @State private var showNotifications = false
    @State private var showProfile = false

    var body: some View {
        VStack(spacing: 0) {
            if !viewModel.topEventCounts.isEmpty {
                topEventCountsRow
            }
            content
        }
        .searchable(text: $viewModel.searchText, prompt: "Search hospital, ward, bed, event")
        .navigationTitle("Alarms")
        .mainScreenToolbar(showNotifications: $showNotifications, showProfile: $showProfile, unreadCount: inboxStore.unreadCount)
        .task { await viewModel.loadPendingAlarms() }
        .onChange(of: scenePhase) { newPhase in
            // Push is the fast path, not the only path — always refresh on foreground.
            if newPhase == .active {
                Task { await viewModel.loadPendingAlarms() }
            }
        }
        .sheet(item: $viewModel.selectedEventForAcknowledge) { event in
            AcknowledgeView(event: event) {
                Task { await viewModel.loadPendingAlarms() }
            }
        }
        .sheet(isPresented: $showNotifications) {
            NotificationInboxView()
        }
        .sheet(isPresented: $showProfile) {
            ProfileView()
        }
    }

    private var topEventCountsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(viewModel.topEventCounts, id: \.name) { item in
                    VStack(spacing: 4) {
                        Text("\(item.count)")
                            .font(.title2.bold())
                        Text(item.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .frame(minWidth: 72)
                    .padding()
                    .background(.background.secondary, in: RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 8)
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.events.isEmpty {
            Spacer()
            ProgressView()
            Spacer()
        } else if let errorMessage = viewModel.errorMessage, viewModel.events.isEmpty {
            Spacer()
            Text(errorMessage)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
        } else if viewModel.filteredEvents.isEmpty {
            Spacer()
            Text("No pending alarms")
                .foregroundStyle(.secondary)
            Spacer()
        } else {
            List(viewModel.filteredEvents) { event in
                EventCardView(event: event) {
                    Button("Acknowledge") {
                        viewModel.selectedEventForAcknowledge = event
                    }
                    .buttonStyle(.bordered)
                }
                .listRowSeparator(.hidden)
                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
            }
            .listStyle(.plain)
            .refreshable { await viewModel.loadPendingAlarms() }
        }
    }
}

#Preview {
    NavigationStack { AlarmsView() }
        .environmentObject(NotificationInboxStore())
        .environmentObject(SessionManager())
}
