//
//  ServiceProvider.swift
//  XXFRouter
//
//  服务提供者协议（SPI机制）
//  类似于DRouter的Service机制，用于模块间的服务发现和调用
//  Created by XXF on 2024
//

import Foundation

// MARK: - 服务协议

/// 服务协议基类，所有服务接口都应该继承此协议
///
/// 使用示例：
/// ```swift
/// // 1. 定义服务接口
/// protocol UserServiceProtocol: ServiceProtocol {
///     func getCurrentUser() -> User?
///     func login(username: String, password: String) -> Bool
/// }
///
/// // 2. 实现服务
/// class UserServiceImpl: UserServiceProtocol {
///     static var serviceName: String { "UserService" }
///     static var serviceAlias: [String] { ["user", "account"] }
///
///     required init() {}
///
///     func getCurrentUser() -> User? { ... }
///     func login(username: String, password: String) -> Bool { ... }
/// }
///
/// // 3. 注册服务
/// ServiceRegistry.shared.register(UserServiceImpl.self, for: UserServiceProtocol.self)
///
/// // 4. 获取服务
/// if let userService: UserServiceProtocol = ServiceRegistry.shared.service() {
///     let user = userService.getCurrentUser()
/// }
/// ```
public protocol ServiceProtocol: AnyObject {
    /// 服务名称，用于日志和调试
    static var serviceName: String { get }

    /// 服务别名，可以通过别名获取服务
    static var serviceAlias: [String] { get }

    /// 服务优先级，当有多个实现时，选择优先级最高的
    static var servicePriority: Int { get }

    /// 是否是单例服务
    static var isSingleton: Bool { get }

    /// 无参数初始化器
    init()
}

// MARK: - 默认实现

public extension ServiceProtocol {
    /// 默认服务名称为类名
    static var serviceName: String { String(describing: Self.self) }

    /// 默认无别名
    static var serviceAlias: [String] { [] }

    /// 默认优先级为0
    static var servicePriority: Int { 0 }

    /// 默认为单例
    static var isSingleton: Bool { true }
}

// MARK: - 服务工厂

/// 服务工厂协议，用于自定义服务创建逻辑
public protocol ServiceFactory: Sendable {
    /// 服务类型标识
    var serviceKey: ObjectIdentifier { get }

    /// 服务名称
    var serviceName: String { get }

    /// 服务别名
    var serviceAlias: [String] { get }

    /// 服务优先级
    var servicePriority: Int { get }

    /// 是否单例
    var isSingleton: Bool { get }

    /// 创建服务实例
    func createInstance() -> Any
}

// MARK: - 类型服务工厂

/// 基于类型的服务工厂实现
final class TypeServiceFactory<T: ServiceProtocol>: ServiceFactory, @unchecked Sendable {
    let serviceKey: ObjectIdentifier
    let serviceName: String
    let serviceAlias: [String]
    let servicePriority: Int
    let isSingleton: Bool

    private let type: T.Type

    init(type: T.Type, key: ObjectIdentifier) {
        self.type = type
        self.serviceKey = key
        self.serviceName = type.serviceName
        self.serviceAlias = type.serviceAlias
        self.servicePriority = type.servicePriority
        self.isSingleton = type.isSingleton
    }

    func createInstance() -> Any {
        return type.init()
    }
}

// MARK: - 闭包服务工厂

/// 基于闭包的服务工厂实现
final class ClosureServiceFactory: ServiceFactory, @unchecked Sendable {
    let serviceKey: ObjectIdentifier
    let serviceName: String
    let serviceAlias: [String]
    let servicePriority: Int
    let isSingleton: Bool

    private let factory: @Sendable () -> Any

    init(
        key: ObjectIdentifier,
        name: String,
        alias: [String] = [],
        priority: Int = 0,
        isSingleton: Bool = true,
        factory: @escaping @Sendable () -> Any
    ) {
        self.serviceKey = key
        self.serviceName = name
        self.serviceAlias = alias
        self.servicePriority = priority
        self.isSingleton = isSingleton
        self.factory = factory
    }

    func createInstance() -> Any {
        return factory()
    }
}

// MARK: - 服务注册表

/// 服务注册表，管理所有注册的服务
public final class ServiceRegistry: @unchecked Sendable {
    /// 共享实例
    public static let shared = ServiceRegistry()

    /// 读写锁
    private let lock = NSRecursiveLock()

    /// 服务工厂映射
    /// Key: 协议/接口的ObjectIdentifier
    private var factories: [ObjectIdentifier: [ServiceFactory]] = [:]

    /// 服务实例缓存（用于单例服务）
    private var instances: [ObjectIdentifier: Any] = [:]

