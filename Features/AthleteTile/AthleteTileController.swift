import Foundation

struct AthleteTileController {
    private var engine: TimerEngine

    init(engine: TimerEngine) {
        self.engine = engine
    }

    func makeViewState(at now: Date = Date()) -> AthleteTileViewState {
        AthleteTilePresenter(engine: engine).makeViewState(at: now)
    }

    mutating func perform(_ action: AthleteTileAction, at now: Date = Date()) -> AthleteTileViewState {
        switch action {
        case .primary:
            performPrimaryAction(at: now)
        case .lap:
            _ = engine.lap(at: now)
        case .reset:
            engine.reset()
        }

        return makeViewState(at: now)
    }

    private mutating func performPrimaryAction(at now: Date) {
        switch AthleteTileStatus(timer: engine.timer) {
        case .idle, .paused:
            engine.start(at: now)
        case .running:
            engine.pause(at: now)
        }
    }
}
