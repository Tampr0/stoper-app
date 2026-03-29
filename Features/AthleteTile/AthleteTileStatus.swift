import Foundation

enum AthleteTileStatus: Equatable, Sendable {
    case idle
    case running
    case paused

    init(timer: AthleteTimer) {
        if timer.isRunning {
            self = .running
        } else if timer.accumulatedElapsed > 0 {
            self = .paused
        } else {
            self = .idle
        }
    }
}
