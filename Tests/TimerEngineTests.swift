import XCTest
@testable import StoperAppCore

final class TimerEngineTests: XCTestCase {
    func testStartFromIdleMarksTimerRunningWithoutChangingAccumulatedElapsed() {
        let t0 = makeDate(100)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)

        XCTAssertTrue(engine.timer.isRunning)
        XCTAssertEqual(engine.timer.startedAt, t0)
        XCTAssertNil(engine.timer.pausedAt)
        XCTAssertEqual(engine.timer.accumulatedElapsed, 0, accuracy: 0.000_1)
    }

    func testPauseAfterRunningStoresAccumulatedElapsedAndPausedAt() {
        let t0 = makeDate(100)
        let t1 = makeDate(145)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        engine.pause(at: t1)

        XCTAssertFalse(engine.timer.isRunning)
        XCTAssertNil(engine.timer.startedAt)
        XCTAssertEqual(engine.timer.pausedAt, t1)
        XCTAssertEqual(engine.timer.accumulatedElapsed, 45, accuracy: 0.000_1)
    }

    func testStartWhilePausedResumesWithoutClearingAccumulatedElapsed() {
        let t0 = makeDate(100)
        let t1 = makeDate(145)
        let t2 = makeDate(200)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        engine.pause(at: t1)
        engine.start(at: t2)

        XCTAssertTrue(engine.timer.isRunning)
        XCTAssertEqual(engine.timer.startedAt, t2)
        XCTAssertNil(engine.timer.pausedAt)
        XCTAssertEqual(engine.timer.accumulatedElapsed, 45, accuracy: 0.000_1)
    }

    func testElapsedWhileRunningUsesStartTimeAndAccumulatedElapsed() {
        let t0 = makeDate(100)
        let t1 = makeDate(135)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)

        XCTAssertEqual(engine.elapsed(at: t1), 35, accuracy: 0.000_1)
    }

    func testElapsedWhilePausedRemainsFrozen() {
        let t0 = makeDate(100)
        let t1 = makeDate(145)
        let t2 = makeDate(200)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        engine.pause(at: t1)

        XCTAssertEqual(engine.elapsed(at: t2), 45, accuracy: 0.000_1)
    }

    func testResetReturnsTimerToIdleState() {
        let t0 = makeDate(100)
        let t1 = makeDate(125)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        _ = engine.lap(at: t1)
        engine.reset()

        XCTAssertFalse(engine.timer.isRunning)
        XCTAssertNil(engine.timer.startedAt)
        XCTAssertNil(engine.timer.pausedAt)
        XCTAssertEqual(engine.timer.accumulatedElapsed, 0, accuracy: 0.000_1)
        XCTAssertEqual(engine.timer.currentRep, 0)
        XCTAssertTrue(engine.timer.lapTimes.isEmpty)
    }

    func testLapWhileRunningCreatesFirstLapWithMatchingElapsedAndSplit() {
        let t0 = makeDate(100)
        let t1 = makeDate(112)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        let lap = engine.lap(at: t1)

        XCTAssertNotNil(lap)
        XCTAssertEqual(engine.timer.lapTimes.count, 1)
        XCTAssertEqual(lap?.repNumber, 1)
        XCTAssertEqual(lap?.elapsedTime, 12, accuracy: 0.000_1)
        XCTAssertEqual(lap?.splitTime, 12, accuracy: 0.000_1)
        XCTAssertEqual(engine.timer.currentRep, 1)
    }

    func testSecondLapUsesPreviousLapForSplitTime() {
        let t0 = makeDate(100)
        let t1 = makeDate(112)
        let t2 = makeDate(130)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        _ = engine.lap(at: t1)
        let secondLap = engine.lap(at: t2)

        XCTAssertEqual(secondLap?.repNumber, 2)
        XCTAssertEqual(secondLap?.elapsedTime, 30, accuracy: 0.000_1)
        XCTAssertEqual(secondLap?.splitTime, 18, accuracy: 0.000_1)
        XCTAssertEqual(engine.timer.lapTimes.count, 2)
        XCTAssertEqual(engine.timer.currentRep, 2)
    }

    func testLapWhilePausedReturnsNilWithoutChangingLapTimes() {
        let t0 = makeDate(100)
        let t1 = makeDate(120)
        let t2 = makeDate(140)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        engine.pause(at: t1)
        let lap = engine.lap(at: t2)

        XCTAssertNil(lap)
        XCTAssertTrue(engine.timer.lapTimes.isEmpty)
        XCTAssertEqual(engine.timer.currentRep, 0)
    }

    func testStartWhileAlreadyRunningDoesNotResetElapsed() {
        let t0 = makeDate(100)
        let t1 = makeDate(120)
        let t2 = makeDate(150)
        var engine = TimerEngine(timer: makeTimer())

        engine.start(at: t0)
        engine.start(at: t1)

        XCTAssertEqual(engine.timer.startedAt, t0)
        XCTAssertEqual(engine.elapsed(at: t2), 50, accuracy: 0.000_1)
    }

    private func makeTimer() -> AthleteTimer {
        AthleteTimer(name: "Lane 1")
    }

    private func makeDate(_ seconds: TimeInterval) -> Date {
        Date(timeIntervalSinceReferenceDate: seconds)
    }
}
