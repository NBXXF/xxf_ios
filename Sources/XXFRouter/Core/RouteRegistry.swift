//
//  RouteRegistry.swift
//  XXFRouter
//
//  路由注册表，基于 URLNavigator 的 URLMatcher 实现高效的 URL 匹配
//  Created by XXF on 2024
//

import Foundation
import URLNavigator
import URLMatcher

// MARK: - 路由条目

/// 路由条目，存储路由的元数据
public struct RouteEntry: @unchecked Sendable {
    /// 路由模式
    public let pattern: String

    /// 路由标志位
    public let flags: RouteFlags

    /// 优先级
    public let priority: Int

    /// 路由工厂（用于创建视图控制器）
    public let factory: RouteFactory?

    /// 路由处理器（用于执行特定操作）
    public let handler: RouteHandler?

    /// 是否是工厂路由
    public var isFactory: Bool { factory != nil }

    /// 是否是处理器路由
    public var isHandler: Bool { handler != nil }

    /// 创建工厂路由条目
    public static func factory(_ factory: RouteFactory) -> RouteEntry {
        return RouteEntry(
            pattern: factory.pattern,
            flags: factory.flags,
            priority: factory.priority,
            factory: factory,
            handler: nil
        )
    }

    /// 创建处理器路由条目
    public static func handler(_ handler: RouteHandler) -> RouteEntry {
        return RouteEntry(
            pattern: handler.pattern,
            flags: handler.flags,
            priority: handler.priority,
            factory: nil,
            handler: handler
        )
    }
}

// MARK: - 路由注册表

/// 路由注册表，基于 URLNavigator 的 URLMatcher 实现线程安全的路由管理
///
/// 使用 URLNavigator 的 URLMatcher 作为底层匹配引擎，提供：
/// - 高效的 URL 模式匹配
/// - 支持 `<param>` 和 `:param` 两种参数格式
/// - 经过大量项目验证的稳定性
public final class RouteRegistry: @unchecked Sendable {
    /// 共享实例
    public static let shared = RouteRegistry()

    /// 读写锁，保证线程安全
    private let lock = NSRecursiveLock()

    /// URLNavigator 的 URL 匹配器
    private let urlMatcher = URLMatcher()

    /// 路由条目存储（pattern -> entry）
    private var entries: [String: RouteEntry] = [:]

    /// 按优先级排序的模式列表（用于匹配时按优先级查找）
    private var sortedPatterns: [String] = []

    /// 是否需要重新排序
    private var needsSort: Bool = false

    /// 初始化
    public init() {}

    // MARK: - 注册方法

    /// 注册Routable类型
    /// - Parameter type: 实现了Routable协议的类型
    @MainActor
    public func register<T: Routable>(_ type: T.Type) {
        let factory = TypeRouteFactory(type: type)
        registerFactory(factory)
    }

    /// 注册路由工厂
    /// - Parameter factory: 路由工厂
    public func register(factory: RouteFactory) {
        let entry = RouteEntry(
            pattern: factory.pattern,
            flags: factory.flags,
            priority: factory.priority,
            factory: factory,
            handler: nil
        )
        register(entry: entry)
    }

    /// 内部方法：注册工厂
    private func registerFactory(_ factory: RouteFactory) {
        let entry = RouteEntry(
            pattern: factory.pattern,
            flags: factory.flags,
            priority: factory.priority,
            factory: factory,
            handler: nil
        )
        register(entry: entry)
    }

    /// 注册路由处理器
    /// - Parameter handler: 路由处理器
    public func register(handler: RouteHandler) {
        let entry = RouteEntry.handler(handler)
        register(entry: entry)
    }

    /// 注册闭包工厂
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
    ///   - factory: 创建视图控制器的闭包。
    ///     业务可在此进行参数校验并抛出 RouteError，
    ///     例如 missingRequiredParameter / invalidParameterType / custom
    public func register(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        factory: @escaping @MainActor @Sendable (RouteContext) throws -> RouteViewController
    ) {
        let closureFactory = ClosureRouteFactory(
            pattern: pattern,
            flags: flags,
            priority: priority,
            factory: factory
        )
        registerFactory(closureFactory)
    }

