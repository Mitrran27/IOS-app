import Foundation

/// The `user` object returned by `/otp_verify`. Also used on the Profile screen.
struct User: Codable, Equatable {
    let id: String
    let email: String
    let full_name: String
    let phone: String
    let hospital_uuid: String
    let ward_uuid: String?
    let notify_apps: Bool
    let shift_time: String?
    let push_notify_ezycall: Bool
    let push_notify_advance: Bool
    let flag_whatsapp_registration: Int
    let push_notify_asset: Bool
}
