// PreferenceWrapper.swift
// xxf_ios
//
// Created by xxf on 6/19.
//

import Combine
import Foundation

// MARK: - 属性包装器内部实现

/// 用法参考 `UserDefaultsPreferenceProvider`
@propertyWrapper
public class PreferenceWrapper<T, Owner: PreferenceProvider>: NSObject, @unchecked Sendable {
    /// UserDefaults 或其它偏好存储的 key
    private let key: String
    /// 默认值（可选）
    private let defaultValue: T?
    private let storage: PreferencesStorage

    /// 并发队列，保证读写安全
    private let queue = DispatchQueue(label: "com.xxf.preference", attributes: .concurrent)
    /// 锁保证初始化安全
    private let lock = NSLock()
    /// Combine 发布者，发布偏好值变化
    private let subject: CurrentValueSubject<T?, Never>

    /// 是否同步写入（UserDefaults.synchronize 已废弃，一般忽略，但这里保留兼容）
    private let useSyncWrite: Bool
    /// 是否开启缓存，默认开启提高性能
    private let cacheEnabled: Bool

    /// 缓存的值
    private var cache: T?
    /// UserDefaults 监听通知观察者
    private var notificationObserver: NSObjectProtocol?
    /// 是否已经完成延迟初始化
    private var didInitialize = false

    /// 公开 Combine 事件流
    public var projectedValue: AnyPublisher<T?, Never> {
        ensureInitialized()
        return subject.eraseToAnyPublisher()
    }

    /// 属性包装器初始化方法
    /// - Parameters:
    ///   - wrappedValue: 默认值（可选）
    ///   - key: 偏好存储键
    ///   - useSyncWrite: 是否同步写入（废弃，但保留调用，默认 true）
    ///   - cacheEnabled: 是否启用缓存，默认 false
    public init(wrappedValue defaultValue: T?,
                _ key: String,
                useSyncWrite: Bool = true,
                cacheEnabled: Bool = false)
    {
        self.key = key
        storage = Owner.storage
        self.defaultValue = defaultValue
        self.useSyncWrite = useSyncWrite
        self.cacheEnabled = cacheEnabled
        subject = CurrentValueSubject(defaultValue)
        super.init()
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// 第一次读或写时调用，完成订阅和首次加载
    private func ensureInitialized() {
        lock.lock()
        defer { lock.unlock() }

        guard !didInitialize else { return }
        didInitialize = true

        setupNotification()

        let initialValue = loadValue()
        if cacheEnabled {
            cache = initialValue
        }
        subject.send(initialValue)
    }

    /// 监听 UserDefaults 改变通知
    private func setupNotification() {
        guard let ud = storage as? UserDefaults else { return }

        notificationObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: ud,
            queue: .main
        ) { [weak self] _ in
            self?.queue.async(flags: .barrier) {
                guard let self = self else { return }
                let newValue = self.loadValue()

                if self.cacheEnabled {
                    self.cache = newValue
                }
                self.subject.send(newValue)
            }
        }
    }

    /// 读取值（优先尝试解码 Data，其次基础类型，失败返回默认值）
    private func loadValue() -> T? {
        // 1. 尝试读取原始值
        if let rawValue = storage.object(forKey: key) {
            // 2. 如果是 Data 且需要解码
            if let data = rawValue as? Data, !isDirectlyStorableType() {
                return _decodeIfConforming(to: T.self, from: data) ?? defaultValue
            }
            // 3. 如果是兼容类型直接返回
            else if let value = rawValue as? T {
                return value
            }
        }

        // 4. 返回默认值（可能为 nil）
        return defaultValue
    }

    /// 编码值（基础类型直接返回，复杂类型转 Data）
    private func encodeIfNeeded(_ value: T) -> Any? {
        if isDirectlyStorableType() {
            return value
        }
        if let encodable = value as? Encodable {
            return try? JSONEncoder().encode(AnyEncodable(encodable))
        }
        return nil
    }

    /// 判断是否为 UserDefaults 支持的直接存储类型
    private func isDirectlyStorableType() -> Bool {
        switch T.self {
        case is String.Type,
             is Int.Type,
             is Bool.Type,
             is Double.Type,
             is Float.Type,
             is Data.Type,
             is URL.Type:
            return true
        default:
            return false
        }
    }

    /// 属性包装器读写接口
    public var wrappedValue: T? {
        get {
            ensureInitialized()
            return queue.sync {
                cacheEnabled ? cache : loadValue()
            }
        }
        set {
            ensureInitialized()
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }

                if newValue == nil {
                    // 移除存储并重置为默认值
                    storage.removeObject(forKey: self.key)
                    let resetValue = self.loadValue()

                    if self.cacheEnabled {
                        self.cache = resetValue
                    }
                    self.subject.send(resetValue)
                } else if let encoded = self.encodeIfNeeded(newValue!) {
                    // 成功编码的值
                    storage.set(encoded, forKey: self.key)

                    if self.cacheEnabled {
                        self.cache = newValue
                    }
                    self.subject.send(newValue)
                } else {
                    // 编码失败时不更新存储和发送事件
                    print("[Preference] Encode failed for key: \(self.key), type: \(T.self)")
                }

                if self.useSyncWrite, let ud = storage as? UserDefaults {
                    ud.synchronize()
                }
            }
        }
    }
}

// MARK: - 类型擦除支持 Decodable 解码

/// 仅当 T 符合 Decodable 时，才调用此版本进行解码
private func _decodeIfConforming<T: Decodable>(to _: T.Type, from data: Data) -> T? {
    try? JSONDecoder().decode(T.self, from: data)
}

/// 默认 fallback（T 不是 Decodable），返回 nil
private func _decodeIfConforming<T>(to _: T.Type, from _: Data) -> T? {
    nil
}

// MARK: - 类型擦除包装器（用于 Encodable）

/// 用于绕开类型系统限制，把任意 Encodable 编码为 Data
private struct AnyEncodable: Encodable {
    private let encodeFunc: (Encoder) throws -> Void

    init(_ encodable: Encodable) {
        encodeFunc = { encoder in
            try encodable.encode(to: encoder)
        }
    }

    func encode(to encoder: Encoder) throws {
        try encodeFunc(encoder)
    }
}
