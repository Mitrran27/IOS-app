import FirebaseMessaging

/// Async wrapper over Firebase's completion-handler token API. Step 3's
/// OTP-verify call needs this value as `mobile_token` — it is NOT a raw
/// APNs device token.
enum FCMToken {
    static func current() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: APIError.transport("Failed to obtain a push notification token."))
                }
            }
        }
    }
}
