//
//  RouteResult.swift
//  XXFRouter
//
//  路由结果和回调机制
//  Created by XXF on 2024
//

import Foundation

// MARK: - 路由结果

/// 路由执行结果
public enum RouteResult: @unchecked Sendable {
    /// 成功导航到视图控制器
    case success(viewController: RouteViewController)

    /// 成功执行处理器
    case handled

    /// 被拦截
    case intercepted(reason: String)

    /// 被重定向
    case redirected(to: String)

    /// 降级处理
    case degraded(viewController: RouteViewController?)

    /// 失败
    case failure(error: RouteError)

    /// 是否成功
    public var isSuccess: Bool {
        switch self {
        case .success, .handled:
            return true
        default:
            return false
        }
    }

    /// 是否失败
    public var isFailure: Bool {
        switch self {
        case .failure:
            return true
        default:
            return false
        }
    }

    /// 获取视图控制器（如果有）
    public var viewController: RouteViewController? {
        switch self {
        case .success(let vc):
            return vc
        case .degraded(let vc):
            return vc
        default:
            return nil
        }
    }

    /// 获取错误（如果有）
    public var error: RouteError? {
        switch self {
        case .failure(let error):
            return error
        default:
            return nil
        }
    }
}

// MARK: - 路由回调协议

/// 路由回调协议，用于接收路由执行结果
public protocol RouteCallback: AnyObject, Sendable {
    /// 路由开始执行
    /// - Parameter context: 路由上下文
    func onRouteStart(context: RouteContext)

    /// 路由被拦截
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - reason: 拦截原因
    func onRouteIntercepted(context: RouteContext, reason: String)

    /// 路由未找到
    /// - Parameter context: 路由上下文
    func onRouteNotFound(context: RouteContext)

    /// 路由成功
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - viewController: 目标视图控制器
    func onRouteSuccess(context: RouteContext, viewController: RouteViewController?)

    /// 路由失败
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - error: 错误信息
    func onRouteFailure(context: RouteContext, error: RouteError)

    /// 路由完成（无论成功或失败）
    /// - Parameters:
    ///   - context: 路由上下文
    ///   - result: 路由结果
    func onRouteComplete(context: RouteContext, result: RouteResult)
}

// MARK: - 默认实现

public extension RouteCallback {
    func onRouteStart(context: RouteContext) {}
    func onRouteIntercepted(context: RouteContext, reason: String) {}
    func onRouteNotFound(context: RouteContext) {}
    func onRouteSuccess(context: RouteContext, viewController: RouteViewController?) {}
    func onRouteFailure(context: RouteContext, error: RouteError) {}
    func onRouteComplete(context: RouteContext, result: RouteResult) {}
}

// MARK: - 路由监听器

/// 全局路由监听器，用于监控所有路由事件
public protocol RouteListener: AnyObject, Sendable {
    /// 监听器名称
    var name: String { get }

    /// 优先级
    var priority: Int { get }

    /// 路由事件发生时调用
    /// - Parameters:
    ///   - event: 路由事件
    ///   - context: 路由上下文
    func onEvent(_ event: RouteEvent, context: RouteContext)
}

public extension RouteListener {
    var name: String { String(describing: type(of: self)) }
    var priority: Int { 0 }
}

// MARK: - 路由事件

/// 路由事件枚举
public enum RouteEvent: Sendable {
    /// 路由开始
    case start

    /// 拦截器开始执行
    case interceptorStart(name: String)

    /// 拦截器执行完成
    case interceptorComplete(name: String, result: InterceptorResult)

    /// 被拦截
    case intercepted(reason: String)

    /// 路由未找到
    case notFound

    /// 视图控制器创建成功
    case viewControllerCreated(RouteViewController)

    /// 导航开始
    case navigationStart

    /// 导航完成
    case navigationComplete

    /// 处理器执行
    case handlerExecuted(success: Bool)

    /// 降级处理
    case degraded

    /// 路由成功
    case success

    /// 路由失败
    case failure(RouteError)
}

// MARK: - 路由监听管理器

/// 路由监听管理器
public final class RouteListenerManager: @unchecked Sendable {
    /// 共享实例
    public static let shared = RouteListenerManager()

    /// 读写锁
    private let lock = NSRecursiveLock()

    /// 监听器列表
    private var listeners: [RouteListener] = []

    /// 是否已排序
    private var isSorted: Bool = false

    /// 初始化
    public init() {}

    /// 添加监听器
    /// - Parameter listener: 监听器
    public func addListener(_ listener: RouteListener) {
        lock.lock()
        defer { lock.unlock() }

        listeners.append(listener)
        isSorted = false
    }

