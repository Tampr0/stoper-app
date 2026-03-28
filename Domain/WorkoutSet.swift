import Foundation

struct WorkoutSet: Codable, Equatable, Sendable {
    let repeatCount: Int
    let intervalDuration: TimeInterval?
    let restDuration: TimeInterval?

    init(
        repeatCount: Int,
        intervalDuration: TimeInterval? = nil,
        restDuration: TimeInterval? = nil
    ) {
        self.repeatCount = repeatCount
        self.intervalDuration = intervalDuration
        self.restDuration = restDuration
    }
}
