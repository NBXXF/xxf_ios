//
//  HttpCache.swift
//  xxf_ios
//
//  HTTP 双层缓存管理器
//
//  架构设计:
//  ┌─────────────────────────────────────────────────────────┐
//  │                    HttpCache                            │
//  │  ┌─────────────────────────────────────────────────┐   │
//  │  │              Memory Layer (L1)                   │   │
//  │  │    LRUCache: O(1) 访问，App 生命周期有效         │   │
//  │  └─────────────────────────────────────────────────┘   │
//  │                        ↓ miss                          │
//  │  ┌─────────────────────────────────────────────────┐   │
//  │  │               Disk Layer (L2)                    │   │
//  │  │  HyperosloDiskCache: 持久化存储，支持过期时间    │   │
//  │  └─────────────────────────────────────────────────┘   │
//  └─────────────────────────────────────────────────────────┘
//
//  特性:
//  - 双层缓存：内存快速访问 + 磁盘持久化
//  - 线程安全：所有操作都是线程安全的
//  - 异步初始化：磁盘缓存异步初始化，不阻塞主线程
//  - 优雅降级：磁盘缓存失败时降级为纯内存缓存
//  - 自动回填：磁盘命中时自动回填内存缓存
//  - 容错设计：异常情况下不会崩溃
//
//  Created by xxf on 2025/3/4.
//

import Foundation
import Moya
import XXFCache

// MARK: - 缓存条目

/// 内存缓存条目
///
/// 封装 Response 和缓存时间，用于内存层缓存。
/// 使用 `@unchecked Sendable` 是因为 Response 内部是不可变的。
public struct CacheEntry: @unchecked Sendable {
    /// 缓存的响应对象
    public let response: Response

    /// 缓存时间
    public let cachedAt: Date

    /// 创建缓存条目
    /// - Parameters:
    ///   - response: 响应对象
    ///   - cachedAt: 缓存时间，默认为当前时间
    public init(response: Response, cachedAt: Date = Date()) {
        self.response = response
        self.cachedAt = cachedAt
    }

    /// 检查缓存是否在有效期内
    /// - Parameter maxAge: 最大有效期（秒），.infinity 表示永不过期
    /// - Returns: 缓存是否有效
    public func isValid(maxAge: TimeInterval) -> Bool {
        // 无限过期时间，永远有效
        guard maxAge.isFinite, maxAge > 0 else { return maxAge == .infinity }
        return Date().timeIntervalSince(cachedAt) < maxAge
    }
}

/// 磁盘缓存条目（可序列化）
///
/// 用于磁盘层缓存，支持 Codable 序列化。
/// 只存储必要的数据，减少磁盘占用。
public struct DiskCacheEntry: Codable, Sendable {
    /// 响应数据
    public let data: Data

    /// HTTP 状态码
    public let statusCode: Int

    /// 缓存时间
    public let cachedAt: Date

    /// 从 Response 创建磁盘缓存条目
    /// - Parameters:
    ///   - response: 响应对象
    ///   - cachedAt: 缓存时间，默认为当前时间
    public init(response: Response, cachedAt: Date = Date()) {
        self.data = response.data
        self.statusCode = response.statusCode
        self.cachedAt = cachedAt
    }

    /// 检查缓存是否在有效期内
    /// - Parameter maxAge: 最大有效期（秒），.infinity 表示永不过期
    /// - Returns: 缓存是否有效
    public func isValid(maxAge: TimeInterval) -> Bool {
        guard maxAge.isFinite, maxAge > 0 else { return maxAge == .infinity }
        return Date().timeIntervalSince(cachedAt) < maxAge
    }

    /// 转换为 Moya Response
    /// - Returns: 不带 URLResponse 的 Response 对象
    public func toResponse() -> Response {
        Response(statusCode: statusCode, data: data)
    }

    /// 转换为内存缓存条目
    /// - Returns: CacheEntry 对象
    public func toCacheEntry() -> CacheEntry {
        CacheEntry(response: toResponse(), cachedAt: cachedAt)
    }
}

// MARK: - 缓存配置