    /// 移除监听器
    /// - Parameter listener: 监听器
    public func removeListener(_ listener: RouteListener) {
        lock.lock()
        defer { lock.unlock() }

        listeners.removeAll { $0 === listener }
    }

    /// 清除所有监听器
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        listeners.removeAll()
        isSorted = false
    }

    /// 通知所有监听器
    /// - Parameters:
    ///   - event: 路由事件
    ///   - context: 路由上下文
    public func notify(event: RouteEvent, context: RouteContext) {
        lock.lock()

        if !isSorted {
            listeners.sort { $0.priority > $1.priority }
            isSorted = true
        }

        let sortedListeners = listeners
        lock.unlock()

        for listener in sortedListeners {
            listener.onEvent(event, context: context)
        }
    }
}

// MARK: - 闭包回调

/// 基于闭包的路由回调
public final class ClosureRouteCallback: RouteCallback, @unchecked Sendable {
    private let onStart: (@Sendable (RouteContext) -> Void)?
    private let onIntercepted: (@Sendable (RouteContext, String) -> Void)?
    private let onNotFound: (@Sendable (RouteContext) -> Void)?
    private let onSuccess: (@Sendable (RouteContext, RouteViewController?) -> Void)?
    private let onFailure: (@Sendable (RouteContext, RouteError) -> Void)?
    private let onComplete: (@Sendable (RouteContext, RouteResult) -> Void)?

    /// 创建闭包回调
    public init(
        onStart: (@Sendable (RouteContext) -> Void)? = nil,
        onIntercepted: (@Sendable (RouteContext, String) -> Void)? = nil,
        onNotFound: (@Sendable (RouteContext) -> Void)? = nil,
        onSuccess: (@Sendable (RouteContext, RouteViewController?) -> Void)? = nil,
        onFailure: (@Sendable (RouteContext, RouteError) -> Void)? = nil,
        onComplete: (@Sendable (RouteContext, RouteResult) -> Void)? = nil
    ) {
        self.onStart = onStart
        self.onIntercepted = onIntercepted
        self.onNotFound = onNotFound
        self.onSuccess = onSuccess
        self.onFailure = onFailure
        self.onComplete = onComplete
    }

    public func onRouteStart(context: RouteContext) {
        onStart?(context)
    }

    public func onRouteIntercepted(context: RouteContext, reason: String) {
        onIntercepted?(context, reason)
    }

    public func onRouteNotFound(context: RouteContext) {
        onNotFound?(context)
    }

    public func onRouteSuccess(context: RouteContext, viewController: RouteViewController?) {
        onSuccess?(context, viewController)
    }

    public func onRouteFailure(context: RouteContext, error: RouteError) {
        onFailure?(context, error)
    }

    public func onRouteComplete(context: RouteContext, result: RouteResult) {
        onComplete?(context, result)
    }
}

// MARK: - 日志监听器

/// 日志路由监听器，用于调试
public final class LoggingRouteListener: RouteListener, @unchecked Sendable {
    public let name = "LoggingRouteListener"
    public let priority: Int

    private let logHandler: @Sendable (String) -> Void

    /// 创建日志监听器
    /// - Parameters:
    ///   - priority: 优先级
    ///   - logHandler: 日志处理闭包
    public init(
        priority: Int = 0,
        logHandler: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.priority = priority
        self.logHandler = logHandler
    }

    public func onEvent(_ event: RouteEvent, context: RouteContext) {
        let message: String

        switch event {
        case .start:
            message = "[Router] Start routing: \(context.url)"
        case .interceptorStart(let name):
            message = "[Router] Interceptor start: \(name)"
        case .interceptorComplete(let name, let result):
            message = "[Router] Interceptor complete: \(name), result: \(result)"
        case .intercepted(let reason):
            message = "[Router] Intercepted: \(reason)"
        case .notFound:
            message = "[Router] Route not found: \(context.url)"
        case .viewControllerCreated(let vc):
            message = "[Router] ViewController created: \(type(of: vc))"
        case .navigationStart:
            message = "[Router] Navigation start"
        case .navigationComplete:
            message = "[Router] Navigation complete"
        case .handlerExecuted(let success):
            message = "[Router] Handler executed, success: \(success)"
        case .degraded:
            message = "[Router] Degraded: \(context.url)"
        case .success:
            message = "[Router] Success: \(context.url)"
        case .failure(let error):
            message = "[Router] Failure: \(error)"
        }

        logHandler(message)
    }
}
