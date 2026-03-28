import Foundation

enum LogLevel: String, Codable, Sendable {
    case debug
    case info
    case warning
    case error
}

protocol AppLogger {
    func log(
        level: LogLevel,
        message: String,
        metadata: [String: String],
        file: StaticString,
        function: StaticString,
        line: UInt
    )
}
