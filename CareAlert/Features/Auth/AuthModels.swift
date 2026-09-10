import Foundation

struct LoginRequest: Encodable {
    let phone_number: String
}

struct LoginResponse: Decodable {
    let success: Bool
    let message: String
    let otp: String
}

/// Request body for the CIOT WhatsApp relay that actually delivers the OTP
/// to the user. The backend's `/login` response only returns the OTP value;
/// this app is responsible for forwarding it.
struct WhatsAppRelayRequest: Encodable {
    let country_code: String
    let footer: String
    let msg: String
    let msg_id: String
    let notify_type: String
    let phone_num: String
    let title: String
}

struct OTPVerifyRequest: Encodable {
    let phone_number: String
    let otp: String
    let mobile_token: String
}

struct OTPVerifyResponse: Decodable {
    let success: Bool
    let message: String
    let token: String
    let expires_at: String
    let expires_in_seconds: Int
    let user: User
}
