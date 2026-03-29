import Foundation

struct AthleteTilePresenter {
    private let timer: AthleteTimer

    init(engine: TimerEngine) {
        self.init(timer: engine.timer)
    }

    init(timer: AthleteTimer) {
        self.timer = timer
    }

    func makeViewState(at now: Date = Date()) -> AthleteTileViewState {
        let status = AthleteTileStatus(timer: timer)
        let elapsed = Self.elapsed(for: timer, at: now)

        return AthleteTileViewState(
            id: timer.id,
            name: timer.name,
            status: status,
            elapsedText: Self.formatElapsed(elapsed),
            lapCount: timer.lapTimes.count,
            currentRep: timer.currentRep,
            totalReps: timer.totalReps,
            primaryActionTitle: primaryActionTitle(for: status),
            isLapEnabled: status == .running,
            isResetEnabled: elapsed > 0 || !timer.lapTimes.isEmpty || timer.currentRep > 0
        )
    }

    private func primaryActionTitle(for status: AthleteTileStatus) -> String {
        switch status {
        case .idle:
            return "Start"
        case .running:
            return "Pause"
        case .paused:
            return "Resume"
        }
    }

    private static func elapsed(for timer: AthleteTimer, at now: Date) -> TimeInterval {
        if timer.isRunning, let startedAt = timer.startedAt {
            return timer.accumulatedElapsed + now.timeIntervalSince(startedAt)
        }

        if timer.pausedAt != nil {
            return timer.accumulatedElapsed
        }

        return 0
    }

    private static func formatElapsed(_ elapsed: TimeInterval) -> String {
        let totalSeconds = max(0, Int(elapsed))
        let hours = totalSeconds / 3_600
        let minutes = (totalSeconds % 3_600) / 60
        let seconds = totalSeconds % 60

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        }

        return String(format: "%02d:%02d", minutes, seconds)
    }
}
