import SwiftUI

struct ContentView: View {
    @State private var controller: AthleteTileController
    @State private var state: AthleteTileViewState

    init() {
        let timer = AthleteTimer(name: "Athlete 1", totalReps: 8)
        let controller = AthleteTileController(engine: TimerEngine(timer: timer))

        _controller = State(initialValue: controller)
        _state = State(initialValue: controller.makeViewState())
    }

    var body: some View {
        NavigationView {
            ScrollView {
                AthleteTileView(
                    state: state,
                    onPrimary: { perform(.primary) },
                    onLap: { perform(.lap) },
                    onReset: { perform(.reset) }
                )
                .padding()
            }
            .navigationTitle("Stopwatch")
        }
    }

    private func perform(_ action: AthleteTileAction) {
        var updatedController = controller
        let updatedState = updatedController.perform(action)
        controller = updatedController
        state = updatedState
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
