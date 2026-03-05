//
//  LRUCache.swift
//  xxf_ios
//
//  高性能 LRU (Least Recently Used) 内存缓存实现
//
//  设计特点:
//  - 线程安全：使用 NSLock 保护所有读写操作
//  - O(1) 复杂度：使用哈希表 + 双向链表实现 O(1) 的增删查改
//  - 内存压力响应：监听系统内存警告，自动清理缓存
//  - 双重淘汰策略：支持按数量限制和按容量限制
//  - 防崩溃设计：参数校验、空值保护、异常捕获
//
//  使用场景:
//  - HTTP 响应缓存
//  - 图片内存缓存
//  - 任意需要 LRU 淘汰策略的场景
//
//  Created by xxf on 6/19.
//

import Foundation

// MARK: - LRUCache

/// 高性能 LRU 内存缓存
///
/// 使用哈希表 + 双向链表实现 O(1) 时间复杂度的缓存操作。
/// 最近访问的元素会被移动到链表尾部，淘汰时从头部移除。
///
/// - Note: 线程安全，可在多线程环境下使用
/// - Warning: Key 必须实现 Hashable 协议
///
/// ## 使用示例
/// ```swift
/// let cache = LRUCache<String, Data>(
///     totalCostLimit: 64 * 1024 * 1024,  // 64MB
///     countLimit: 500
/// )
///
/// cache.setValue(data, forKey: "key", cost: data.count)
/// let cached = cache.value(forKey: "key")
/// ```
public final class LRUCache<Key: Hashable, Value>: @unchecked Sendable {
    // MARK: - Private Properties

    /// 哈希表：O(1) 查找
    private var values: [Key: Container] = [:]

    /// 双向链表头指针（最旧的元素）
    private unowned(unsafe) var head: Container?

    /// 双向链表尾指针（最新的元素）
    private unowned(unsafe) var tail: Container?

    /// 线程安全锁
    private let lock: NSLock = .init()

    /// 内存压力监听源
    private var memoryPressureSource: DispatchSourceMemoryPressure?

    // MARK: - Private Properties (Cost)

    /// 当前缓存总容量（字节）- 内部使用，需要在锁内访问
    private var _totalCost: Int = 0

    /// 最大总容量限制（字节）
    /// - Note: 设置后会立即触发清理检查
    public var totalCostLimit: Int {
        didSet {
            guard totalCostLimit != oldValue, totalCostLimit > 0 else { return }
            clean()
        }
    }

    /// 最大数量限制
    /// - Note: 设置后会立即触发清理检查
    public var countLimit: Int {
        didSet {
            guard countLimit != oldValue, countLimit > 0 else { return }
            clean()
        }
    }

    // MARK: - Initialization

    /// 初始化 LRU 缓存
    /// - Parameters:
    ///   - totalCostLimit: 最大总容量限制（字节），默认无限制
    ///   - countLimit: 最大数量限制，默认无限制
    public init(
        totalCostLimit: Int = .max,
        countLimit: Int = .max
    ) {
        // 参数校验：防止负数
        self.totalCostLimit = max(1, totalCostLimit)
        self.countLimit = max(1, countLimit)
        setupMemoryPressureMonitoring()
    }

    deinit {
        // 取消内存压力监听
        memoryPressureSource?.cancel()
        memoryPressureSource = nil

        // 清理链表引用，防止循环引用
        lock.lock()
        head = nil
        tail = nil
        values.removeAll()
        lock.unlock()
    }

    // MARK: - Memory Pressure Monitoring

    /// 设置内存压力监听
    /// 当系统内存紧张时自动清空缓存
    private func setupMemoryPressureMonitoring() {
        #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            let source = DispatchSource.makeMemoryPressureSource(
                eventMask: [.warning, .critical],
                queue: .main
            )
            source.setEventHandler { [weak self] in
                guard let self = self else { return }
                #if DEBUG
                    print("[LRUCache] Memory pressure detected, clearing cache")
                #endif
                self.removeAllValues()
            }
            source.resume()
            memoryPressureSource = source
        #endif
    }
}

// MARK: - Public Interface

