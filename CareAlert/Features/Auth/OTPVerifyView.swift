import SwiftUI

struct OTPVerifyView: View {
    @StateObject private var viewModel: OTPVerifyViewModel
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.dismiss) private var dismiss
    @FocusState private var otpFieldFocused: Bool

    init(phoneNumber: String) {
        _viewModel = StateObject(wrappedValue: OTPVerifyViewModel(phoneNumber: phoneNumber))
    }

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 4) {
                Text("Code sent to")
                    .foregroundStyle(.secondary)
                Text(viewModel.phoneNumber)
                    .font(.headline)

                Button("Change") { dismiss() }
                    .font(.footnote)
            }

            TextField("6-digit code", text: $viewModel.otp)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .multilineTextAlignment(.center)
                .font(.title2)
                .focused($otpFieldFocused)
                .textFieldStyle(.roundedBorder)
                .disabled(viewModel.isVerifying)
                .onChange(of: viewModel.otp) { newValue in
                    if newValue.count > 6 {
                        viewModel.otp = String(newValue.prefix(6))
                    }
                }

            if let statusMessage = viewModel.statusMessage {
                Text(statusMessage)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }

            Button {
                otpFieldFocused = false
                Task { await viewModel.verify() }
            } label: {
                if viewModel.isVerifying {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Verify and Sign In")
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isOTPValid || viewModel.isVerifying)

            Button("Resend code") {
                Task { await viewModel.resendOTP() }
            }
            .font(.footnote)
            .disabled(viewModel.isResending || viewModel.isVerifying)

            Spacer()
        }
        .padding(24)
        .navigationTitle("Verify OTP")
        .onChange(of: viewModel.verifiedToken) { token in
            guard let token, let user = viewModel.verifiedUser else { return }
            // RootView observes sessionManager.isLoggedIn and swaps to the
            // logged-in tab shell automatically — no local navigation needed.
            sessionManager.saveSession(token: token, user: user)
        }
    }
}

#Preview {
    NavigationStack {
        OTPVerifyView(phoneNumber: "60183810223")
    }
    .environmentObject(SessionManager())
}
