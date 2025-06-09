//
//  LogUtils.swift
//  xxf_ios
//  底层用swift-log 比os.Logger 更好,生态更好,比如Pulse
//  Created by xxf on /5/23.
//
import Foundation
import Logging
import Pulse
import PulseLogHandler
import PulseProxy
import XXFExtensions

public class LogUtils {
    public static let config: Config = .init(logInterceptor: { _ in
        false
    })
    
    @usableFromInline
    static let logger = {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.xxf.logger"
        return Logger(label: subsystem)
    }()

    private nonisolated(unsafe) static var isInitialized = false
    /// 初始化 目前有gui 监听,必须最早初始化,而且只能初始化一次
    public static func initialize() {
        guard !isInitialized else { return }
        isInitialized = true
        LoggingSystem.bootstrap { label in
            var streamLogHandler = StreamLogHandler.standardOutput(label: label)
            streamLogHandler.logLevel = .debug // ✅ 设置最低等级为 debug
            var persistentLogHandler = PersistentLogHandler(label: label)
            persistentLogHandler.logLevel = .debug // ✅ 设置最低等级为 debug
            var handlers: [LogHandler] = [persistentLogHandler, // UI 实时查看
                                          streamLogHandler] // 控制台

            // 获取日志目录并确保目录存在
            let logDirectory = getLogDirectoryURL()
            do {
                try FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
                handlers.append(FileLogHandler(
                    label: label,
                    logDirectory: logDirectory,
                    fileExtension: "log",
                    maxFileSizeMB: 10, // 单文件最大10MB
                    maxRetentionDays: 7, // 保留7天日志，自动清理
                    logLevel: .debug, // 记录最低日志级别
                    bufferMaxSize: 16 * 1024, // 缓存16KB才写磁盘
                    flushInterval: 2.0 // 最多2秒写一次
                ))
            } catch {
                // 如果目录创建失败，可以打印或做其他处理
                print("⚠️ Failed to create log directory: \(error)")
            }
            return MultiplexLogHandler(handlers)
        }

        #if DEBUG
            NetworkLogger.enableProxy()
        #endif
    }

    /// 获取日志目录（iOS/macOS 通用）
    /// - Returns: 日志文件夹 URL，未创建目录
    public static func getLogDirectoryURL() -> URL {
        let baseDir = FileManager.default.applicationSupportDirectory()
        return baseDir.appendingPathComponent("Logs", isDirectory: true)
    }

    @inlinable
    static func log(_ message: () -> String,
                    level: LogLevel,
                    tag: String,
                    file: String,
                    function: String,
                    line: Int)
    {
        let rawMessage = "[\(tag)] \(message())"
        let metadata: Logger.Metadata = [
            "file": "\(file)",
            "function": "\(function)",
            "line": "\(line)",
        ]

        switch level {
        case .debug:
            logger.debug("\(rawMessage)", metadata: metadata)
        case .info:
            logger.info("\(rawMessage)", metadata: metadata)
        case .warning:
            logger.warning("\(rawMessage)", metadata: metadata)
        case .error:
            logger.error("\(rawMessage)", metadata: metadata)
        }
    }
}
