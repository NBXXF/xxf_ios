//
//  LogUtils.swift
//  xxf_ios
//  底层用swift-log 比os.Logger 更好,生态更好,比如Pulse
//  Created by xxf on 5/23.
//
import Foundation
import Logging
import Pulse
import PulseLogHandler
import PulseProxy
import XXFFoundation

// 全局屏蔽 print
public func print(_: Any..., separator _: String = " ", terminator _: String = "\n") {
    // 不做任何事情，完全屏蔽
}

public enum LogUtils {
    public nonisolated(unsafe) static var config: Config = .init(logInterceptor: { _ in
        false
    })

    @usableFromInline
    static let logger = {
        let subsystem = Bundle.main.bundleIdentifier ?? "com.xxf.logger"
        return Logger(label: subsystem)
    }()

    public static func createFileLogHandler(label: String = "com.xxf.file.logger.handler") -> FileLogHandler {
        // 获取日志目录并确保目录存在
        let logDirectory = getLogDirectoryURL()
        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        return FileLogHandler(
            label: label,
            logDirectory: logDirectory,
            fileExtension: "log",
            maxFileSizeMB: 100, // 单文件最大100MB
            maxRetentionDays: 7, // 保留7天日志，自动清理
            logLevel: .debug, // 记录最低日志级别
            bufferMaxSize: 16 * 1024, // 缓存16KB才写磁盘
            flushInterval: 2.0 // 最多2秒写一次
        )
    }

    private nonisolated(unsafe) static var isInitialized = false

    private nonisolated(unsafe) static let streamLogHandlerCache = ConcurrentDictionary<String, StreamLogHandler>()
    private nonisolated(unsafe) static let persistentLogHandlerCache = ConcurrentDictionary<String, PersistentLogHandler>()
    private nonisolated(unsafe) static let fileLogHandlerCache = ConcurrentDictionary<String, FileLogHandler>()

    /// 初始化 目前有gui 监听,必须最早初始化,而且只能初始化一次
    public static func initialize(enableCacheFile: Bool = false,
                                  enableMemoryCache: Bool = true,
                                  enableCrashCache: Bool = false)
    {
        guard !isInitialized else { return }
        isInitialized = true
        LoggingSystem.bootstrap { label in
            var handlers: [LogHandler] = []

            // 控制台
            let streamLogHandler = streamLogHandlerCache.getOrSet(label, default: StreamLogHandler.standardOutput(label: label).apply { logHandler in
                // 设置最低等级为 debug
                logHandler.logLevel = .debug
            })
            handlers.add(streamLogHandler)

            if enableMemoryCache {
                // Pulse UI 实时查看
                let persistentLogHandler = persistentLogHandlerCache.getOrSet(label, default: PersistentLogHandler(label: label).apply { logHandler in
                    // 设置最低等级为 debug
                    logHandler.logLevel = .debug
                })

                handlers.insert(persistentLogHandler, at: 0)

                // 自动清理内存缓存
                LoggerStore.shared.enableAutoTrim()
            }

            if enableCacheFile {
                let fileLogHandler = fileLogHandlerCache.getOrSet(label, default: createFileLogHandler(label: label).apply { logHandler in
                    // 设置最低等级为 debug
                    logHandler.logLevel = .debug
                })
                handlers.add(fileLogHandler)
            }
            return MultiplexLogHandler(handlers)
        }

        if enableCrashCache {
            // CrashReporterManager.shared.start()
        }

        redirectPrintToPulse()
    }

    private static func redirectPrintToPulse() {
        // 重写print方法
//        Swift.print = { items, separator, terminator in
//            let message = items.map { "\($0)" }.joined(separator: separator)
//            pulseLogger.log(message)
//            // 仍然打印到控制台
//            Swift.print(message, terminator: terminator)
//        }
    }

    /// 获取日志目录（iOS/macOS 通用）
    /// - Returns: 日志文件夹 URL，未创建目录
    public static func getLogDirectoryURL() -> URL {
        let baseDir = FileManager.default.applicationSupportDirectory()
        return baseDir.appendingPathComponent("Logs", isDirectory: true)
    }

    public static func log(_ message: () -> String,
                           level: LogLevel,
                           tag: String,
                           file: String = #fileID,
                           function: String = #function,
                           line: Int = #line)
    {
        // 拦截日志
        if config.logInterceptor(level) {
            return
        }

        /// 获取最后一个文件名
        /// - Parameter file: 原文件
        /// - Returns: 简化文件名
        func trimmedFile(file: String) -> String {
            let trimmedFile: String
            if let lastIndex = file.lastIndex(of: "/") {
                trimmedFile = String(file[file.index(after: lastIndex) ..< file.endIndex])
            } else {
                trimmedFile = file
            }
            return trimmedFile
        }

        let rawMessage = if tag.isNotEmpty {
            "[\(tag)] \(message())"
        } else {
            message()
        }
        let metadata: Logger.Metadata = [
            "file": "\(trimmedFile(file: file))",
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

extension StreamLogHandler: StandardExtensible {}
extension PersistentLogHandler: StandardExtensible {}
extension FileLogHandler: StandardExtensible {}
