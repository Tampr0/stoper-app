import Foundation

struct TimerSession: Codable, Equatable, Sendable {
    var timers: [AthleteTimer]
    var updatedAt: Date

    init(timers: [AthleteTimer], updatedAt: Date = Date()) {
        self.timers = timers
        self.updatedAt = updatedAt
    }
}

protocol SessionStore {
    func loadSession() throws -> TimerSession?
    func saveSession(_ session: TimerSession) throws
}
