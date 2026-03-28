import XCTest

final class MultiTimerCoordinatorTests: XCTestCase {
    func testAddTimerUntilMaxStoresEightTimersAndDisablesFurtherAdds() {
        var coordinator = MultiTimerCoordinator()

        for index in 1...8 {
            XCTAssertTrue(coordinator.addTimer(makeTimer(index: index)))
        }

        XCTAssertEqual(coordinator.timers.count, 8)
        XCTAssertFalse(coordinator.canAddTimer)
    }

    func testAddingNinthTimerIsIgnored() {
        var coordinator = MultiTimerCoordinator()

        for index in 1...8 {
            XCTAssertTrue(coordinator.addTimer(makeTimer(index: index)))
        }

        XCTAssertFalse(coordinator.addTimer(makeTimer(index: 9)))
        XCTAssertEqual(coordinator.timers.count, 8)
    }

    func testInitWithMoreThanEightTimersTruncatesToEight() {
        let timers = (1...9).map(makeTimer)
        let coordinator = MultiTimerCoordinator(timers: timers)

        XCTAssertEqual(coordinator.timers.count, 8)
    }

    func testRemoveTimerDeletesMatchingIdentifier() {
        let first = makeTimer(index: 1)
        let second = makeTimer(index: 2)
        let third = makeTimer(index: 3)
        var coordinator = MultiTimerCoordinator(timers: [first, second, third])

        coordinator.removeTimer(id: second.id)

        XCTAssertEqual(coordinator.timers.count, 2)
        XCTAssertFalse(coordinator.timers.contains { $0.id == second.id })
    }

    private func makeTimer(index: Int) -> AthleteTimer {
        AthleteTimer(name: "Lane \(index)")
    }
}
