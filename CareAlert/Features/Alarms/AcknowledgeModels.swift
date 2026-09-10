import Foundation

struct AcknowledgeRequest: Encodable {
    let event_log_id: String
    let nurse_uuid: String
}