public extension LRUCache {
    /// 当前缓存数量
    /// - Note: 线程安全
    var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return values.count
    }

    /// 缓存是否为空
    /// - Note: 线程安全
    var isEmpty: Bool {
        lock.lock()
        defer { lock.unlock() }
        return values.isEmpty
    }

    /// 获取所有缓存的 key（按访问顺序，最旧到最新）
    /// - Note: 线程安全，返回快照
    var allKeys: [Key] {
        lock.lock()
        defer { lock.unlock() }

        var keys = [Key]()
        keys.reserveCapacity(values.count)

        var current = head
        while let container = current {
            keys.append(container.key)
            current = container.next
        }
        return keys
    }

    /// 获取所有缓存的值（按访问顺序，最旧到最新）
    /// - Note: 线程安全，返回快照
    var allValues: [Value] {
        lock.lock()
        defer { lock.unlock() }

        var result = [Value]()
        result.reserveCapacity(values.count)

        var current = head
        while let container = current {
            result.append(container.value)
            current = container.next
        }
        return result
    }

    /// 设置缓存值
    /// - Parameters:
    ///   - value: 要缓存的值，传 nil 会移除该 key 的缓存
    ///   - key: 缓存键
    ///   - cost: 值的容量（字节），用于容量限制，默认为 0
    /// - Note: 如果 key 已存在会更新值并将其移动到最近访问位置
    func setValue(_ value: Value?, forKey key: Key, cost: Int = 0) {
        // nil 值处理：移除缓存
        guard let value = value else {
            removeValue(forKey: key)
            return
        }

        // 参数校验：cost 不能为负数
        let safeCost = max(0, cost)

        lock.lock()

        if let container = values[key] {
            // 更新已存在的缓存
            container.value = value
            _totalCost -= container.cost
            container.cost = safeCost
            _totalCost += safeCost

            // 移动到最近访问位置
            remove(container)
            append(container)
        } else {
            // 添加新缓存
            let container = Container(value: value, cost: safeCost, key: key)
            values[key] = container
            append(container)
            _totalCost += safeCost
        }

        lock.unlock()

        // 检查是否需要淘汰
        clean()
    }

    /// 移除指定 key 的缓存
    /// - Parameter key: 缓存键
    /// - Returns: 被移除的值，如果不存在返回 nil
    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }

        guard let container = values.removeValue(forKey: key) else {
            return nil
        }

        remove(container)
        _totalCost -= container.cost

        return container.value
    }

    /// 获取缓存值
    /// - Parameter key: 缓存键
    /// - Returns: 缓存的值，如果不存在返回 nil
    /// - Note: 访问后会将该元素移动到最近访问位置
    func value(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }

        guard let container = values[key] else {
            return nil
        }

        // 移动到最近访问位置（LRU 核心逻辑）
        remove(container)
        append(container)

        return container.value
    }

    /// 检查缓存是否包含指定 key
    /// - Parameter key: 缓存键
    /// - Returns: 是否存在
    /// - Note: 不会改变访问顺序
    func contains(key: Key) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return values[key] != nil
    }

    /// 清空所有缓存
    /// - Note: 线程安全
    func removeAllValues() {
        lock.lock()
        values.removeAll()
        head = nil
        tail = nil
        _totalCost = 0
        lock.unlock()
    }

    /// 当前缓存总容量（字节）
    /// - Note: 线程安全
    var totalCost: Int {
        lock.lock()
        defer { lock.unlock() }
        return _totalCost
    }
}

// MARK: - Private Implementation

private extension LRUCache {
    /// 双向链表节点容器
    final class Container {
        var value: Value
        var cost: Int
        let key: Key
        unowned(unsafe) var prev: Container?
        unowned(unsafe) var next: Container?

        init(value: Value, cost: Int, key: Key) {
            self.value = value
            self.cost = max(0, cost)
            self.key = key
        }
    }

    /// 从链表中移除节点
    /// - Parameter container: 要移除的节点
    /// - Note: 必须在持有锁的情况下调用
    func remove(_ container: Container) {
        // 更新前后节点的指针
        container.prev?.next = container.next
        container.next?.prev = container.prev

        // 更新头尾指针
        if head === container {
            head = container.next
        }
        if tail === container {
            tail = container.prev
        }

        // 清理节点指针，防止悬空引用
        container.prev = nil
        container.next = nil
    }

    /// 将节点添加到链表尾部（最近访问位置）
    /// - Parameter container: 要添加的节点
    /// - Note: 必须在持有锁的情况下调用
    func append(_ container: Container) {
        // 断言检查：确保节点未在链表中
        assert(container.next == nil && container.prev == nil || head === container)

        if head == nil {
            // 空链表：同时设置头尾指针
            head = container
            tail = container
        } else {
            // 添加到尾部
            container.prev = tail
            tail?.next = container
            tail = container
        }
    }

    /// 清理超出限制的缓存
    /// - Note: 从链表头部（最旧的元素）开始淘汰
    func clean() {
        lock.lock()
        defer { lock.unlock() }

        // 循环淘汰直到满足限制条件
        while (_totalCost > totalCostLimit || values.count > countLimit),
              let container = head
        {
            // 从链表移除
            remove(container)

            // 从哈希表移除
            values.removeValue(forKey: container.key)

            // 更新容量
            _totalCost -= container.cost
        }
    }
}

// MARK: - Debug Support

#if DEBUG
    public extension LRUCache {
        /// 打印缓存状态（仅 DEBUG 模式）
        func debugPrint() {
            lock.lock()
            defer { lock.unlock() }

            print("[LRUCache] count: \(values.count), totalCost: \(_totalCost)/\(totalCostLimit)")
            print("[LRUCache] countLimit: \(countLimit)")

            var index = 0
            var current = head
            while let container = current {
                print("  [\(index)] key: \(container.key), cost: \(container.cost)")
                current = container.next
                index += 1
            }
        }
    }
#endif
