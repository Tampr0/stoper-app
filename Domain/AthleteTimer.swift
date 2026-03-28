import Foundation

struct AthleteTimer: Identifiable, Codable, Equatable, Sendable {
    let id: UUID
    var name: String
    var mode: TimerMode
    var isRunning: Bool
    var currentRep: Int
    var totalReps: Int
    var startedAt: Date?
    var pausedAt: Date?
    var accumulatedElapsed: TimeInterval
    var lapTimes: [LapRecord]

    init(
        id: UUID = UUID(),
        name: String,
        mode: TimerMode = .manual,
        isRunning: Bool = false,
        currentRep: Int = 0,
        totalReps: Int = 0,
        startedAt: Date? = nil,
        pausedAt: Date? = nil,
        accumulatedElapsed: TimeInterval = 0,
        lapTimes: [LapRecord] = []
    ) {
        self.id = id
        self.name = name
        self.mode = mode
        self.isRunning = isRunning
        self.currentRep = currentRep
        self.totalReps = totalReps
        self.startedAt = startedAt
        self.pausedAt = pausedAt
        self.accumulatedElapsed = accumulatedElapsed
        self.lapTimes = lapTimes
    }
}
