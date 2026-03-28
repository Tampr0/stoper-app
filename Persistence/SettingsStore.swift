import Foundation

struct AppSettings: Codable, Equatable, Sendable {
    var preferredTimerMode: TimerMode

    init(preferredTimerMode: TimerMode = .manual) {
        self.preferredTimerMode = preferredTimerMode
    }
}

protocol SettingsStore {
    func loadSettings() throws -> AppSettings
    func saveSettings(_ settings: AppSettings) throws
}