/// HTTP 缓存配置
///
/// 用于配置 HttpCache 的各项参数。
/// 提供合理的默认值，大多数情况下直接使用 `.default` 即可。
public struct HttpCacheConfig: Sendable {
    /// 内存缓存最大数量
    public let memoryCountLimit: Int

    /// 内存缓存最大容量（字节）
    public let memoryCostLimit: Int

    /// 磁盘缓存名称
    public let diskCacheName: String

    /// 磁盘缓存默认过期时间（秒）
    public let diskDefaultExpiry: TimeInterval

    /// 磁盘缓存最大容量（字节）
    public let diskMaxSize: UInt64

    /// 是否启用磁盘缓存
    public let diskCacheEnabled: Bool

    /// 默认配置
    /// - 内存：512 条目，64MB 容量
    /// - 磁盘：3天过期，256MB 容量
    public static let `default` = HttpCacheConfig()

    /// 轻量级配置（适用于内存敏感场景）
    public static let lightweight = HttpCacheConfig(
        memoryCountLimit: 100,
        memoryCostLimit: 16 * 1024 * 1024,
        diskMaxSize: 64 * 1024 * 1024
    )

    /// 创建缓存配置
    /// - Parameters:
    ///   - memoryCountLimit: 内存缓存最大数量，默认 512
    ///   - memoryCostLimit: 内存缓存最大容量（字节），默认 64MB
    ///   - diskCacheName: 磁盘缓存名称，默认 "HttpCache"
    ///   - diskDefaultExpiry: 磁盘缓存默认过期时间（秒），默认 3天
    ///   - diskMaxSize: 磁盘缓存最大容量（字节），默认 256MB
    ///   - diskCacheEnabled: 是否启用磁盘缓存，默认 true
    public init(
        memoryCountLimit: Int = 512,
        memoryCostLimit: Int = 64 * 1024 * 1024,
        diskCacheName: String = "HttpCache",
        diskDefaultExpiry: TimeInterval = 3 * 24 * 60 * 60,
        diskMaxSize: UInt64 = 256 * 1024 * 1024,
        diskCacheEnabled: Bool = true
    ) {
        // 参数校验：确保所有值都是合理的
        self.memoryCountLimit = max(1, memoryCountLimit)
        self.memoryCostLimit = max(1024, memoryCostLimit)  // 至少 1KB
        self.diskCacheName = diskCacheName.isEmpty ? "HttpCache" : diskCacheName
        self.diskDefaultExpiry = max(60, diskDefaultExpiry)  // 至少 1分钟
        self.diskMaxSize = max(1024 * 1024, diskMaxSize)  // 至少 1MB
        self.diskCacheEnabled = diskCacheEnabled
    }
}

// MARK: - HTTP 缓存管理器

/// HTTP 双层缓存管理器
///
/// 提供高性能的 HTTP 响应缓存，支持内存和磁盘双层缓存。
///
/// ## 使用示例
/// ```swift
/// let cache = HttpCache.shared
///
/// // 写入缓存
/// cache.forceSet(response, forKey: "api_user_info", maxAge: 3600)
///
/// // 读取缓存
/// if let cached = cache.get(forKey: "api_user_info", maxAge: 3600) {
///     // 使用缓存的响应
/// }
///
/// // 清理
/// cache.removeAll()
/// ```
///
/// ## 线程安全
/// 所有公开方法都是线程安全的，可以在任意线程调用。
///
/// ## 缓存策略
/// 1. 读取：先查内存，miss 后查磁盘，命中后回填内存
/// 2. 写入：同步写内存，异步写磁盘
/// 3. 过期：内存基于 maxAge 判断，磁盘有独立过期机制
public final class HttpCache: @unchecked Sendable {
    // MARK: - Singleton

    /// 全局共享实例
    public static let shared = HttpCache()

    // MARK: - Properties

    /// 缓存配置
    private let config: HttpCacheConfig

    /// 内存缓存层（L1）
    private let memoryCache: LRUCache<String, CacheEntry>

    /// 磁盘缓存层（L2）
    private var diskCache: HyperosloDiskCache<DiskCacheEntry>?

    /// 磁盘操作队列
    private let diskQueue: DispatchQueue

