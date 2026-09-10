#if DEBUG
import Foundation

/// Fake session + data for reviewing the UI flow (Alarms → Acknowledge →
/// History → History Detail → Profile) without a real backend, OTP, or
/// Firebase. Entry point is `DebugBypassButton` on LoginView.
///
/// To remove this feature entirely: delete this file, DebugBypassButton.swift,
/// and the three `#if DEBUG ... #endif` blocks that reference `DebugMockData`
/// in AlarmsViewModel.swift, HistoryViewModel.swift, and ProfileView.swift
/// (`grep -rn DebugMockData CareAlert` finds all of them).
enum DebugMockData {
    /// Flipped true by DebugBypassButton right before injecting the fake
    /// session; AlarmsViewModel/HistoryViewModel check this to serve mock
    /// data instead of calling the real API. Reset on logout.
    static var isActive = false

    static let token = "debug-bypass-fake-token"

    static let user = User(
        id: "debug-user-id",
        email: "debug.nurse@example.com",
        full_name: "Debug Nurse",
        phone: "60000000000",
        hospital_uuid: "debug-hospital-uuid",
        ward_uuid: "debug-ward-uuid",
        notify_apps: true,
        shift_time: "08:00-16:00",
        push_notify_ezycall: true,
        push_notify_advance: true,
        flag_whatsapp_registration: 1,
        push_notify_asset: true
    )

    // Covers varied event_type/color/priority, and one empty nurse_list so
    // the Acknowledge modal's disabled-submit state is reachable.
    static let pendingEvents: [NotificationEvent] = [
        NotificationEvent(
            id: "debug-pending-1", occurred_at: "2026-09-10T08:15:00.000Z", ended_at: nil,
            event_status: 0, event_type: 2, ack_by: nil, ack_at: nil, notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "120A", bed_code: "120A", event_uuid: "debug-uuid-1", event_name: "120A-WTR",
            color: "#2563EB", priority: 6, master_event_type: 2,
            nurse_list: [
                NurseListItem(name: "Mani Nurse", email: "mani@example.com", user_id: "nurse-1", shift_time: "08:00-16:00", phone_number: "60111111111")
            ]
        ),
        NotificationEvent(
            id: "debug-pending-2", occurred_at: "2026-09-10T08:20:00.000Z", ended_at: nil,
            event_status: 0, event_type: 1, ack_by: nil, ack_at: nil, notify_sent: false,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 2",
            bed_name: "204B", bed_code: "204B", event_uuid: "debug-uuid-2", event_name: "204B-CALL",
            color: "#DC2626", priority: 9, master_event_type: 1,
            nurse_list: [
                NurseListItem(name: "Aisha Nurse", email: "aisha@example.com", user_id: "nurse-2", shift_time: "08:00-16:00", phone_number: "60122222222"),
                NurseListItem(name: "Ben Nurse", email: "ben@example.com", user_id: "nurse-3", shift_time: "16:00-00:00", phone_number: "60133333333")
            ]
        ),
        NotificationEvent(
            id: "debug-pending-3", occurred_at: "2026-09-10T08:25:00.000Z", ended_at: nil,
            event_status: 0, event_type: 3, ack_by: nil, ack_at: nil, notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "127A", bed_code: "127A", event_uuid: "debug-uuid-3", event_name: "127A-HK",
            color: "#059669", priority: 3, master_event_type: 3,
            nurse_list: []
        ),
        NotificationEvent(
            id: "debug-pending-4", occurred_at: "2026-09-10T08:30:00.000Z", ended_at: nil,
            event_status: 0, event_type: 2, ack_by: nil, ack_at: nil, notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 3",
            bed_name: "119D", bed_code: "119D", event_uuid: "debug-uuid-4", event_name: "119D-AWS",
            color: "#7C3AED", priority: 4, master_event_type: 2,
            nurse_list: [
                NurseListItem(name: "Cara Nurse", email: "cara@example.com", user_id: "nurse-4", shift_time: "00:00-08:00", phone_number: "60144444444")
            ]
        )
    ]

    static let historyEvents: [NotificationEvent] = [
        NotificationEvent(
            id: "debug-history-1", occurred_at: "2026-09-09T09:10:14.000Z", ended_at: "2026-09-09T09:10:51.000Z",
            event_status: 2, event_type: 2, ack_by: "Mani Nurse", ack_at: "2026-09-09T09:10:40.000Z", notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "123A", bed_code: "123A", event_uuid: "debug-uuid-5", event_name: "123A-HK",
            color: "#2563EB", priority: 6, master_event_type: 2, nurse_list: nil
        ),
        NotificationEvent(
            id: "debug-history-2", occurred_at: "2026-09-09T10:05:00.000Z", ended_at: nil,
            event_status: 1, event_type: 1, ack_by: "Aisha Nurse", ack_at: "2026-09-09T10:06:12.000Z", notify_sent: true,
            force_close: 0, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 2",
            bed_name: "204B", bed_code: "204B", event_uuid: "debug-uuid-6", event_name: "204B-CALL",
            color: "#DC2626", priority: 9, master_event_type: 1, nurse_list: nil
        ),
        NotificationEvent(
            id: "debug-history-3", occurred_at: "2026-09-08T14:45:00.000Z", ended_at: "2026-09-08T14:50:22.000Z",
            event_status: 2, event_type: 3, ack_by: nil, ack_at: nil, notify_sent: false,
            force_close: 1, hospital_name: "Pantai Hospital Laguna", ward_name: "WARD 1",
            bed_name: "127A", bed_code: "127A", event_uuid: "debug-uuid-7", event_name: "127A-HK",
            color: "#059669", priority: 3, master_event_type: 3, nurse_list: nil
        )
    ]
}
#endif
