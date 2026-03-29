import Foundation

struct DashboardViewState: Equatable, Sendable {
    let tiles: [AthleteTileViewState]
    let canAddAthlete: Bool
    let athleteCount: Int
    let maxAthleteCount: Int
}
