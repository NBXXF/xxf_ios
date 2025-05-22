import Foundation
import os

enum LogLevel: String {
    case debug = "🐛 DEBUG"
    case info = "ℹ️ INFO"
    case warning = "⚠️ WARNING"
    case error = "❌ ERROR"
}

struct LogUtils {
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.xxf.app"
    private static let category = "general"
    
    private static let logger = Logger(subsystem: subsystem, category: category)

    static func debug(_ message: String) {
        log(level: .debug, message)
    }

    static func info(_ message: String) {
        log(level: .info, message)
    }

    static func warning(_ message: String) {
        log(level: .warning, message)
    }

    static func error(_ message: String) {
        log(level: .error, message)
    }

    private static func log(level: LogLevel, _ message: String) {
        #if DEBUG
        print("[\(level.rawValue)] \(message)")
        #endif
        
        switch level {
        case .debug:
            logger.debug("\(message, privacy: .public)")
        case .info:
            logger.info("\(message, privacy: .public)")
        case .warning:
            logger.warning("\(message, privacy: .public)")
        case .error:
            logger.error("\(message, privacy: .public)")
        }
    }
}
