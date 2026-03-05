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

// MARK: - 内置降级处理器

/// URL降级处理器，处理特定URL模式的降级
public final class URLPatternDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name: String
    public let priority: Int
    public let strategy: DegradationStrategy

    private let pattern: String
    private let handler: @Sendable (RouteContext) -> DegradationResult

    /// 创建URL模式降级处理器
    /// - Parameters:
    ///   - pattern: URL模式（支持正则表达式）
    ///   - name: 处理器名称
    ///   - priority: 优先级
    ///   - strategy: 降级策略
    ///   - handler: 处理闭包
    public init(
        pattern: String,
        name: String = "URLPatternDegradationHandler",
        priority: Int = 0,
        strategy: DegradationStrategy = .custom,
        handler: @escaping @Sendable (RouteContext) -> DegradationResult
    ) {
        self.pattern = pattern
        self.name = name
        self.priority = priority
        self.strategy = strategy
        self.handler = handler
    }

    public func canHandle(context: RouteContext) -> Bool {
        // 尝试正则匹配
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            let range = NSRange(context.url.startIndex..., in: context.url)
            return regex.firstMatch(in: context.url, options: [], range: range) != nil
        }

        // 简单字符串包含检查
        return context.url.lowercased().contains(pattern.lowercased())
    }

    public func handle(context: RouteContext) -> DegradationResult {
        return handler(context)
    }
}

/// HTTP/HTTPS 外部链接降级处理器
public final class ExternalLinkDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "ExternalLinkDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy = .openExternal

    /// 创建外部链接降级处理器
    /// - Parameter priority: 优先级
    public init(priority: Int = 100) {
        self.priority = priority
    }

    public func canHandle(context: RouteContext) -> Bool {
        let url = context.url.lowercased()
        return url.hasPrefix("http://") || url.hasPrefix("https://")
    }

    public func handle(context: RouteContext) -> DegradationResult {
        #if canImport(UIKit)
        if let url = URL(string: context.url) {
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
            return .handled
        }
        #elseif canImport(AppKit)
        if let url = URL(string: context.url) {
            NSWorkspace.shared.open(url)
            return .handled
        }
        #endif
        return .failure(error: .invalidURL(url: context.url))
    }
}

/// 默认404页面降级处理器
public final class NotFoundDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "NotFoundDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy = .showDefaultPage

    private let pageFactory: @Sendable (RouteContext) -> RouteViewController

    /// 创建默认404降级处理器
    /// - Parameters:
    ///   - priority: 优先级
    ///   - pageFactory: 创建404页面的工厂闭包
    public init(
        priority: Int = -1000, // 最低优先级
        pageFactory: @escaping @Sendable (RouteContext) -> RouteViewController
    ) {
        self.priority = priority
        self.pageFactory = pageFactory
    }

    public func canHandle(context: RouteContext) -> Bool {
        return true
    }

    public func handle(context: RouteContext) -> DegradationResult {
        let viewController = pageFactory(context)
        return .viewController(viewController)
    }
}

/// 重定向降级处理器
public final class RedirectDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "RedirectDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy

    private let targetURL: String
    private let condition: (@Sendable (RouteContext) -> Bool)?

    /// 创建重定向降级处理器
    /// - Parameters:
    ///   - targetURL: 重定向目标URL
    ///   - priority: 优先级
    ///   - condition: 触发条件（可选）
    public init(
        targetURL: String,
        priority: Int = 0,
        condition: (@Sendable (RouteContext) -> Bool)? = nil
    ) {
        self.targetURL = targetURL
        self.priority = priority
        self.strategy = .redirect(url: targetURL)
        self.condition = condition
    }

    public func canHandle(context: RouteContext) -> Bool {
        if let condition = condition {
            return condition(context)
        }
        return true
    }

    public func handle(context: RouteContext) -> DegradationResult {
        return .redirect(url: targetURL)
    }
}
