import Foundation

struct LapRecord: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    let repNumber: Int
    let elapsedTime: TimeInterval
    let splitTime: TimeInterval
    let timestamp: Date

    init(
        id: UUID = UUID(),
        repNumber: Int,
        elapsedTime: TimeInterval,
        splitTime: TimeInterval,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.repNumber = repNumber
        self.elapsedTime = elapsedTime
        self.splitTime = splitTime
        self.timestamp = timestamp
    }
}
