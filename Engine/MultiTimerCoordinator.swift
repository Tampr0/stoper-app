import Foundation

struct MultiTimerCoordinator {
    static let maxTimers = 8

    private(set) var timers: [AthleteTimer]

    init(timers: [AthleteTimer] = []) {
        self.timers = Array(timers.prefix(Self.maxTimers))
    }

    var canAddTimer: Bool {
        timers.count < Self.maxTimers
    }

    mutating func addTimer(_ timer: AthleteTimer) -> Bool {
        guard canAddTimer else { return false }
        timers.append(timer)
        return true
    }

    mutating func updateTimer(_ timer: AthleteTimer) {
        guard let index = timers.firstIndex(where: { $0.id == timer.id }) else { return }
        timers[index] = timer
    }

    mutating func removeTimer(id: UUID) {
        timers.removeAll { $0.id == id }
    }
}
