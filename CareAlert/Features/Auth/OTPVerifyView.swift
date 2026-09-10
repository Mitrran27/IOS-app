import SwiftUI

/// Placeholder for Step 3. Confirms navigation from Login works; the real
/// OTP input UI and `/otp_verify` call are built in the next step.
struct OTPVerifyView: View {
    let phoneNumber: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Code sent to")
                .foregroundStyle(.secondary)
            Text(phoneNumber)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .navigationTitle("Verify OTP")
    }
}

#Preview {
    OTPVerifyView(phoneNumber: "60183810223")
}
