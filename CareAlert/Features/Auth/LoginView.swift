import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @FocusState private var phoneFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "bell.badge.fill")
                    .font(.system(size: 56))
                    .foregroundStyle(.tint)

                Text("Login to your account")
                    .font(.title2)
                    .fontWeight(.semibold)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Phone Number")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    TextField("60183810223", text: $viewModel.phoneNumber)
                        .keyboardType(.numberPad)
                        .textContentType(.telephoneNumber)
                        .focused($phoneFieldFocused)
                        .textFieldStyle(.roundedBorder)
                        .disabled(viewModel.isSubmitting)
                }

                Text("We'll send a one-time code to this number via WhatsApp.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                }

                Button {
                    phoneFieldFocused = false
                    Task { await viewModel.sendOTP() }
                } label: {
                    if viewModel.isSubmitting {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Send OTP")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!viewModel.isPhoneNumberValid || viewModel.isSubmitting)

                Spacer()
            }
            .padding(24)
            .navigationDestination(isPresented: $viewModel.didSendOTP) {
                OTPVerifyView(phoneNumber: viewModel.phoneNumber)
            }
        }
    }
}

#Preview {
    LoginView()
}