    /// 注册闭包处理器
    /// - Parameters:
    ///   - pattern: 路由模式
    ///   - flags: 路由标志位
    ///   - priority: 优先级
    ///   - handler: 处理闭包
    public func registerHandler(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        handler: @escaping @Sendable (RouteContext) -> Bool
    ) {
        let closureHandler = ClosureRouteHandler(
            pattern: pattern,
            flags: flags,
            priority: priority,
            handler: handler
        )
        register(handler: closureHandler)
    }

    /// 注册路由条目
    /// - Parameter entry: 路由条目
    private func register(entry: RouteEntry) {
        lock.lock()
        defer { lock.unlock() }

        registerEntryUnsafe(entry)
    }

    /// 批量注册路由条目（高效版本，一次锁操作完成所有注册）
    /// - Parameter entries: 路由条目数组
    private func registerEntries(_ entriesToAdd: [RouteEntry]) {
        guard !entriesToAdd.isEmpty else { return }

        lock.lock()
        defer { lock.unlock() }

        for entry in entriesToAdd {
            registerEntryUnsafe(entry)
        }
    }

    /// 内部注册方法（无锁版本，调用前必须持有锁）
    /// - Parameter entry: 路由条目
    private func registerEntryUnsafe(_ entry: RouteEntry) {
        let pattern = entry.pattern

        // 如果已存在相同模式的路由，比较优先级
        if let existing = entries[pattern] {
            if entry.priority > existing.priority {
                entries[pattern] = entry
                needsSort = true
            }
        } else {
            entries[pattern] = entry
            sortedPatterns.append(pattern)
            needsSort = true
        }
    }

    // MARK: - 查询方法

    /// 查找匹配的路由条目
    /// - Parameter url: URL字符串
    /// - Returns: 匹配的路由条目和解析出的参数
    public func find(for url: String) -> (entry: RouteEntry, parameters: RouteParameters)? {
        lock.lock()
        defer { lock.unlock() }

        // 按优先级排序
        if needsSort {
            sortedPatterns.sort { pattern1, pattern2 in
                let priority1 = entries[pattern1]?.priority ?? 0
                let priority2 = entries[pattern2]?.priority ?? 0
                return priority1 > priority2
            }
            needsSort = false
        }

        // 使用 URLMatcher 一次性匹配所有模式（更高效）
        // URLMatcher 会返回第一个匹配的结果
        if let matchResult = urlMatcher.match(url, from: sortedPatterns) {
            // matchResult.pattern 是匹配到的模式
            guard let entry = entries[matchResult.pattern] else {
                return nil
            }

            // 转换参数类型
            var parameters: RouteParameters = [:]
            for (key, value) in matchResult.values {
                parameters[key] = value
            }
            return (entry, parameters)
        }

        return nil
    }

    /// 检查URL是否已注册
    /// - Parameter url: URL字符串
    /// - Returns: 是否已注册
    public func contains(url: String) -> Bool {
        return find(for: url) != nil
    }

    /// 获取所有注册的路由模式
    /// - Returns: 路由模式数组
    public func allPatterns() -> [String] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entries.keys)
    }

    /// 获取所有路由条目
    /// - Returns: 路由条目数组
    public func allEntries() -> [RouteEntry] {
        lock.lock()
        defer { lock.unlock() }
        return Array(entries.values)
    }

    // MARK: - 移除方法

    /// 移除指定模式的路由
    /// - Parameter pattern: 路由模式
    /// - Returns: 被移除的路由条目
    @discardableResult
    public func unregister(pattern: String) -> RouteEntry? {
        lock.lock()
        defer { lock.unlock() }

        let removed = entries.removeValue(forKey: pattern)
        if removed != nil {
            sortedPatterns.removeAll { $0 == pattern }
        }
        return removed
    }

    /// 清除所有注册的路由
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        entries.removeAll()
        sortedPatterns.removeAll()
        needsSort = false
    }
}

// MARK: - 便捷注册扩展

