//
//  XXFFlow.swift
//  xxf_ios
//
//  Created by xxf on 5/29.
//

@_exported import RxBlocking
@_exported import RxCocoa
@_exported import RxSwift

/**
 import RxSwift

 // 不要自动打印订阅栈（可选）
 Hooks.recordCallStackOnError = false

 // 全局未捕获错误处理器：所有漏写 onError 的错误都会走这里
 Hooks.defaultErrorHandler = { subscriptionCallStack, error in
     // 1) 你可以统一上报日志
     print("🔶 全局捕获未处理的错误：", error)
     // 2) 或者静默吞掉，或给用户弹个吐司
 }
 这样当你在任意一个 Observable/Single/Completable/… 上只调用了 subscribe(onNext:)、drive(onNext:) 而没写 onError 时，RxSwift 不再触发 fatalError 崩溃，而是把错误分发给上面注册的 defaultErrorHandle
 */
import RxSwift
import XXFFoundation

public final class XXFFlow {
    /// 缓存的 Logger
    private static let flowLogger: Logger = {
        let logger = Logger(label: "com.xxf.flow.log")
        return logger
    }()

    private init() {}

    // MARK: 事件流日志

    public typealias LogEventLogger = (_ message: String,
                                       _ logEventTag: LogEventTypeTag,
                                       _ file: String,
                                       _ function: String,
                                       _ line: Int) -> Void

    public nonisolated(unsafe) static var logEventLogger: LogEventLogger = { message, _, file, function, line in
        flowLogger.debug("\(message)", file: file, function: function, line: UInt(line))
    }

    // 提供泛型的默认日志处理闭包工厂
    static func defaultLogEventHandler<Element>() -> LogEventHandler<Element> {
        { logEvent, identifier, trimOutput, file, function, line in
            let id = identifier ?? "\(file):\(line) (\(function))"

            let message: String
            switch logEvent {
            case let .next(element):
                let elementDescription = trimOutput ? "\(element)".truncate(maxLength: 40, truncateAt: .middle) : "\(element)"
                message = "\(logEvent): \(elementDescription)"
            case let .error(error):
                message = "\(logEvent): \(error)"
            default:
                message = "\(logEvent)"
            }

            logEventLogger("\(id) -> \(message)", logEvent.tag, file, function, line)
        }
    }

    // MARK: 事件统计耗时日志

    public typealias LogTimingLogger = (_ totalElapsed: TimeUnit,
                                        _ identifier: String?,
                                        _ warningTimeLimit: TimeUnit,
                                        _ errorTimeLimit: TimeUnit,
                                        _ file: String,
                                        _ function: String,
                                        _ line: Int) -> Void

    public nonisolated(unsafe) static var logTimingLogger: LogTimingLogger = { totalElapsed, identifier, warningTimeLimit, errorTimeLimit, file, function, line in
        let rawMessage = if let identifier = identifier, identifier.isNotEmpty {
            "[\(identifier)]: takeTime: \(totalElapsed.inMilliseconds) ms"
        } else {
            "takeTime: \(totalElapsed.inMilliseconds) ms"
        }
        if totalElapsed < warningTimeLimit {
            flowLogger.debug("\(rawMessage)", file: file, function: function, line: UInt(line))
        } else if totalElapsed < errorTimeLimit {
            flowLogger.warning("\(rawMessage)", file: file, function: function, line: UInt(line))
        } else {
            flowLogger.error("\(rawMessage)", file: file, function: function, line: UInt(line))
        }
    }
}
