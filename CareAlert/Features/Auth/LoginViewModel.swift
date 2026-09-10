import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didSendOTP = false

    private let apiClient: APIClient
    private let relayClient: APIClient

    init(
        apiClient: APIClient = .shared,
        relayClient: APIClient = APIClient(baseURL: Config.whatsAppRelayURL)
    ) {
        self.apiClient = apiClient
        self.relayClient = relayClient
    }

    /// Digits only, no country-code symbol — matches the backend's expected format (e.g. "60183810223").
    var isPhoneNumberValid: Bool {
        let trimmed = phoneNumber.trimmingCharacters(in: .whitespaces)
        return trimmed.count >= 9 && trimmed.count <= 15 && trimmed.allSatisfy(\.isNumber)
    }

    func sendOTP() async {
        guard isPhoneNumberValid, !isSubmitting else { return }
        isSubmitting = true
        errorMessage = nil
        defer { isSubmitting = false }

        do {
            let response: LoginResponse = try await apiClient.request(
                "login",
                body: LoginRequest(phone_number: phoneNumber),
                requiresAuth: false
            )
            try await deliverOTPViaWhatsApp(response.otp)
            didSendOTP = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
        }
    }

    private func deliverOTPViaWhatsApp(_ otp: String) async throws {
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
