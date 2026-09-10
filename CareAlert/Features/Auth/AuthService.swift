import Foundation

/// The login-OTP flow: calls `/login`, then forwards the returned OTP to the
/// WhatsApp relay. Shared by the Login screen and OTP Verify's resend action.
struct AuthService {
    private let apiClient: APIClient
    private let relayClient: APIClient

    init(
        apiClient: APIClient = .shared,
        relayClient: APIClient = APIClient(baseURL: Config.whatsAppRelayURL)
    ) {
        self.apiClient = apiClient
        self.relayClient = relayClient
    }

    func requestOTP(phoneNumber: String) async throws {
        let response: LoginResponse = try await apiClient.request(
            "login",
            body: LoginRequest(phone_number: phoneNumber),
            requiresAuth: false
        )
        try await deliverOTPViaWhatsApp(response.otp, phoneNumber: phoneNumber)
    }

    private func deliverOTPViaWhatsApp(_ otp: String, phoneNumber: String) async throws {
        let relayRequest = WhatsAppRelayRequest(
            country_code: "+60",
            footer: "*Reported by Ezycall AI System*",
            msg: "Your OTP is: \(otp)\nThis OTP is valid for 5 minutes.\nDo not share this OTP with anyone.",
            msg_id: UUID().uuidString,
            notify_type: "whatsapp",
            phone_num: "+\(phoneNumber)",
            title: "EzyCall Login OTP"
        )
        try await relayClient.requestNoContent("", body: relayRequest, requiresAuth: false)
    }
}
