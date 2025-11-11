import Foundation

/// Thread-safe dictionary wrapper
/// - Important: Note that this is a `class`, i.e. reference (not value) type
public final class ConcurrentDictionary<Key: Hashable, Value> {
    private var container: [Key: Value] = [:]
    private let rwlock = RWLock()

    public var keys: [Key] {
        let result: [Key]
        rwlock.readLock()
        result = Array(container.keys)
        rwlock.unlock()
        return result
    }

    public var values: [Value] {
        let result: [Value]
        rwlock.readLock()
        result = Array(container.values)
        rwlock.unlock()
        return result
    }

    public init() {}

    /// Sets the value for key
    ///
    /// - Parameters:
    ///   - value: The value to set for key
    ///   - key: The key to set value for
    public func set(value: Value, forKey key: Key) {
        rwlock.writeLock()
        _set(value: value, forKey: key)
        rwlock.unlock()
    }

    @discardableResult
    public func remove(_ key: Key) -> Value? {
        let result: Value?
        rwlock.writeLock()
        result = _remove(key)
        rwlock.unlock()
        return result
    }

    public func contains(_ key: Key) -> Bool {
        let result: Bool
        rwlock.readLock()
        result = container.index(forKey: key) != nil
        rwlock.unlock()
        return result
    }

    public func value(forKey key: Key) -> Value? {
        let result: Value?
        rwlock.readLock()
        result = container[key]
        rwlock.unlock()
        return result
    }

    public func mutateValue(forKey key: Key, mutation: (Value) -> Value) {
        rwlock.writeLock()
        if let value = container[key] {
            container[key] = mutation(value)
        }
        rwlock.unlock()
    }

    // MARK: Subscript

    public subscript(key: Key) -> Value? {
        get {
            return value(forKey: key)
        }
        set {
            rwlock.writeLock()
            defer {
                rwlock.unlock()
            }
            guard let newValue = newValue else {
                _remove(key)
                return
            }
            _set(value: newValue, forKey: key)
        }
    }

    // MARK: Private

    @inline(__always)
    private func _set(value: Value, forKey key: Key) {
        container[key] = value
    }

    @inline(__always)
    @discardableResult
    private func _remove(_ key: Key) -> Value? {
        guard let index = container.index(forKey: key) else { return nil }

        let tuple = container.remove(at: index)
        return tuple.value
    }

    public func removeAll(keepingCapacity: Bool = false) {
        rwlock.writeLock()
        defer { rwlock.unlock() }
        container.removeAll(keepingCapacity: keepingCapacity)
    }

    /// Returns the value for the key if exists.
    /// Otherwise, inserts the value produced by the closure and returns it.
    @discardableResult
    public func getOrSet(_ key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        rwlock.writeLock()
        defer { rwlock.unlock() }

        // 如果存在直接返回
        if let existing = container[key] {
            return existing
        }

        // 不存在则创建、插入并返回
        let value = defaultValue()
        container[key] = value
        return value
    }

    /**
     // 读取不存在的 key，会插入默认值 0
     let a = dict["count", default: 0]
     print(a) // 0

     // 可以直接自增
     dict["count", default: 0] += 1
     print(dict["count", default: 0]) // 1
     */
    public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
        get {
            return getOrSet(key, default: defaultValue())
        }
        set {
            self[key] = newValue
        }
    }
}
