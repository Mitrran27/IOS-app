import Foundation

extension String {
    /// API timestamps are ISO8601 with fractional seconds (e.g.
    /// "2026-08-19T10:15:00.000Z"); falls back to the plain format, and to
    /// the raw string if neither parses.
    var formattedEventTimestamp: String {
        let withFractional = ISO8601DateFormatter()
        withFractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let date = withFractional.date(from: self) ?? ISO8601DateFormatter().date(from: self)
        guard let date else { return self }

        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        displayFormatter.timeStyle = .short
        return displayFormatter.string(from: date)
    }
}
