import Foundation

protocol LogFileWriter {
    func write(
        level: LogLevel,
        message: String,
        metadata: [String: String],
        timestamp: Date
    ) throws
}