    /// 线程安全锁（保护 diskCache 引用）
    private let lock = NSLock()

    /// 磁盘缓存初始化状态
    private var diskCacheInitialized = false

    /// 磁盘缓存初始化等待队列
    private var pendingDiskOperations: [() -> Void] = []

    // MARK: - Initialization

    /// 使用默认配置初始化
    public convenience init() {
        self.init(config: .default)
    }

    /// 使用自定义配置初始化
    /// - Parameter config: 缓存配置
    public init(config: HttpCacheConfig) {
        self.config = config

        // 初始化内存缓存
        self.memoryCache = LRUCache(
            totalCostLimit: config.memoryCostLimit,
            countLimit: config.memoryCountLimit
        )

        // 创建磁盘操作队列
        self.diskQueue = DispatchQueue(
            label: "com.xxf.httpcache.disk",
            qos: .utility
        )

        // 异步初始化磁盘缓存
        if config.diskCacheEnabled {
            diskQueue.async { [weak self] in
                self?.initializeDiskCache()
            }
        } else {
            lock.lock()
            diskCacheInitialized = true
            lock.unlock()
        }
    }

    /// 兼容旧版初始化方法
    /// - Parameters:
    ///   - countLimit: 内存缓存数量限制
    ///   - totalCostLimit: 内存缓存容量限制（字节）
    @available(*, deprecated, message: "Use init(config:) instead")
    public convenience init(countLimit: Int, totalCostLimit: Int) {
        self.init(config: HttpCacheConfig(
            memoryCountLimit: countLimit,
            memoryCostLimit: totalCostLimit
        ))
    }

    // MARK: - Private Initialization

    /// 初始化磁盘缓存
    private func initializeDiskCache() {
        do {
            let diskConfig = DiskCacheConfig(
                name: config.diskCacheName,
                defaultExpiry: config.diskDefaultExpiry,
                maxSize: config.diskMaxSize
            )
            let cache = try HyperosloDiskCache<DiskCacheEntry>(config: diskConfig)

            lock.lock()
            self.diskCache = cache
            self.diskCacheInitialized = true

            // 执行等待中的操作
            let pending = pendingDiskOperations
            pendingDiskOperations.removeAll()
            lock.unlock()

            // 在队列中执行等待的操作
            for operation in pending {
                operation()
            }

            #if DEBUG
                print("[HttpCache] Disk cache initialized successfully")
            #endif
        } catch {
            lock.lock()
            self.diskCacheInitialized = true  // 标记为已初始化（失败）
            pendingDiskOperations.removeAll()
            lock.unlock()

            #if DEBUG
                print("[HttpCache] Disk cache initialization failed: \(error)")
            #endif
        }
    }

    // MARK: - Read Operations

    /// 只从内存缓存读取（同步，非常快）
    ///
    /// 该方法只查询内存层缓存，不会访问磁盘。适用于需要快速检查缓存的场景。
    ///
    /// - Parameters:
    ///   - key: 缓存键
    ///   - maxAge: 最大有效期（秒），默认永不过期
    /// - Returns: 缓存的响应，内存中不存在或已过期返回 nil
    public func getFromMemory(forKey key: String, maxAge: TimeInterval = .infinity) -> Response? {
        guard !key.isEmpty else { return nil }

        if let entry = memoryCache.value(forKey: key) {
            if entry.isValid(maxAge: maxAge) {
                return entry.response
            } else {
                // 过期，移除内存缓存
                memoryCache.removeValue(forKey: key)
                // 异步移除磁盘缓存
                removeDiskCacheAsync(forKey: key)
            }
        }
        return nil
    }

