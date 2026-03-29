import SwiftUI

struct AthleteTileView: View {
    let state: AthleteTileViewState
    let onPrimary: () -> Void
    let onLap: () -> Void
    let onReset: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(state.name)
                    .font(.headline)

                Text(state.elapsedText)
                    .font(.system(size: 42, weight: .bold, design: .monospaced))
                    .frame(maxWidth: .infinity, alignment: .leading)

                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            HStack {
                Text("Laps: \(state.lapCount)")
                Spacer()
                Text("Rep \(state.currentRep) / \(state.totalReps)")
            }
            .font(.subheadline)

            HStack(spacing: 12) {
                Button(state.primaryActionTitle, action: onPrimary)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)

                Button("Lap", action: onLap)
                    .buttonStyle(.bordered)
                    .disabled(!state.isLapEnabled)
                    .frame(maxWidth: .infinity)

                Button("Reset", action: onReset)
                    .buttonStyle(.bordered)
                    .disabled(!state.isResetEnabled)
                    .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }

    private var statusText: String {
        switch state.status {
        case .idle:
            return "Idle"
        case .running:
            return "Running"
        case .paused:
            return "Paused"
        }
    }
}

struct AthleteTileView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AthleteTileView(
                state: makeIdleState(),
                onPrimary: {},
                onLap: {},
                onReset: {}
            )
            .previewDisplayName("Idle")

            AthleteTileView(
                state: makeRunningState(),
                onPrimary: {},
                onLap: {},
                onReset: {}
            )
            .previewDisplayName("Running")

            AthleteTileView(
                state: makePausedState(),
                onPrimary: {},
                onLap: {},
                onReset: {}
            )
            .previewDisplayName("Paused")
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }

    private static func makeIdleState() -> AthleteTileViewState {
        AthleteTileViewState(
            id: UUID(),
            name: "Athlete 1",
            status: .idle,
            elapsedText: "00:00",
            lapCount: 0,
            currentRep: 0,
            totalReps: 8,
            primaryActionTitle: "Start",
            isLapEnabled: false,
            isResetEnabled: false
        )
    }

    private static func makeRunningState() -> AthleteTileViewState {
        AthleteTileViewState(
            id: UUID(),
            name: "Athlete 1",
            status: .running,
            elapsedText: "01:24",
            lapCount: 2,
            currentRep: 2,
            totalReps: 8,
            primaryActionTitle: "Pause",
            isLapEnabled: true,
            isResetEnabled: true
        )
    }

    private static func makePausedState() -> AthleteTileViewState {
        AthleteTileViewState(
            id: UUID(),
            name: "Athlete 1",
            status: .paused,
            elapsedText: "03:18",
            lapCount: 4,
            currentRep: 4,
            totalReps: 8,
            primaryActionTitle: "Resume",
            isLapEnabled: false,
            isResetEnabled: true
        )
    }
}
