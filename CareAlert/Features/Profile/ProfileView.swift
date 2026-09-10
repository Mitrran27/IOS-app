import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @State private var isLoggingOut = false

    private let apiClient: APIClient = .shared

    var body: some View {
        NavigationStack {
            Form {
                if let user = sessionManager.currentUser {
                    Section {
                        LabeledContent("Name", value: user.full_name)
                        LabeledContent("Phone", value: user.phone)
                    }
                }

                Section {
                    Button(role: .destructive) {
                        Task { await logout() }
                    } label: {
                        if isLoggingOut {
                            ProgressView()
                        } else {
                            Text("Logout")
                        }
                    }
                    .disabled(isLoggingOut)
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private func logout() async {
        isLoggingOut = true
        defer { isLoggingOut = false }

        #if DEBUG
        if DebugMockData.isActive {
            DebugMockData.isActive = false
            sessionManager.clearSession()
            return
        }
        #endif

        // The backend accepts both 200 and 401 as logout completion, and a
        // network failure shouldn't strand the user in a broken session —
        // the local session is cleared either way.
        try? await apiClient.requestNoContent("logout", allowsSessionRenewal: false)
        sessionManager.clearSession()
    }
}

#Preview {
    ProfileView()
        .environmentObject(SessionManager())
}
