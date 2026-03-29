import Foundation

struct AthleteTileViewState: Equatable, Sendable {
    let name: String
    let status: AthleteTileStatus
    let elapsedText: String
    let lapCount: Int
    let currentRep: Int
    let totalReps: Int
    let primaryActionTitle: String
    let isLapEnabled: Bool
    let isResetEnabled: Bool
}
