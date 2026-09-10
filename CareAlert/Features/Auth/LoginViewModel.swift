import Foundation

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var phoneNumber = ""
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    @Published var didSendOTP = false

    private let authService: AuthService

    init(authService: AuthService = AuthService()) {
        self.authService = authService
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
            try await authService.requestOTP(phoneNumber: phoneNumber)
            didSendOTP = true
        } catch {
            errorMessage = (error as? LocalizedError)?.errorDescription ?? "Something went wrong. Please try again."
        }
    }
}
