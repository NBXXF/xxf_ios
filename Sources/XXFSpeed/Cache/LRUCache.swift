//
//  LRUCache.swift
//  xxf_ios
//  内存缓存LRU
//  Created by trl on 6/19.
//

import Foundation

public final class LRUCache<Key: Hashable, Value> {
    private var values: [Key: Container] = [:]
    private unowned(unsafe) var head: Container?
    private unowned(unsafe) var tail: Container?
    private let lock: NSLock = .init()
    private var memoryPressureSource: DispatchSourceMemoryPressure?

    /// The current total cost of values in the cache
    public private(set) var totalCost: Int = 0

    /// The maximum total cost permitted
    public var totalCostLimit: Int {
        didSet { clean() }
    }

    /// The maximum number of values permitted
    public var countLimit: Int {
        didSet { clean() }
    }

    /// Initialize the cache with optional `totalCostLimit` and `countLimit`
    public init(
        totalCostLimit: Int = .max,
        countLimit: Int = .max
    ) {
        self.totalCostLimit = totalCostLimit
        self.countLimit = countLimit
        setupMemoryPressureMonitoring()
    }

    deinit {
        memoryPressureSource?.cancel()
    }

    private func setupMemoryPressureMonitoring() {
        #if os(iOS) || os(macOS) || os(tvOS) || os(visionOS)
            let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
            source.setEventHandler { [weak self] in
                self?.removeAllValues()
            }
            source.resume()
            memoryPressureSource = source
        #endif
    }
}

public extension LRUCache {
    var count: Int {
        values.count
    }

    var isEmpty: Bool {
        values.isEmpty
    }

    var allKeys: [Key] {
        lock.lock()
        defer { lock.unlock() }
        var keys = [Key]()
        var next = head
        while let container = next {
            keys.append(container.key)
            next = container.next
        }
        return keys
    }

    var allValues: [Value] {
        lock.lock()
        defer { lock.unlock() }
        var result = [Value]()
        var next = head
        while let container = next {
            result.append(container.value)
            next = container.next
        }
        return result
    }

    func setValue(_ value: Value?, forKey key: Key, cost: Int = 0) {
        guard let value = value else {
            removeValue(forKey: key)
            return
        }

        lock.lock()
        if let container = values[key] {
            container.value = value
            totalCost -= container.cost
            container.cost = cost
            remove(container)
            append(container)
        } else {
            let container = Container(value: value, cost: cost, key: key)
            values[key] = container
            append(container)
        }
        totalCost += cost
        lock.unlock()
        clean()
    }

    @discardableResult
    func removeValue(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        guard let container = values.removeValue(forKey: key) else {
            return nil
        }
        remove(container)
        totalCost -= container.cost
        return container.value
    }

    func value(forKey key: Key) -> Value? {
        lock.lock()
        defer { lock.unlock() }
        if let container = values[key] {
            remove(container)
            append(container)
            return container.value
        }
        return nil
    }

    func removeAllValues() {
        lock.lock()
        values.removeAll()
        head = nil
        tail = nil
        totalCost = 0
        lock.unlock()
    }
}

private extension LRUCache {
    final class Container {
        var value: Value
        var cost: Int
        let key: Key
        unowned(unsafe) var prev: Container?
        unowned(unsafe) var next: Container?

        init(value: Value, cost: Int, key: Key) {
            self.value = value
            self.cost = cost
            self.key = key
        }
    }

    func remove(_ container: Container) {
        if head === container {
            head = container.next
        }
        if tail === container {
            tail = container.prev
        }
        container.next?.prev = container.prev
        container.prev?.next = container.next
        container.next = nil
    }

    func append(_ container: Container) {
        assert(container.next == nil)
        if head == nil {
            head = container
        }
        container.prev = tail
        tail?.next = container
        tail = container
    }

    func clean() {
        lock.lock()
        defer { lock.unlock() }
        while totalCost > totalCostLimit || count > countLimit,
              let container = head
        {
            remove(container)
            values.removeValue(forKey: container.key)
            totalCost -= container.cost
        }
    }
}
