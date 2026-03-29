import XCTest

@testable import StoperAppCore

final class AthleteTileControllerTests: XCTestCase {
    func testPrimaryActionStartsFromIdle() {
        var controller = AthleteTileController(engine: TimerEngine(timer: makeTimer()))

        let viewState = controller.perform(.primary, at: makeDate(100))

        XCTAssertEqual(viewState.status, .running)
        XCTAssertEqual(viewState.primaryActionTitle, "Pause")
        XCTAssertEqual(viewState.elapsedText, "00:00")
        XCTAssertTrue(viewState.isLapEnabled)
    }

    func testPrimaryActionPausesFromRunning() {
        let timer = makeTimer(isRunning: true, startedAt: makeDate(100))
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))

        let viewState = controller.perform(.primary, at: makeDate(145))

        XCTAssertEqual(viewState.status, .paused)
        XCTAssertEqual(viewState.primaryActionTitle, "Resume")
        XCTAssertEqual(viewState.elapsedText, "00:45")
        XCTAssertFalse(viewState.isLapEnabled)
        XCTAssertTrue(viewState.isResetEnabled)
    }

    func testPrimaryActionResumesFromPaused() {
        let timer = makeTimer(pausedAt: makeDate(145), accumulatedElapsed: 45)
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))

        let viewState = controller.perform(AthleteTileAction.primary, at: makeDate(200))

        XCTAssertEqual(viewState.status, AthleteTileStatus.running)
        XCTAssertEqual(viewState.primaryActionTitle, "Pause")
        XCTAssertEqual(viewState.elapsedText, "00:45")
        XCTAssertTrue(viewState.isLapEnabled)
    }

    func testLapActionRecordsALapOnlyWhileRunning() {
        let timer = makeTimer(isRunning: true, startedAt: makeDate(100))
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))

        let viewState = controller.perform(.lap, at: makeDate(112))

        XCTAssertEqual(viewState.status, .running)
        XCTAssertEqual(viewState.lapCount, 1)
        XCTAssertEqual(viewState.currentRep, 1)
        XCTAssertEqual(viewState.elapsedText, "00:12")
    }

    func testLapActionDoesNothingWhileIdle() {
        var controller = AthleteTileController(engine: TimerEngine(timer: makeTimer()))

        let viewState = controller.perform(.lap, at: makeDate(112))

        XCTAssertEqual(viewState.status, .idle)
        XCTAssertEqual(viewState.lapCount, 0)
        XCTAssertEqual(viewState.currentRep, 0)
        XCTAssertEqual(viewState.elapsedText, "00:00")
    }

    func testLapActionDoesNothingWhilePaused() {
        let timer = makeTimer(pausedAt: makeDate(130), accumulatedElapsed: 30)
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))

        let viewState = controller.perform(AthleteTileAction.lap, at: makeDate(150))

        XCTAssertEqual(viewState.status, AthleteTileStatus.paused)
        XCTAssertEqual(viewState.lapCount, 0)
        XCTAssertEqual(viewState.currentRep, 0)
        XCTAssertEqual(viewState.elapsedText, "00:30")
    }

    func testResetActionClearsStateAfterRunning() {
        let timer = makeTimer(isRunning: true, startedAt: makeDate(100))
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))
        _ = controller.perform(.primary, at: makeDate(145))

        let viewState = controller.perform(.reset, at: makeDate(145))

        XCTAssertEqual(viewState.status, .idle)
        XCTAssertEqual(viewState.elapsedText, "00:00")
        XCTAssertEqual(viewState.lapCount, 0)
        XCTAssertEqual(viewState.currentRep, 0)
        XCTAssertEqual(viewState.primaryActionTitle, "Start")
        XCTAssertFalse(viewState.isLapEnabled)
        XCTAssertFalse(viewState.isResetEnabled)
    }

    func testResetActionClearsStateAfterLaps() {
        let timer = makeTimer(isRunning: true, startedAt: makeDate(100))
        var controller = AthleteTileController(engine: TimerEngine(timer: timer))
        _ = controller.perform(.lap, at: makeDate(110))

        let viewState = controller.perform(.reset, at: makeDate(110))

        XCTAssertEqual(viewState.status, .idle)
        XCTAssertEqual(viewState.lapCount, 0)
        XCTAssertEqual(viewState.currentRep, 0)
        XCTAssertEqual(viewState.elapsedText, "00:00")
        XCTAssertFalse(viewState.isResetEnabled)
    }

    func testPerformReturnsUpdatedViewStateAfterEachAction() {
        var controller = AthleteTileController(engine: TimerEngine(timer: makeTimer()))

        let runningState = controller.perform(.primary, at: makeDate(100))
        let lapState = controller.perform(.lap, at: makeDate(112))
        let pausedState = controller.perform(.primary, at: makeDate(120))

        XCTAssertEqual(runningState.status, .running)
        XCTAssertEqual(lapState.lapCount, 1)
        XCTAssertEqual(lapState.currentRep, 1)
        XCTAssertEqual(pausedState.status, .paused)
        XCTAssertEqual(pausedState.elapsedText, "00:20")
    }

    func testPrimaryActionLabelTransitionsAcrossIdleRunningPausedRunning() {
        var controller = AthleteTileController(engine: TimerEngine(timer: makeTimer()))

        let idleState = controller.makeViewState(at: makeDate(90))
        let runningState = controller.perform(.primary, at: makeDate(100))
        let pausedState = controller.perform(.primary, at: makeDate(115))
        let resumedState = controller.perform(.primary, at: makeDate(130))

        XCTAssertEqual(idleState.primaryActionTitle, "Start")
        XCTAssertEqual(runningState.primaryActionTitle, "Pause")
        XCTAssertEqual(pausedState.primaryActionTitle, "Resume")
        XCTAssertEqual(resumedState.primaryActionTitle, "Pause")
    }

    private func makeTimer(
        name: String = "Lane 1",
        isRunning: Bool = false,
        currentRep: Int = 0,
        totalReps: Int = 4,
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

    private func makeDate(_ seconds: TimeInterval) -> Date {
        Date(timeIntervalSinceReferenceDate: seconds)
    }
}
