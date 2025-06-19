// PreferenceWrapper.swift
// xxf_ios
//
// Created by xxf on 6/19.
//

import Combine
import Foundation

// MARK: - 属性包装器内部实现

/// 用法参考 `PreferencesDemo`
@propertyWrapper
public class PreferenceWrapper<T, Owner: PreferenceProvider>: NSObject {
    /// UserDefaults 或其它偏好存储的 key
    private let key: String
    /// 默认值（可选）
    private let defaultValue: T?
    private let ownerProvider: () -> Owner
    /// 偏好存储提供者实例（无主引用）
    private var owner: Owner { ownerProvider() }

    /// 并发队列，保证读写安全
    private let queue = DispatchQueue(label: "com.xxf.preference", attributes: .concurrent)
    /// Combine 发布者，发布偏好值变化
    private let subject: CurrentValueSubject<T?, Never>

    /// 是否同步写入（UserDefaults.synchronize 已废弃，一般忽略，但这里保留兼容）
    private let useSyncWrite: Bool
    /// 是否开启缓存，默认开启提高性能
    private let cacheEnabled: Bool

    /// 缓存的值
    private var cache: T? = nil
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
    ///   - owner: 偏好存储提供者实例
    ///   - useSyncWrite: 是否同步写入（废弃，但保留调用，默认 true）
    ///   - cacheEnabled: 是否启用缓存，默认 true
    public init(wrappedValue defaultValue: T?,
                _ key: String,
                ownerProvider: @escaping () -> Owner,
                useSyncWrite: Bool = true,
                cacheEnabled: Bool = true)
    {
        self.key = key
        self.defaultValue = defaultValue
        self.ownerProvider = ownerProvider
        self.useSyncWrite = useSyncWrite
        self.cacheEnabled = cacheEnabled
        subject = CurrentValueSubject(defaultValue)
        super.init()
        // 延迟初始化，首次 ensureInitialized 时执行 setupNotification/loadValue
    }

    deinit {
        if let observer = notificationObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }

    /// 第一次读或写时调用，完成订阅和首次加载
    private func ensureInitialized() {
        guard !didInitialize else { return }
        didInitialize = true

        setupNotification()

        if cacheEnabled {
            cache = loadValue()
            subject.send(cache)
        } else {
            subject.send(loadValue())
        }
    }

    /// 监听 UserDefaults 改变通知
    private func setupNotification() {
        guard let ud = owner.storage as? UserDefaults else { return }
        notificationObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: ud,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            let newValue = self.loadValue()
            if self.cacheEnabled {
                self.queue.async(flags: .barrier) {
                    self.cache = newValue
                    self.subject.send(newValue)
                }
            } else {
                self.subject.send(newValue)
            }
        }
    }

    /// 读取值（优先尝试解码 Data，其次基础类型，失败返回默认值）
    private func loadValue() -> T? {
        let storage = owner.storage

        if let data = storage.object(forKey: key) as? Data,
           !isDirectlyStorableType()
        {
            return _decodeIfConforming(to: T.self, from: data)
        }

        if let directValue = storage.object(forKey: key) as? T {
            return directValue
        }

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
                cacheEnabled ? (cache ?? loadValue()) : loadValue()
            }
        }
        set {
            ensureInitialized()
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                let storage = self.owner.storage

                if newValue == nil {
                    storage.removeObject(forKey: self.key)
                    if self.cacheEnabled {
                        self.cache = nil
                    }
                } else if let encoded = self.encodeIfNeeded(newValue!) {
                    storage.set(encoded, forKey: self.key)
                    if self.cacheEnabled {
                        self.cache = newValue
                    }
                }

                if self.useSyncWrite, let ud = storage as? UserDefaults {
                    ud.synchronize()
                }

                self.subject.send(newValue)
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