    /// 别名映射
    /// Key: 别名, Value: 协议的ObjectIdentifier
    private var aliasMap: [String: ObjectIdentifier] = [:]

    /// 初始化
    public init() {}

    // MARK: - 注册方法

    /// 注册服务实现
    /// - Parameters:
    ///   - implementation: 服务实现类型
    ///   - protocol: 服务协议类型
    public func register<Implementation: ServiceProtocol, Protocol>(
        _ implementation: Implementation.Type,
        for protocol: Protocol.Type
    ) {
        let key = ObjectIdentifier(`protocol`)
        let factory = TypeServiceFactory(type: implementation, key: key)

        lock.lock()
        defer { lock.unlock() }

        // 添加工厂
        if factories[key] == nil {
            factories[key] = []
        }
        factories[key]?.append(factory)

        // 按优先级排序
        factories[key]?.sort { $0.servicePriority > $1.servicePriority }

        // 注册别名
        for alias in implementation.serviceAlias {
            aliasMap[alias.lowercased()] = key
        }

        // 清除该协议的实例缓存
        instances.removeValue(forKey: key)
    }

    /// 注册闭包工厂
    /// - Parameters:
    ///   - protocol: 服务协议类型
    ///   - name: 服务名称
    ///   - alias: 服务别名
    ///   - priority: 优先级
    ///   - isSingleton: 是否单例
    ///   - factory: 创建服务实例的闭包
    public func register<Protocol>(
        for protocol: Protocol.Type,
        name: String? = nil,
        alias: [String] = [],
        priority: Int = 0,
        isSingleton: Bool = true,
        factory: @escaping @Sendable () -> Protocol
    ) {
        let key = ObjectIdentifier(`protocol`)
        let serviceName = name ?? String(describing: `protocol`)

        let closureFactory = ClosureServiceFactory(
            key: key,
            name: serviceName,
            alias: alias,
            priority: priority,
            isSingleton: isSingleton,
            factory: factory
        )

        lock.lock()
        defer { lock.unlock() }

        if factories[key] == nil {
            factories[key] = []
        }
        factories[key]?.append(closureFactory)
        factories[key]?.sort { $0.servicePriority > $1.servicePriority }

        for a in alias {
            aliasMap[a.lowercased()] = key
        }

        instances.removeValue(forKey: key)
    }

    /// 注册已有实例
    /// - Parameters:
    ///   - instance: 服务实例
    ///   - protocol: 服务协议类型
    ///   - alias: 服务别名
    public func register<Protocol>(
        instance: Protocol,
        for protocol: Protocol.Type,
        alias: [String] = []
    ) {
        let key = ObjectIdentifier(`protocol`)

        lock.lock()
        defer { lock.unlock() }

        instances[key] = instance

        for a in alias {
            aliasMap[a.lowercased()] = key
        }
    }

    // MARK: - 获取服务

    /// 获取服务实例
    /// - Parameter protocol: 服务协议类型
    /// - Returns: 服务实例，如果未注册返回nil
    public func service<Protocol>(for protocol: Protocol.Type = Protocol.self) -> Protocol? {
        let key = ObjectIdentifier(`protocol`)
        return getInstance(for: key) as? Protocol
    }

    /// 通过别名获取服务实例
    /// - Parameter alias: 服务别名
    /// - Returns: 服务实例，如果未找到返回nil
    public func service(alias: String) -> Any? {
        lock.lock()
        let key = aliasMap[alias.lowercased()]
        lock.unlock()

        guard let serviceKey = key else {
            return nil
        }

        return getInstance(for: serviceKey)
    }

    /// 获取所有服务实现
    /// - Parameter protocol: 服务协议类型
    /// - Returns: 所有服务实例数组
    public func allServices<Protocol>(for protocol: Protocol.Type) -> [Protocol] {
        let key = ObjectIdentifier(`protocol`)

        lock.lock()
        defer { lock.unlock() }

        guard let factoryList = factories[key] else {
            return []
        }

        // 为每个工厂创建唯一的缓存 key（使用服务名称作为稳定标识）
        return factoryList.compactMap { factory -> Protocol? in
            if factory.isSingleton {
                // 使用 协议key + 服务名称 作为缓存 key（更稳定，不受排序影响）
                let cacheKey = "\(key)_\(factory.serviceName)"
                if let cached = singletonCache[cacheKey] as? Protocol {
                    return cached
                }
                let instance = factory.createInstance()
                if let service = instance as? Protocol {
                    singletonCache[cacheKey] = service
                    return service
                }
                return nil
            } else {
                return factory.createInstance() as? Protocol
            }
        }
    }