    /// 同步读取缓存
    ///
    /// - Warning: 如果内存缓存未命中，会同步读取磁盘，可能阻塞当前线程。
    ///   对于 UI 线程敏感的场景，建议使用异步版本 `get(forKey:maxAge:completion:)`
    ///
    /// - Parameters:
    ///   - key: 缓存键
    ///   - maxAge: 最大有效期（秒），默认永不过期
    /// - Returns: 缓存的响应，不存在或已过期返回 nil
    public func get(forKey key: String, maxAge: TimeInterval = .infinity) -> Response? {
        // 参数校验
        guard !key.isEmpty else { return nil }

        #if DEBUG
            // 在主线程上同步读取磁盘可能导致卡顿
            if Thread.isMainThread, memoryCache.contains(key: key) == false {
                print("[HttpCache] Warning: Synchronous disk read on main thread for key '\(key)'")
            }
        #endif

        // 1. 先查内存缓存
        if let entry = memoryCache.value(forKey: key) {
            if entry.isValid(maxAge: maxAge) {
                return entry.response
            } else {
                // 过期，移除
                memoryCache.removeValue(forKey: key)
                removeDiskCacheAsync(forKey: key)
            }
        }

        // 2. 再查磁盘缓存（同步）
        guard let diskEntry = getDiskCacheSync(forKey: key) else {
            return nil
        }

        // 3. 检查磁盘缓存是否过期
        guard diskEntry.isValid(maxAge: maxAge) else {
            removeDiskCacheAsync(forKey: key)
            return nil
        }

        // 4. 回填内存缓存
        let cacheEntry = diskEntry.toCacheEntry()
        memoryCache.setValue(cacheEntry, forKey: key, cost: diskEntry.data.count)

        return diskEntry.toResponse()
    }

    /// 异步读取缓存
    /// - Parameters:
    ///   - key: 缓存键
    ///   - maxAge: 最大有效期（秒），默认永不过期
    ///   - completion: 完成回调（可能在任意线程）
    public func get(
        forKey key: String,
        maxAge: TimeInterval = .infinity,
        completion: @escaping @Sendable (Response?) -> Void
    ) {
        // 参数校验
        guard !key.isEmpty else {
            completion(nil)
            return
        }

        // 1. 先同步查内存
        if let entry = memoryCache.value(forKey: key) {
            if entry.isValid(maxAge: maxAge) {
                completion(entry.response)
                return
            } else {
                memoryCache.removeValue(forKey: key)
            }
        }

        // 2. 异步查磁盘
        executeDiskOperation { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard let diskEntry = self.getDiskCacheSync(forKey: key) else {
                completion(nil)
                return
            }

            // 检查过期
            guard diskEntry.isValid(maxAge: maxAge) else {
                self.removeDiskCacheAsync(forKey: key)
                completion(nil)
                return
            }

            // 回填内存
            let cacheEntry = diskEntry.toCacheEntry()
            self.memoryCache.setValue(cacheEntry, forKey: key, cost: diskEntry.data.count)

            completion(diskEntry.toResponse())
        }
    }

    /// 检查缓存是否存在且有效
    /// - Parameters:
    ///   - key: 缓存键
    ///   - maxAge: 最大有效期（秒），默认永不过期
    /// - Returns: 缓存是否存在且有效
    public func contains(forKey key: String, maxAge: TimeInterval = .infinity) -> Bool {
        get(forKey: key, maxAge: maxAge) != nil
    }

    // MARK: - Write Operations

    /// 写入缓存（通过拦截器判断是否缓存）
    /// - Parameters:
    ///   - response: 响应对象
    ///   - key: 缓存键
    ///   - maxAge: 过期时间（秒）
    ///   - interceptor: 缓存拦截器
    public func set(
        _ response: Response,
        forKey key: String,
        maxAge: TimeInterval = CacheType.defaultMaxAge,
        interceptor: any CacheInterceptor
    ) {
        // 拦截器判断
        guard !interceptor.shouldSkipCache(response) else { return }
        forceSet(response, forKey: key, maxAge: maxAge)
    }

    /// 强制写入缓存（不经过拦截器）
    /// - Parameters:
    ///   - response: 响应对象
    ///   - key: 缓存键
    ///   - maxAge: 过期时间（秒）
    public func forceSet(
        _ response: Response,
        forKey key: String,
        maxAge: TimeInterval = CacheType.defaultMaxAge
    ) {
        // 参数校验
        guard !key.isEmpty else { return }

        // 空数据不缓存
        guard !response.data.isEmpty else { return }

        let now = Date()
        let cost = response.data.count

        // 1. 同步写入内存缓存
        let memoryEntry = CacheEntry(response: response, cachedAt: now)
        memoryCache.setValue(memoryEntry, forKey: key, cost: cost)

        // 2. 异步写入磁盘缓存
        let diskEntry = DiskCacheEntry(response: response, cachedAt: now)
        setDiskCacheAsync(diskEntry, forKey: key, maxAge: maxAge)
    }

