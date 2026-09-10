import Foundation

@MainActor
final class OTPVerifyViewModel: ObservableObject {
    let phoneNumber: String

    @Published var otp = ""
    @Published var isVerifying = false
    @Published var isResending = false
    @Published var errorMessage: String?
    @Published var statusMessage: String? = "Code sent."
    @Published private(set) var verifiedToken: String?
    @Published private(set) var verifiedUser: User?

    private let apiClient: APIClient
    private let authService: AuthService
    private let mobileTokenProvider: () async throws -> String

    init(
        phoneNumber: String,
        apiClient: APIClient = .shared,
        authService: AuthService = AuthService(),
        mobileTokenProvider: @escaping () async throws -> String = { try await FCMToken.current() }
    ) {
        self.phoneNumber = phoneNumber
        self.apiClient = apiClient
        self.authService = authService
        self.mobileTokenProvider = mobileTokenProvider
    }

    var isOTPValid: Bool {
        otp.count == 6 && otp.allSatisfy(\.isNumber)
    }

    func verify() async {
        guard isOTPValid, !isVerifying else { return }
        isVerifying = true
        errorMessage = nil
        statusMessage = nil
        defer { isVerifying = false }

        let mobileToken: String
        do {
            mobileToken = try await mobileTokenProvider()
        } catch {
            errorMessage = "Unable to set up push notifications. Please check your connection and try again."
            return
        }

        do {
            let response: OTPVerifyResponse = try await apiClient.request(
                "otp_verify",
                body: OTPVerifyRequest(
                    phone_number: phoneNumber,
                    otp: otp,
                    mobile_token: mobileToken
                ),
                requiresAuth: false
            )
            verifiedToken = response.token
            verifiedUser = response.user
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Invalid or expired code. Please try again."
        }
    }

    func resendOTP() async {
        guard !isResending else { return }
        isResending = true
        errorMessage = nil
        statusMessage = nil
        defer { isResending = false }

        do {
            try await authService.requestOTP(phoneNumber: phoneNumber)
            statusMessage = "Code sent."
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Failed to resend code. Please try again."
        }
    }
}