    /// 单例缓存（用于 allServices 方法）
    private var singletonCache: [String: Any] = [:]

    /// 获取实例
    private func getInstance(for key: ObjectIdentifier) -> Any? {
        lock.lock()
        defer { lock.unlock() }

        // 检查缓存
        if let cached = instances[key] {
            return cached
        }

        // 获取优先级最高的工厂
        guard let factory = factories[key]?.first else {
            return nil
        }

        // 创建实例
        let instance = factory.createInstance()

        // 如果是单例，缓存实例
        if factory.isSingleton {
            instances[key] = instance
        }

        return instance
    }

    // MARK: - 查询方法

    /// 检查服务是否已注册
    /// - Parameter protocol: 服务协议类型
    /// - Returns: 是否已注册
    public func isRegistered<Protocol>(for protocol: Protocol.Type) -> Bool {
        let key = ObjectIdentifier(`protocol`)

        lock.lock()
        defer { lock.unlock() }

        return factories[key] != nil && !factories[key]!.isEmpty
    }

    /// 检查别名是否已注册
    /// - Parameter alias: 服务别名
    /// - Returns: 是否已注册
    public func isRegistered(alias: String) -> Bool {
        lock.lock()
        defer { lock.unlock() }

        return aliasMap[alias.lowercased()] != nil
    }

    /// 获取所有已注册的服务名称
    /// - Returns: 服务名称数组
    public func allServiceNames() -> [String] {
        lock.lock()
        defer { lock.unlock() }

        var names: [String] = []
        for factoryList in factories.values {
            for factory in factoryList {
                names.append(factory.serviceName)
            }
        }
        return names
    }

    // MARK: - 移除方法

    /// 移除服务
    /// - Parameter protocol: 服务协议类型
    public func unregister<Protocol>(for protocol: Protocol.Type) {
        let key = ObjectIdentifier(`protocol`)

        lock.lock()
        defer { lock.unlock() }

        // 移除别名
        if let factoryList = factories[key] {
            for factory in factoryList {
                for alias in factory.serviceAlias {
                    aliasMap.removeValue(forKey: alias.lowercased())
                }
            }
        }

        factories.removeValue(forKey: key)
        instances.removeValue(forKey: key)
    }

    /// 清除所有服务
    public func clear() {
        lock.lock()
        defer { lock.unlock() }

        factories.removeAll()
        instances.removeAll()
        singletonCache.removeAll()
        aliasMap.removeAll()
    }

    /// 清除所有实例缓存（保留注册信息）
    public func clearCache() {
        lock.lock()
        defer { lock.unlock() }

        instances.removeAll()
        singletonCache.removeAll()
    }
}

// MARK: - 便捷方法扩展

public extension ServiceRegistry {
    /// 使用下标语法获取服务
    subscript<Protocol>(type: Protocol.Type) -> Protocol? {
        return service(for: type)
    }

    /// 使用下标语法通过别名获取服务
    subscript(alias alias: String) -> Any? {
        return service(alias: alias)
    }
}

// MARK: - 服务注册构建器

/// 服务注册构建器，提供链式API
public final class ServiceRegistryBuilder: @unchecked Sendable {
    private let registry: ServiceRegistry

    init(registry: ServiceRegistry) {
        self.registry = registry
    }

    /// 注册服务实现
    @discardableResult
    public func add<Implementation: ServiceProtocol, Protocol>(
        _ implementation: Implementation.Type,
        for protocol: Protocol.Type
    ) -> Self {
        registry.register(implementation, for: `protocol`)
        return self
    }

    /// 注册闭包工厂
    @discardableResult
    public func add<Protocol>(
        for protocol: Protocol.Type,
        name: String? = nil,
        alias: [String] = [],
        priority: Int = 0,
        isSingleton: Bool = true,
        factory: @escaping @Sendable () -> Protocol
    ) -> Self {
        registry.register(
            for: `protocol`,
            name: name,
            alias: alias,
            priority: priority,
            isSingleton: isSingleton,
            factory: factory
        )
        return self
    }

    /// 注册已有实例
    @discardableResult
    public func add<Protocol>(
        instance: Protocol,
        for protocol: Protocol.Type,
        alias: [String] = []
    ) -> Self {
        registry.register(instance: instance, for: `protocol`, alias: alias)
        return self
    }
}

public extension ServiceRegistry {
    /// 使用构建器注册
    func register(_ builder: (ServiceRegistryBuilder) -> Void) {
        let builderInstance = ServiceRegistryBuilder(registry: self)
        builder(builderInstance)
    }
}