    // MARK: - Delete Operations

    /// 移除指定缓存
    /// - Parameter key: 缓存键
    /// - Returns: 被移除的响应（如果存在）
    @discardableResult
    public func remove(forKey key: String) -> Response? {
        guard !key.isEmpty else { return nil }

        let response = memoryCache.removeValue(forKey: key)?.response
        removeDiskCacheAsync(forKey: key)
        return response
    }

    /// 清空所有缓存
    public func removeAll() {
        memoryCache.removeAllValues()
        removeAllDiskCacheAsync()
    }

    /// 清理过期缓存
    public func removeExpired() {
        executeDiskOperation { [weak self] in
            try? self?.diskCache?.removeExpired()
        }
    }

    // MARK: - Statistics

    /// 当前内存缓存数量
    public var count: Int { memoryCache.count }

    /// 当前内存缓存总大小（字节）
    public var totalCost: Int { memoryCache.totalCost }

    /// 当前磁盘缓存大小（字节）
    public var diskSize: UInt64 {
        lock.lock()
        let cache = diskCache
        lock.unlock()
        return cache?.totalSize ?? 0
    }

    /// 磁盘缓存是否可用
    public var isDiskCacheAvailable: Bool {
        lock.lock()
        let available = diskCache != nil
        lock.unlock()
        return available
    }

    /// 磁盘缓存是否已初始化完成
    public var isDiskCacheReady: Bool {
        lock.lock()
        defer { lock.unlock() }
        return diskCacheInitialized
    }

    /// 快速异步读取缓存（磁盘未就绪时立即返回 nil）
    ///
    /// 与 `get(forKey:maxAge:completion:)` 的区别：
    /// - 如果磁盘缓存未就绪，立即回调 nil，不等待初始化
    /// - 适用于需要快速响应的场景（如 firstCache 模式）
    ///
    /// - Parameters:
    ///   - key: 缓存键
    ///   - maxAge: 最大有效期（秒），默认永不过期
    ///   - completion: 完成回调（可能在任意线程）
    public func getFast(
        forKey key: String,
        maxAge: TimeInterval = .infinity,
        completion: @escaping @Sendable (Response?) -> Void
    ) {
        // 参数校验
        guard !key.isEmpty else {
            completion(nil)
            return
        }

        // 1. 先同步查内存
        if let entry = memoryCache.value(forKey: key) {
            if entry.isValid(maxAge: maxAge) {
                completion(entry.response)
                return
            } else {
                memoryCache.removeValue(forKey: key)
            }
        }

        // 2. 检查磁盘缓存是否就绪
        lock.lock()
        let isReady = diskCacheInitialized
        let cache = diskCache
        lock.unlock()

        // 磁盘未就绪，立即返回 nil（不等待）
        guard isReady, cache != nil else {
            completion(nil)
            return
        }

        // 3. 磁盘已就绪，异步查磁盘
        diskQueue.async { [weak self] in
            guard let self = self else {
                completion(nil)
                return
            }

            guard let diskEntry = self.getDiskCacheSync(forKey: key) else {
                completion(nil)
                return
            }

            // 检查过期
            guard diskEntry.isValid(maxAge: maxAge) else {
                self.removeDiskCacheAsync(forKey: key)
                completion(nil)
                return
            }

            // 回填内存
            let cacheEntry = diskEntry.toCacheEntry()
            self.memoryCache.setValue(cacheEntry, forKey: key, cost: diskEntry.data.count)

            completion(diskEntry.toResponse())
        }
    }

    // MARK: - Private Disk Operations

    /// 同步读取磁盘缓存
    private func getDiskCacheSync(forKey key: String) -> DiskCacheEntry? {
        lock.lock()
        let cache = diskCache
        lock.unlock()

        guard let cache = cache else { return nil }

        do {
            return try cache.get(forKey: key)
        } catch {
            #if DEBUG
                print("[HttpCache] Disk read error for key '\(key)': \(error)")
            #endif
            return nil
        }
    }

