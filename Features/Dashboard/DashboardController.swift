import Foundation

struct DashboardController {
    private var coordinator: MultiTimerCoordinator

    init(coordinator: MultiTimerCoordinator = MultiTimerCoordinator()) {
        self.coordinator = coordinator
    }

    func makeViewState(at now: Date = Date()) -> DashboardViewState {
        let tiles = coordinator.timers.map { timer in
            AthleteTilePresenter(timer: timer).makeViewState(at: now)
        }

        return DashboardViewState(
            tiles: tiles,
            canAddAthlete: coordinator.canAddTimer,
            athleteCount: coordinator.timers.count,
            maxAthleteCount: MultiTimerCoordinator.maxTimers
        )
    }

    mutating func perform(_ action: AthleteTileAction, for athleteID: UUID, at now: Date = Date()) -> DashboardViewState {
        guard let timer = coordinator.timers.first(where: { $0.id == athleteID }) else {
            return makeViewState(at: now)
        }

        var controller = AthleteTileController(engine: TimerEngine(timer: timer))
        _ = controller.perform(action, at: now)
        coordinator.updateTimer(controller.timer)

        return makeViewState(at: now)
    }

    mutating func addAthlete(name: String, totalReps: Int = 0) -> DashboardViewState {
        let timer = AthleteTimer(name: name, totalReps: totalReps)
        _ = coordinator.addTimer(timer)
        return makeViewState()
    }

    mutating func removeAthlete(id: UUID) -> DashboardViewState {
        coordinator.removeTimer(id: id)
        return makeViewState()
    }
}