public extension RouteRegistry {
    /// 批量注册 Routable 类型（高效版本，一次锁操作完成所有注册）
    /// - Parameter types: Routable 类型数组
    ///
    /// 使用示例：
    /// ```swift
    /// registry.register([
    ///     HomeViewController.self,
    ///     ProfileViewController.self,
    ///     SettingsViewController.self
    /// ])
    /// ```
    @MainActor
    func register(_ types: [any Routable.Type]) {
        guard !types.isEmpty else { return }

        // 由于 Swift 类型系统限制，需要先收集所有 entries 再批量注册
        // 使用 RouteEntry 的 factory 初始化方式
        var entriesToAdd: [RouteEntry] = []
        entriesToAdd.reserveCapacity(types.count)

        for type in types {
            // 通过协议方法创建工厂
            let factory = AnyRoutableFactory(type: type)
            entriesToAdd.append(.factory(factory))
        }

        registerEntries(entriesToAdd)
    }

    /// 批量注册闭包工厂（高效版本，一次锁操作完成所有注册）
    /// - Parameter factories: 工厂配置数组
    ///
    /// 使用示例：
    /// ```swift
    /// registry.register(factories: [
    ///     (pattern: "app://home", flags: .none, priority: 0, factory: { _ in HomeVC() }),
    ///     (pattern: "app://profile/<userId>", flags: .requiresLogin, priority: 0, factory: { ctx in
    ///         ProfileVC(userId: ctx.string(for: "userId") ?? "")
    ///     })
    /// ])
    /// ```
    @MainActor
    func register(
        factories: [RouteFactoryConfig]
    ) {
        guard !factories.isEmpty else { return }

        let entries = factories.map { config -> RouteEntry in
            let factory = ClosureRouteFactory(
                pattern: config.pattern,
                flags: config.flags,
                priority: config.priority,
                factory: config.factory
            )
            return .factory(factory)
        }
        registerEntries(entries)
    }

    /// 批量注册处理器（高效版本，一次锁操作完成所有注册）
    /// - Parameter handlers: 处理器配置数组
    ///
    /// 使用示例：
    /// ```swift
    /// registry.register(handlers: [
    ///     RouteHandlerConfig(pattern: "app://logout") { _ in
    ///         AuthService.shared.logout()
    ///         return true
    ///     }
    /// ])
    /// ```
    func register(
        handlers: [RouteHandlerConfig]
    ) {
        guard !handlers.isEmpty else { return }

        let entries = handlers.map { config -> RouteEntry in
            let handler = ClosureRouteHandler(
                pattern: config.pattern,
                flags: config.flags,
                priority: config.priority,
                handler: config.handler
            )
            return .handler(handler)
        }
        registerEntries(entries)
    }

    /// 使用构建器注册
    /// - Parameter builder: 注册构建器闭包
    @MainActor
    func register(_ builder: (RouteRegistryBuilder) -> Void) {
        let builderInstance = RouteRegistryBuilder(registry: self)
        builder(builderInstance)
    }
}

// MARK: - 路由注册构建器

/// 路由注册构建器，提供链式API
@MainActor
public final class RouteRegistryBuilder: @unchecked Sendable {
    private let registry: RouteRegistry

    init(registry: RouteRegistry) {
        self.registry = registry
    }

    /// 注册Routable类型
    @discardableResult
    public func add<T: Routable>(_ type: T.Type) -> Self {
        registry.register(type)
        return self
    }

    /// 注册闭包工厂
    /// - Note: 业务可在 factory 中进行参数校验并抛出 RouteError，
    ///   例如 missingRequiredParameter / invalidParameterType / custom
    @discardableResult
    public func add(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        factory: @escaping @MainActor @Sendable (RouteContext) throws -> RouteViewController
    ) -> Self {
        registry.register(
            pattern: pattern,
            flags: flags,
            priority: priority,
            factory: factory
        )
        return self
    }

    /// 注册闭包处理器
    @discardableResult
    public func addHandler(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        handler: @escaping @Sendable (RouteContext) -> Bool
    ) -> Self {
        registry.registerHandler(
            pattern: pattern,
            flags: flags,
            priority: priority,
            handler: handler
        )
        return self
    }
}
