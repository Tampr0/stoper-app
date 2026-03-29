import XCTest

@testable import StoperAppCore

final class DashboardControllerTests: XCTestCase {
    func testEmptyDashboardState() {
        let controller = DashboardController()

        let viewState = controller.makeViewState(at: makeDate(100))

        XCTAssertTrue(viewState.tiles.isEmpty)
        XCTAssertTrue(viewState.canAddAthlete)
        XCTAssertEqual(viewState.athleteCount, 0)
        XCTAssertEqual(viewState.maxAthleteCount, 8)
    }

    func testAddingOneAthleteUpdatesCountAndTileList() {
        var controller = DashboardController()

        let viewState = controller.addAthlete(name: "Lane 1", totalReps: 4)

        XCTAssertEqual(viewState.athleteCount, 1)
        XCTAssertEqual(viewState.tiles.count, 1)
        XCTAssertEqual(viewState.tiles[0].name, "Lane 1")
        XCTAssertEqual(viewState.tiles[0].totalReps, 4)
    }

    func testAddingAthletesUpToEightSetsCanAddAthleteToFalse() {
        var controller = DashboardController()

        for index in 1...8 {
            _ = controller.addAthlete(name: "Lane \(index)")
        }

        let viewState = controller.makeViewState(at: makeDate(100))

        XCTAssertEqual(viewState.athleteCount, 8)
        XCTAssertFalse(viewState.canAddAthlete)
    }

    func testAddingNinthAthleteDoesNothing() {
        var controller = DashboardController()

        for index in 1...8 {
            _ = controller.addAthlete(name: "Lane \(index)")
        }

        let before = controller.makeViewState(at: makeDate(100))
        let after = controller.addAthlete(name: "Lane 9")

        XCTAssertEqual(after.athleteCount, 8)
        XCTAssertEqual(after.tiles, before.tiles)
        XCTAssertFalse(after.canAddAthlete)
    }

    func testRemovingAnAthleteDecreasesCount() {
        let first = makeTimer(name: "Lane 1")
        let second = makeTimer(name: "Lane 2")
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second])
        )

        let viewState = controller.removeAthlete(id: first.id)

        XCTAssertEqual(viewState.athleteCount, 1)
        XCTAssertEqual(viewState.tiles.map(\.id), [second.id])
    }

    func testRemovingMissingAthleteDoesNothing() {
        let first = makeTimer(name: "Lane 1")
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first])
        )

        let before = controller.makeViewState(at: makeDate(100))
        let after = controller.removeAthlete(id: UUID())

        XCTAssertEqual(after, before)
    }

    func testPerformingPrimaryActionAffectsOnlyTargetedAthlete() {
        let first = makeTimer(name: "Lane 1")
        let second = makeTimer(name: "Lane 2")
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second])
        )

        let viewState = controller.perform(.primary, for: first.id, at: makeDate(100))

        XCTAssertEqual(viewState.tiles[0].status, .running)
        XCTAssertEqual(viewState.tiles[0].primaryActionTitle, "Pause")
        XCTAssertEqual(viewState.tiles[1].status, .idle)
        XCTAssertEqual(viewState.tiles[1].primaryActionTitle, "Start")
    }

    func testPerformingLapAffectsOnlyTargetedAthlete() {
        let first = makeTimer(name: "Lane 1", isRunning: true, startedAt: makeDate(100))
        let second = makeTimer(name: "Lane 2", isRunning: true, startedAt: makeDate(100))
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second])
        )

        let viewState = controller.perform(.lap, for: first.id, at: makeDate(112))

        XCTAssertEqual(viewState.tiles[0].lapCount, 1)
        XCTAssertEqual(viewState.tiles[0].currentRep, 1)
        XCTAssertEqual(viewState.tiles[1].lapCount, 0)
        XCTAssertEqual(viewState.tiles[1].currentRep, 0)
    }

    func testPerformingResetAffectsOnlyTargetedAthlete() {
        let first = makeTimer(
            name: "Lane 1",
            currentRep: 1,
            pausedAt: makeDate(130),
            accumulatedElapsed: 30,
            lapTimes: [makeLap(repNumber: 1, elapsedTime: 30)]
        )
        let second = makeTimer(
            name: "Lane 2",
            currentRep: 2,
            pausedAt: makeDate(140),
            accumulatedElapsed: 40,
            lapTimes: [makeLap(repNumber: 1, elapsedTime: 40)]
        )
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second])
        )

        let viewState = controller.perform(.reset, for: first.id, at: makeDate(150))

        XCTAssertEqual(viewState.tiles[0].status, .idle)
        XCTAssertEqual(viewState.tiles[0].lapCount, 0)
        XCTAssertEqual(viewState.tiles[0].currentRep, 0)
        XCTAssertFalse(viewState.tiles[0].isResetEnabled)
        XCTAssertEqual(viewState.tiles[1].status, .paused)
        XCTAssertEqual(viewState.tiles[1].lapCount, 1)
        XCTAssertEqual(viewState.tiles[1].currentRep, 2)
        XCTAssertTrue(viewState.tiles[1].isResetEnabled)
    }

    func testTileOrderRemainsStableAfterActions() {
        let first = makeTimer(name: "Lane 1")
        let second = makeTimer(name: "Lane 2")
        let third = makeTimer(name: "Lane 3")
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second, third])
        )

        let viewState = controller.perform(.primary, for: second.id, at: makeDate(100))

        XCTAssertEqual(viewState.tiles.map(\.id), [first.id, second.id, third.id])
    }

    func testNewlyAddedAthleteAppearsAtTheEnd() {
        let first = makeTimer(name: "Lane 1")
        let second = makeTimer(name: "Lane 2")
        var controller = DashboardController(
            coordinator: MultiTimerCoordinator(timers: [first, second])
        )

        let viewState = controller.addAthlete(name: "Lane 3")

        XCTAssertEqual(viewState.tiles.count, 3)
        XCTAssertEqual(viewState.tiles[0].id, first.id)
        XCTAssertEqual(viewState.tiles[1].id, second.id)
        XCTAssertEqual(viewState.tiles[2].name, "Lane 3")
    }

    private func makeTimer(
        name: String,
        isRunning: Bool = false,
        currentRep: Int = 0,
        totalReps: Int = 0,
        startedAt: Date? = nil,
        pausedAt: Date? = nil,
        accumulatedElapsed: TimeInterval = 0,
        lapTimes: [LapRecord] = []
    ) -> AthleteTimer {
        AthleteTimer(
            name: name,
            isRunning: isRunning,
            currentRep: currentRep,
            totalReps: totalReps,
            startedAt: startedAt,
            pausedAt: pausedAt,
            accumulatedElapsed: accumulatedElapsed,
            lapTimes: lapTimes
        )
    }

    private func makeLap(repNumber: Int, elapsedTime: TimeInterval) -> LapRecord {
        LapRecord(
            repNumber: repNumber,
            elapsedTime: elapsedTime,
            splitTime: elapsedTime,
            timestamp: makeDate(0)
        )
    }

    private func makeDate(_ seconds: TimeInterval) -> Date {
        Date(timeIntervalSinceReferenceDate: seconds)
    }
}
