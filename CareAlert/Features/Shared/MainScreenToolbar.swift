import SwiftUI

/// Bell (notification inbox) + profile icons shared by Alarms and History.
struct MainScreenToolbarModifier: ViewModifier {
    @Binding var showNotifications: Bool
    @Binding var showProfile: Bool
    let unreadCount: Int

    func body(content: Content) -> some View {
        content.toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showNotifications = true
                } label: {
                    ZStack(alignment: .topTrailing) {
                        Image(systemName: "bell")
                        if unreadCount > 0 {
                            Text("\(unreadCount)")
                                .font(.caption2)
                                .padding(4)
                                .background(Color.red)
                                .foregroundStyle(.white)
                                .clipShape(Circle())
                                .offset(x: 10, y: -8)
                        }
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showProfile = true
                } label: {
                    Image(systemName: "person.crop.circle")
                }
            }
        }
    }
}

extension View {
    func mainScreenToolbar(showNotifications: Binding<Bool>, showProfile: Binding<Bool>, unreadCount: Int) -> some View {
        modifier(MainScreenToolbarModifier(showNotifications: showNotifications, showProfile: showProfile, unreadCount: unreadCount))
    }
}
