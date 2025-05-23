//
//  LogUtils.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/23.
//
import Foundation
import os

public class LogUtils {
    public static let config: Config = .init(logInterceptor: { _ in
        false
    })

    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.xxf.app"
    private static let category = "general"

    private static let logger = Logger(subsystem: subsystem, category: category)

    public static func debug(_ message: () -> String) {
        if config.logInterceptor(.debug) == true {
            return
        }
        log(level: .debug, message())
    }

    public static func info(_ message: () -> String) {
        if config.logInterceptor(.info) == true {
            return
        }
        log(level: .info, message())
    }

    public static func warning(_ message: () -> String) {
        if config.logInterceptor(.warning) == true {
            return
        }
        log(level: .warning, message())
    }

    public static func error(_ message: () -> String) {
        if config.logInterceptor(.error) == true {
            return
        }
        log(level: .error, message())
    }

    static func log(_ message: () -> String,
                    level: LogLevel,
                    tag: String,
                    file: String,
                    function: String,
                    line: Int)
    {
        if config.logInterceptor(level) == true {
            return
        }
        log(level: level, "[\(tag)] [\(file):\(line) \(function)] \(message())")
    }

    private static func log(level: LogLevel, _ message: String) {
        #if DEBUG
            print("[\(level.description)] \(message)")
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
