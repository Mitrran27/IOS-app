import Foundation

/// A nurse-call event record. The pending (`/get_pending_notifications`) and
/// history (`/get_history_notifications`) APIs return this same shape, so
/// Alarms, History, and History Detail all share this one model.
struct NotificationEvent: Codable, Identifiable, Hashable {
    let id: String
    let occurred_at: String
    let ended_at: String?
    let event_status: Int
    let event_type: Int
    let ack_by: String?
    let ack_at: String?
    let notify_sent: Bool
    let force_close: Int?
    let hospital_name: String
    let ward_name: String
    let bed_name: String
    let bed_code: String?
    let event_uuid: String?
    let event_name: String
    let color: String
    let priority: Int
    let master_event_type: Int?
    // Not present on every history record in the sample docs; treated as
    // absent-safe rather than assumed present.
    let nurse_list: [NurseListItem]?
}

struct NurseListItem: Codable, Hashable, Identifiable {
    let name: String
    let email: String?
    let user_id: String
    let shift_time: String?
    let phone_number: String?

    var id: String { user_id }
}

struct NotificationListResponse: Decodable {
    let success: Bool
    let count: Int
    let data: [NotificationEvent]
}
