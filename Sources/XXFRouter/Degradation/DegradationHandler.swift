//
//  DegradationHandler.swift
//  XXFRouter
//
//  降级处理器，当路由未找到时提供备选方案
//  Created by XXF on 2024
//

import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 降级策略

/// 降级策略枚举
public enum DegradationStrategy: Sendable {
    /// 显示默认页面
    case showDefaultPage

    /// 重定向到指定URL
    case redirect(url: String)

    /// 显示错误提示
    case showError(message: String)

    /// 打开外部浏览器
    case openExternal

    /// 忽略（静默失败）
    case ignore

    /// 自定义处理
    case custom
}

// MARK: - 降级处理器协议

/// 降级处理器协议
///
/// 当路由无法找到匹配的处理器时，将调用降级处理器来处理
/// 可以用于：
/// - 显示404页面
/// - 重定向到首页
/// - 打开外部链接
/// - 显示错误提示
///
/// 使用示例：
/// ```swift
/// class NotFoundDegradationHandler: DegradationHandler {
///     var strategy: DegradationStrategy { .showDefaultPage }
///
///     func handle(context: RouteContext) -> DegradationResult {
///         return .viewController(NotFoundViewController())
///     }
/// }
/// ```
public protocol DegradationHandler: AnyObject, Sendable {
    /// 处理器名称
    var name: String { get }

    /// 优先级，数值越大越先执行
    var priority: Int { get }

    /// 降级策略
    var strategy: DegradationStrategy { get }

    /// 判断是否可以处理该URL
    /// - Parameter context: 路由上下文
    /// - Returns: 是否可以处理
    func canHandle(context: RouteContext) -> Bool

    /// 处理降级
    /// - Parameter context: 路由上下文
    /// - Returns: 降级处理结果
    func handle(context: RouteContext) -> DegradationResult
}

// MARK: - 默认实现

public extension DegradationHandler {
    var name: String { String(describing: type(of: self)) }
    var priority: Int { 0 }
    var strategy: DegradationStrategy { .showDefaultPage }

    func canHandle(context: RouteContext) -> Bool {
        return true
    }
}

// MARK: - 降级处理结果

/// 降级处理结果
public enum DegradationResult: @unchecked Sendable {
    /// 返回一个视图控制器
    case viewController(RouteViewController)

    /// 重定向到另一个URL
    case redirect(url: String)

    /// 已处理（无需进一步操作）
    case handled

    /// 继续尝试其他降级处理器
    case `continue`

    /// 失败，无法处理
    case failure(error: RouteError)
}

// MARK: - 降级处理器管理器

/// 降级处理器管理器
public final class DegradationManager: @unchecked Sendable {
    /// 共享实例
    public static let shared = DegradationManager()

    /// 读写锁
    private let lock = NSRecursiveLock()

    /// 降级处理器列表
    private var handlers: [DegradationHandler] = []

    /// 默认处理器
    private var defaultHandler: DegradationHandler?

    /// 是否已排序
    private var isSorted: Bool = false

    /// 初始化
    public init() {}

    /// 注册降级处理器
    /// - Parameter handler: 降级处理器
    public func register(_ handler: DegradationHandler) {
        lock.lock()
        defer { lock.unlock() }

        handlers.append(handler)
        isSorted = false
    }

    /// 批量注册降级处理器
    /// - Parameter handlers: 降级处理器数组
    public func register(_ handlers: [DegradationHandler]) {
        lock.lock()
        defer { lock.unlock() }

        self.handlers.append(contentsOf: handlers)
        isSorted = false
    }

    /// 设置默认降级处理器
    /// - Parameter handler: 默认处理器
    public func setDefault(_ handler: DegradationHandler) {
        lock.lock()
        defer { lock.unlock() }

        defaultHandler = handler
    }

    /// 移除降级处理器
    /// - Parameter handler: 要移除的处理器
    public func unregister(_ handler: DegradationHandler) {
        lock.lock()
        defer { lock.unlock() }

        handlers.removeAll { $0 === handler }
    }

    /// 清除所有处理器
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        handlers.removeAll()
        defaultHandler = nil
        isSorted = false
    }

    /// 处理降级
    /// - Parameter context: 路由上下文
    /// - Returns: 降级处理结果
    public func handle(context: RouteContext) -> DegradationResult {
        lock.lock()

        if !isSorted {
            handlers.sort { $0.priority > $1.priority }
            isSorted = true
        }

        let sortedHandlers = handlers
        let fallback = defaultHandler
        lock.unlock()

        // 遍历所有处理器
        for handler in sortedHandlers {
            if handler.canHandle(context: context) {
                let result = handler.handle(context: context)

                switch result {
                case .continue:
                    continue
                default:
                    return result
                }
            }
        }

        // 使用默认处理器
        if let defaultHandler = fallback {
            return defaultHandler.handle(context: context)
        }

        // 无法处理
        return .failure(error: .notFound(url: context.url))
    }
}






