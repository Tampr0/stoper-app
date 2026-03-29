import XCTest

@testable import StoperAppCore

final class AthleteTilePresenterTests: XCTestCase {
    func testIdleStateMapping() {
        let presenter = AthleteTilePresenter(timer: makeTimer())

        let viewState = presenter.makeViewState(at: makeDate(100))

        XCTAssertEqual(viewState.status, .idle)
        XCTAssertEqual(viewState.name, "Lane 1")
        XCTAssertEqual(viewState.elapsedText, "00:00")
        XCTAssertEqual(viewState.lapCount, 0)
        XCTAssertEqual(viewState.currentRep, 0)
        XCTAssertEqual(viewState.totalReps, 4)
    }

    func testRunningStateMapping() {
        let timer = makeTimer(
            isRunning: true,
            currentRep: 2,
            startedAt: makeDate(100),
            accumulatedElapsed: 5,
            lapTimes: [makeLap(repNumber: 1, elapsedTime: 7)]
        )
        let presenter = AthleteTilePresenter(timer: timer)

        let viewState = presenter.makeViewState(at: makeDate(112))

        XCTAssertEqual(viewState.status, .running)
        XCTAssertEqual(viewState.elapsedText, "00:17")
        XCTAssertEqual(viewState.lapCount, 1)
        XCTAssertEqual(viewState.currentRep, 2)
    }

    func testPausedStateMapping() {
        let timer = makeTimer(
            isRunning: false,
            currentRep: 1,
            pausedAt: makeDate(140),
            accumulatedElapsed: 45,
            lapTimes: [makeLap(repNumber: 1, elapsedTime: 45)]
        )
        let presenter = AthleteTilePresenter(timer: timer)

        let viewState = presenter.makeViewState(at: makeDate(200))

        XCTAssertEqual(viewState.status, .paused)
        XCTAssertEqual(viewState.elapsedText, "00:45")
        XCTAssertEqual(viewState.lapCount, 1)
    }

    func testElapsedFormattingUnderAMinute() {
        let presenter = AthleteTilePresenter(timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 12))

        XCTAssertEqual(presenter.makeViewState(at: makeDate(100)).elapsedText, "00:12")
    }

    func testElapsedFormattingOverAMinute() {
        let presenter = AthleteTilePresenter(timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 65))

        XCTAssertEqual(presenter.makeViewState(at: makeDate(100)).elapsedText, "01:05")
    }

    func testElapsedFormattingOverAnHour() {
        let presenter = AthleteTilePresenter(timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 3_661))

        XCTAssertEqual(presenter.makeViewState(at: makeDate(100)).elapsedText, "01:01:01")
    }

    func testPrimaryActionTitleForEachStatus() {
        let idlePresenter = AthleteTilePresenter(timer: makeTimer())
        let runningPresenter = AthleteTilePresenter(
            timer: makeTimer(isRunning: true, startedAt: makeDate(10))
        )
        let pausedPresenter = AthleteTilePresenter(
            timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 1)
        )

        XCTAssertEqual(idlePresenter.makeViewState(at: makeDate(20)).primaryActionTitle, "Start")
        XCTAssertEqual(runningPresenter.makeViewState(at: makeDate(20)).primaryActionTitle, "Pause")
        XCTAssertEqual(pausedPresenter.makeViewState(at: makeDate(20)).primaryActionTitle, "Resume")
    }

    func testLapEnabledOnlyWhileRunning() {
        let idlePresenter = AthleteTilePresenter(timer: makeTimer())
        let runningPresenter = AthleteTilePresenter(
            timer: makeTimer(isRunning: true, startedAt: makeDate(10))
        )
        let pausedPresenter = AthleteTilePresenter(
            timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 1)
        )

        XCTAssertFalse(idlePresenter.makeViewState(at: makeDate(20)).isLapEnabled)
        XCTAssertTrue(runningPresenter.makeViewState(at: makeDate(20)).isLapEnabled)
        XCTAssertFalse(pausedPresenter.makeViewState(at: makeDate(20)).isLapEnabled)
    }

    func testResetEnabledWhenElapsedIsNonZero() {
        let presenter = AthleteTilePresenter(
            timer: makeTimer(pausedAt: makeDate(10), accumulatedElapsed: 1)
        )

        XCTAssertTrue(presenter.makeViewState(at: makeDate(20)).isResetEnabled)
    }

    func testResetEnabledWhenRecordedLapsExist() {
        let presenter = AthleteTilePresenter(
            timer: makeTimer(lapTimes: [makeLap(repNumber: 1, elapsedTime: 0)])
        )

        XCTAssertTrue(presenter.makeViewState(at: makeDate(20)).isResetEnabled)
    }

    func testResetDisabledForFreshIdleTimer() {
        let presenter = AthleteTilePresenter(timer: makeTimer())

        XCTAssertFalse(presenter.makeViewState(at: makeDate(20)).isResetEnabled)
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
