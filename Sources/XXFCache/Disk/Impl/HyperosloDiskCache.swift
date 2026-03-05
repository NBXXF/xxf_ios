//
//  HyperosloDiskCache.swift
//  xxf_ios
//
//  基于 hyperoslo/Cache 库的磁盘缓存实现
//
//  设计特点:
//  - 线程安全：使用 NSLock 保护所有磁盘操作
//  - 自动过期：支持自定义过期时间，自动清理过期缓存
//  - 容量限制：支持最大缓存大小限制
//  - 数据保护：使用 FileProtectionType.complete 保护缓存文件
//  - 错误容忍：优雅处理各种磁盘 IO 错误
//  - Codable 支持：支持任意 Codable 类型的存储
//
//  依赖:
//  - hyperoslo/Cache 库
//
//  Created by xxf on 2025/3/5.
//

import Cache
import Foundation

// MARK: - 磁盘缓存错误类型

/// 磁盘缓存错误
public enum DiskCacheError: Error, LocalizedError, Sendable {
    /// key 为空
    case emptyKey
    /// 存储初始化失败
    case storageInitializationFailed(underlying: Error)
    /// 读取失败
    case readFailed(key: String, underlying: Error)
    /// 写入失败
    case writeFailed(key: String, underlying: Error)
    /// 删除失败
    case deleteFailed(key: String, underlying: Error)
    /// 数据损坏
    case dataCorrupted(key: String)

    public var errorDescription: String? {
        switch self {
        case .emptyKey:
            return "Cache key cannot be empty"
        case let .storageInitializationFailed(error):
            return "Failed to initialize disk storage: \(error.localizedDescription)"
        case let .readFailed(key, error):
            return "Failed to read cache for key '\(key)': \(error.localizedDescription)"
        case let .writeFailed(key, error):
            return "Failed to write cache for key '\(key)': \(error.localizedDescription)"
        case let .deleteFailed(key, error):
            return "Failed to delete cache for key '\(key)': \(error.localizedDescription)"
        case let .dataCorrupted(key):
            return "Cache data corrupted for key '\(key)'"
        }
    }
}

// MARK: - HyperosloDiskCache

/// 基于 hyperoslo/Cache 的磁盘缓存实现
///
/// 提供高性能、线程安全的磁盘缓存功能，支持自动过期和容量限制。
///
/// ## 使用示例
/// ```swift
/// struct User: Codable {
///     let id: Int
///     let name: String
/// }
///
/// let cache = try HyperosloDiskCache<User>(
///     config: DiskCacheConfig(
///         name: "UserCache",
///         defaultExpiry: 3600,  // 1小时过期
///         maxSize: 50 * 1024 * 1024  // 50MB
///     )
/// )
///
/// // 存储
/// try cache.set(user, forKey: "user_123")
///
/// // 读取
/// if let cachedUser = try cache.get(forKey: "user_123") {
///     print(cachedUser.name)
/// }
/// ```
public final class HyperosloDiskCache<Value: Codable & Sendable>: DiskCache, @unchecked Sendable {
    // MARK: - Properties

    /// 缓存名称
    public let name: String

    /// 缓存配置
    private let config: DiskCacheConfig

    /// 底层存储引擎
    private let storage: DiskStorage<String, Value>

    /// 线程安全锁
    private let lock = NSLock()

    /// 缓存是否已被释放
    private var isInvalidated = false

    // MARK: - Initialization

    /// 使用配置初始化磁盘缓存
    /// - Parameter config: 缓存配置
    /// - Throws: 初始化失败时抛出 DiskCacheError.storageInitializationFailed
    public init(config: DiskCacheConfig) throws {
        self.name = config.name
        self.config = config

        // 构建 hyperoslo/Cache 的配置
        let diskConfig = DiskConfig(
            name: config.name,
            expiry: .seconds(config.defaultExpiry),
            maxSize: config.maxSize > 0 ? UInt(config.maxSize) : 0,
            directory: config.directory,
            protectionType: .complete
        )

        do {
            self.storage = try DiskStorage<String, Value>(
                config: diskConfig,
                transformer: TransformerFactory.forCodable(ofType: Value.self)
            )
        } catch {
            throw DiskCacheError.storageInitializationFailed(underlying: error)
        }
    }

    deinit {
        lock.lock()
        isInvalidated = true
        lock.unlock()
    }

    // MARK: - DiskCache Protocol

    /// 存储对象到磁盘
    /// - Parameters:
    ///   - value: 要缓存的对象
    ///   - key: 缓存键（不能为空）
    ///   - expiry: 过期时间（秒），nil 使用默认过期时间
    /// - Throws: DiskCacheError
    public func set(_ value: Value, forKey key: String, expiry: TimeInterval?) throws {
        // 参数校验
        guard !key.isEmpty else {
            throw DiskCacheError.emptyKey
        }

        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return }

