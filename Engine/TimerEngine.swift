import Foundation

struct TimerEngine {
    private(set) var timer: AthleteTimer

    init(timer: AthleteTimer) {
        self.timer = timer
    }

    mutating func start(at now: Date = Date()) {
        guard !timer.isRunning else { return }

        timer.isRunning = true
        timer.startedAt = now
        timer.pausedAt = nil
    }

    mutating func pause(at now: Date = Date()) {
        guard timer.isRunning else { return }

        if let startedAt = timer.startedAt {
            timer.accumulatedElapsed += now.timeIntervalSince(startedAt)
        }

        timer.isRunning = false
        timer.startedAt = nil
        timer.pausedAt = now
    }

    mutating func stop(at now: Date = Date()) {
        pause(at: now)
    }

    mutating func reset() {
        timer.isRunning = false
        timer.currentRep = 0
        timer.startedAt = nil
        timer.pausedAt = nil
        timer.accumulatedElapsed = 0
        timer.lapTimes = []
    }

    @discardableResult
    mutating func lap(at now: Date = Date()) -> LapRecord? {
        guard timer.isRunning else { return nil }

        let totalElapsed = elapsed(at: now)
        let previousElapsed = timer.lapTimes.last?.elapsedTime ?? 0
        let nextRep = timer.lapTimes.count + 1
        let record = LapRecord(
            repNumber: nextRep,
            elapsedTime: totalElapsed,
            splitTime: totalElapsed - previousElapsed,
            timestamp: now
        )

        timer.currentRep = nextRep
        timer.lapTimes.append(record)
        return record
    }

    func elapsed(at now: Date = Date()) -> TimeInterval {
        if timer.isRunning, let startedAt = timer.startedAt {
            return timer.accumulatedElapsed + now.timeIntervalSince(startedAt)
        }

        if timer.pausedAt != nil {
            return timer.accumulatedElapsed
        }

        return 0
    }
}
