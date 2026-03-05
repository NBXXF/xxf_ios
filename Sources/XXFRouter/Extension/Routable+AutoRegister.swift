//
//  Routable+AutoRegister.swift
//  XXFRouter
//
//  路由自动注册扩展
//  Created by XXF on 2024
//

import Foundation

// MARK: - 路由模块协议

/// 路由模块协议，用于组织和管理路由注册
///
/// 使用示例：
/// ```swift
/// struct UserModule: RouteModule {
///     static func register(to router: Router) {
///         router.register(ProfileViewController.self)
///         router.register(SettingsViewController.self)
///         router.registerInterceptor(LoginInterceptor())
///     }
/// }
///
/// // 在App启动时注册模块
/// Router.shared.registerModule(UserModule.self)
/// ```
public protocol RouteModule {
    /// 注册路由到路由器
    /// - Parameter router: 路由器实例
    static func register(to router: Router)
}

// MARK: - 路由器模块注册扩展

public extension Router {
    /// 注册路由模块
    /// - Parameter module: 路由模块类型
    func registerModule(_ module: RouteModule.Type) {
        module.register(to: self)
    }

    /// 批量注册路由模块
    /// - Parameter modules: 路由模块类型数组
    func registerModules(_ modules: [RouteModule.Type]) {
        for module in modules {
            registerModule(module)
        }
    }
}

// MARK: - 路由分组

/// 路由分组，用于组织相关的路由
@MainActor
public final class RouteGroup: @unchecked Sendable {
    /// 分组名称
    public let name: String

    /// 路由前缀
    public let prefix: String

    /// 共享标志位
    public let sharedFlags: RouteFlags

    /// 路由器引用
    private weak var router: Router?

    /// 创建路由分组
    /// - Parameters:
    ///   - name: 分组名称
    ///   - prefix: 路由前缀
    ///   - sharedFlags: 共享标志位
    ///   - router: 路由器
    public init(
        name: String,
        prefix: String = "",
        sharedFlags: RouteFlags = .none,
        router: Router
    ) {
        self.name = name
        self.prefix = prefix
        self.sharedFlags = sharedFlags
        self.router = router
    }

    /// 注册Routable类型
    /// - Parameter type: Routable类型
    public func register<T: Routable>(_ type: T.Type) {
        router?.register(type)
    }

    /// 注册闭包工厂
    /// - Parameters:
    ///   - pattern: 路由模式（会自动添加前缀）
    ///   - flags: 额外标志位
    ///   - priority: 优先级
    ///   - factory: 创建视图控制器的闭包
    public func register(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        factory: @escaping @MainActor @Sendable (RouteContext) -> RouteViewController?
    ) {
        let fullPattern = prefix.isEmpty ? pattern : "\(prefix)/\(pattern)"
        let combinedFlags = sharedFlags.union(flags)

        router?.register(
            pattern: fullPattern,
            flags: combinedFlags,
            priority: priority,
            factory: factory
        )
    }

    /// 注册处理器
    /// - Parameters:
    ///   - pattern: 路由模式（会自动添加前缀）
    ///   - flags: 额外标志位
    ///   - priority: 优先级
    ///   - handler: 处理闭包
    public func registerHandler(
        pattern: String,
        flags: RouteFlags = .none,
        priority: Int = 0,
        handler: @escaping @Sendable (RouteContext) -> Bool
    ) {
        let fullPattern = prefix.isEmpty ? pattern : "\(prefix)/\(pattern)"
        let combinedFlags = sharedFlags.union(flags)

        router?.registerHandler(
            pattern: fullPattern,
            flags: combinedFlags,
            priority: priority,
            handler: handler
        )
    }
}

// MARK: - 路由器分组扩展

public extension Router {
    /// 创建路由分组
    /// - Parameters:
    ///   - name: 分组名称
    ///   - prefix: 路由前缀
    ///   - sharedFlags: 共享标志位
    /// - Returns: 路由分组
    func group(
        name: String,
        prefix: String = "",
        sharedFlags: RouteFlags = .none
    ) -> RouteGroup {
        return RouteGroup(
            name: name,
            prefix: prefix,
            sharedFlags: sharedFlags,
            router: self
        )
    }

    /// 使用分组注册路由
    /// - Parameters:
    ///   - name: 分组名称
    ///   - prefix: 路由前缀
    ///   - sharedFlags: 共享标志位
    ///   - builder: 分组构建闭包
    func group(
        name: String,
        prefix: String = "",
        sharedFlags: RouteFlags = .none,
        builder: (RouteGroup) -> Void
    ) {
        let group = RouteGroup(
            name: name,
            prefix: prefix,
            sharedFlags: sharedFlags,
            router: self
        )
        builder(group)
    }
}

// MARK: - 路由表

/// 路由表，用于查看所有已注册的路由
public struct RouteTable: Sendable {
    /// 路由条目
    public struct Entry: Sendable {
        public let pattern: String
        public let flags: RouteFlags
        public let priority: Int
        public let type: RouteEntryType
    }

    /// 路由条目类型
    public enum RouteEntryType: String, Sendable {
        case factory = "Factory"
        case handler = "Handler"
    }

    /// 所有路由条目
    public let entries: [Entry]

    /// 创建路由表
    /// - Parameter router: 路由器
    public init(router: Router) {
        let routeEntries = router.registry.allEntries()

        self.entries = routeEntries.map { entry in
            Entry(
                pattern: entry.pattern,
                flags: entry.flags,
                priority: entry.priority,
                type: entry.isFactory ? .factory : .handler
            )
        }
    }

    /// 打印路由表
    public func printTable() {
        print("┌────────────────────────────────────────────────────────────────┐")
        print("│                         Route Table                           │")
        print("├────────────────────────────────────────────────────────────────┤")
        print("│ Pattern                              │ Flags    │ Pri │ Type  │")
        print("├────────────────────────────────────────────────────────────────┤")

        for entry in entries {
            let pattern = entry.pattern.padding(toLength: 36, withPad: " ", startingAt: 0)
            let flags = String(entry.flags.rawValue).padding(toLength: 8, withPad: " ", startingAt: 0)
            let priority = String(entry.priority).padding(toLength: 3, withPad: " ", startingAt: 0)
            let type = entry.type.rawValue.padding(toLength: 7, withPad: " ", startingAt: 0)

            print("│ \(pattern) │ \(flags) │ \(priority) │ \(type)│")
        }

        print("└────────────────────────────────────────────────────────────────┘")
        print("Total: \(entries.count) routes")
    }
}

public extension Router {
    /// 获取路由表
    var routeTable: RouteTable {
        return RouteTable(router: self)
    }

    /// 打印路由表（用于调试）
    func printRouteTable() {
        routeTable.printTable()
    }
}