        do {
            if let expiry = expiry, expiry > 0 {
                try storage.setObject(value, forKey: key, expiry: .seconds(expiry))
            } else {
                try storage.setObject(value, forKey: key)
            }
        } catch {
            throw DiskCacheError.writeFailed(key: key, underlying: error)
        }
    }

    /// 从磁盘获取对象
    /// - Parameter key: 缓存键（不能为空）
    /// - Returns: 缓存的对象，不存在或已过期返回 nil
    /// - Throws: DiskCacheError
    public func get(forKey key: String) throws -> Value? {
        // 参数校验
        guard !key.isEmpty else {
            throw DiskCacheError.emptyKey
        }

        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return nil }

        do {
            return try storage.object(forKey: key)
        } catch StorageError.notFound {
            // 缓存不存在或已过期，正常返回 nil
            return nil
        } catch StorageError.malformedFileAttributes {
            // 文件属性损坏，尝试删除并返回 nil
            try? storage.removeObject(forKey: key)
            return nil
        } catch {
            // 其他错误（如数据解码失败），记录但不抛出
            #if DEBUG
                print("[HyperosloDiskCache] Read error for key '\(key)': \(error)")
            #endif
            // 尝试删除损坏的缓存
            try? storage.removeObject(forKey: key)
            return nil
        }
    }

    /// 从磁盘删除对象
    /// - Parameter key: 缓存键（不能为空）
    /// - Throws: DiskCacheError
    public func remove(forKey key: String) throws {
        // 参数校验
        guard !key.isEmpty else {
            throw DiskCacheError.emptyKey
        }

        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return }

        do {
            try storage.removeObject(forKey: key)
        } catch StorageError.notFound {
            // key 不存在，静默忽略
        } catch {
            throw DiskCacheError.deleteFailed(key: key, underlying: error)
        }
    }

    /// 删除所有缓存
    /// - Throws: DiskCacheError
    public func removeAll() throws {
        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return }

        do {
            try storage.removeAll()
        } catch {
            #if DEBUG
                print("[HyperosloDiskCache] Failed to remove all: \(error)")
            #endif
            // 即使失败也不抛出，避免影响业务
        }
    }

    /// 删除所有过期对象
    /// - Throws: DiskCacheError
    public func removeExpired() throws {
        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return }

        do {
            try storage.removeExpiredObjects()
        } catch {
            #if DEBUG
                print("[HyperosloDiskCache] Failed to remove expired: \(error)")
            #endif
            // 清理过期缓存失败不应影响业务
        }
    }

    /// 检查缓存是否存在且未过期
    /// - Parameter key: 缓存键（不能为空）
    /// - Returns: 是否存在
    /// - Throws: DiskCacheError
    public func exists(forKey key: String) throws -> Bool {
        // 参数校验
        guard !key.isEmpty else {
            throw DiskCacheError.emptyKey
        }

        lock.lock()
        defer { lock.unlock() }

        // 检查是否已被释放
        guard !isInvalidated else { return false }

        do {
            return try storage.existsObject(forKey: key)
        } catch {
            // 检查存在性失败时返回 false
            return false
        }
    }

    /// 当前缓存总大小（字节）
    public var totalSize: UInt64 {
        lock.lock()
        defer { lock.unlock() }

        guard !isInvalidated else { return 0 }

        return UInt64(storage.totalSize ?? 0)
    }
}

// MARK: - 便捷工厂方法

public extension HyperosloDiskCache {
    /// 创建默认配置的磁盘缓存
    /// - Parameter name: 缓存名称
    /// - Returns: 磁盘缓存实例
    /// - Throws: 初始化失败
    static func create(name: String) throws -> HyperosloDiskCache<Value> {
        try HyperosloDiskCache(config: DiskCacheConfig(name: name))
    }

    /// 创建指定过期时间的磁盘缓存
    /// - Parameters:
    ///   - name: 缓存名称
    ///   - expiry: 默认过期时间（秒）
    /// - Returns: 磁盘缓存实例
    /// - Throws: 初始化失败
    static func create(name: String, expiry: TimeInterval) throws -> HyperosloDiskCache<Value> {
        try HyperosloDiskCache(config: DiskCacheConfig(name: name, defaultExpiry: expiry))
    }

    /// 创建完整配置的磁盘缓存
    /// - Parameters:
    ///   - name: 缓存名称
    ///   - expiry: 默认过期时间（秒）
    ///   - maxSize: 最大缓存大小（字节）
    /// - Returns: 磁盘缓存实例
    /// - Throws: 初始化失败
    static func create(
        name: String,
        expiry: TimeInterval,
        maxSize: UInt64
    ) throws -> HyperosloDiskCache<Value> {
        try HyperosloDiskCache(config: DiskCacheConfig(
            name: name,
            defaultExpiry: expiry,
            maxSize: maxSize
        ))
    }
}

// MARK: - 批量操作扩展

public extension HyperosloDiskCache {
    /// 批量获取缓存
    /// - Parameter keys: 缓存键列表
    /// - Returns: 存在的缓存字典 [key: value]
    func getAll(forKeys keys: [String]) -> [String: Value] {
        var result = [String: Value]()
        result.reserveCapacity(keys.count)

        for key in keys {
            if let value = try? get(forKey: key) {
                result[key] = value
            }
        }

        return result
    }

    /// 批量删除缓存
    /// - Parameter keys: 缓存键列表
    func removeAll(forKeys keys: [String]) {
        for key in keys {
            try? remove(forKey: key)
        }
    }
}

// MARK: - Debug Support

#if DEBUG
    public extension HyperosloDiskCache {
        /// 打印缓存状态（仅 DEBUG 模式）
        func debugPrint() {
            lock.lock()
            let invalidated = isInvalidated
            let size = invalidated ? 0 : UInt64(storage.totalSize ?? 0)
            lock.unlock()

            print("[HyperosloDiskCache] name: \(name)")
            print("[HyperosloDiskCache] totalSize: \(size) bytes")
            print("[HyperosloDiskCache] maxSize: \(config.maxSize) bytes")
            print("[HyperosloDiskCache] defaultExpiry: \(config.defaultExpiry) seconds")
            print("[HyperosloDiskCache] isInvalidated: \(invalidated)")
        }
    }
#endif