    /// 异步写入磁盘缓存
    private func setDiskCacheAsync(_ entry: DiskCacheEntry, forKey key: String, maxAge: TimeInterval) {
        executeDiskOperation { [weak self] in
            guard let self = self else { return }

            self.lock.lock()
            let cache = self.diskCache
            self.lock.unlock()

            guard let cache = cache else { return }

            do {
                try cache.set(entry, forKey: key, expiry: maxAge)
            } catch {
                #if DEBUG
                    print("[HttpCache] Disk write error for key '\(key)': \(error)")
                #endif
            }
        }
    }

    /// 异步删除磁盘缓存
    private func removeDiskCacheAsync(forKey key: String) {
        executeDiskOperation { [weak self] in
            guard let self = self else { return }

            self.lock.lock()
            let cache = self.diskCache
            self.lock.unlock()

            try? cache?.remove(forKey: key)
        }
    }

    /// 异步清空磁盘缓存
    private func removeAllDiskCacheAsync() {
        executeDiskOperation { [weak self] in
            guard let self = self else { return }

            self.lock.lock()
            let cache = self.diskCache
            self.lock.unlock()

            try? cache?.removeAll()
        }
    }

    /// 执行磁盘操作（处理初始化等待）
    private func executeDiskOperation(_ operation: @escaping @Sendable () -> Void) {
        lock.lock()
        if diskCacheInitialized {
            lock.unlock()
            diskQueue.async(execute: operation)
        } else {
            // 磁盘缓存还未初始化，加入等待队列
            pendingDiskOperations.append(operation)
            lock.unlock()
        }
    }
}

// MARK: - 预热 & 维护

public extension HttpCache {
    /// 预热缓存：将磁盘缓存预加载到内存
    /// - Parameters:
    ///   - keys: 需要预热的 key 列表
    ///   - maxAge: 最大有效期，默认永不过期
    func warmup(keys: [String], maxAge: TimeInterval = .infinity) {
        guard !keys.isEmpty else { return }

        executeDiskOperation { [weak self] in
            guard let self = self else { return }

            for key in keys {
                guard !key.isEmpty else { continue }

                if let diskEntry = self.getDiskCacheSync(forKey: key),
                   diskEntry.isValid(maxAge: maxAge)
                {
                    let cacheEntry = diskEntry.toCacheEntry()
                    self.memoryCache.setValue(cacheEntry, forKey: key, cost: diskEntry.data.count)
                }
            }

            #if DEBUG
                print("[HttpCache] Warmup completed for \(keys.count) keys")
            #endif
        }
    }

    /// 执行缓存维护（清理过期缓存）
    func performMaintenance() {
        removeExpired()
    }

    /// 获取缓存统计信息
    func getStatistics() -> CacheStatistics {
        CacheStatistics(
            memoryCount: count,
            memoryCost: totalCost,
            diskSize: diskSize,
            isDiskAvailable: isDiskCacheAvailable
        )
    }
}

// MARK: - 缓存统计

/// 缓存统计信息
public struct CacheStatistics: Sendable {
    /// 内存缓存数量
    public let memoryCount: Int

    /// 内存缓存大小（字节）
    public let memoryCost: Int

    /// 磁盘缓存大小（字节）
    public let diskSize: UInt64

    /// 磁盘缓存是否可用
    public let isDiskAvailable: Bool

    /// 总缓存大小（字节）
    public var totalSize: UInt64 {
        UInt64(memoryCost) + diskSize
    }
}

// MARK: - Debug Support

#if DEBUG
    public extension HttpCache {
        /// 打印缓存状态
        func debugPrint() {
            let stats = getStatistics()
            print("[HttpCache] Memory: \(stats.memoryCount) items, \(stats.memoryCost) bytes")
            print("[HttpCache] Disk: \(stats.diskSize) bytes, available: \(stats.isDiskAvailable)")
            print("[HttpCache] Total: \(stats.totalSize) bytes")
        }
    }
#endif
