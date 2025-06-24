import Combine
import Foundation

@propertyWrapper
public class PreferenceWrapper<T: Sendable, Owner: PreferenceProvider>: NSObject, @unchecked Sendable {
    private let key: String
    private let defaultValue: T?
    private let storage: PreferencesStorage

    private let queue = DispatchQueue(label: "com.xxf.preference", attributes: .concurrent)
    private let subject: CurrentValueSubject<T?, Never>

    private let useSyncWrite: Bool
    private let cacheEnabled: Bool

    private var cache: T?

    private var notificationObserver: NSObjectProtocol?
    private var didInitialize = false

    public var projectedValue: AnyPublisher<T?, Never> {
        initializeIfNeeded()
        return subject.eraseToAnyPublisher()
    }

    public init(wrappedValue defaultValue: T?,
                _ key: String,
                useSyncWrite: Bool = true,
                cacheEnabled: Bool = true)
    {
        self.key = key
        self.defaultValue = defaultValue
        storage = Owner.storage
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

    private func initializeIfNeeded() {
        queue.async(flags: .barrier) { [weak self] in
            guard let self = self else { return }
            guard !self.didInitialize else { return }
            self.didInitialize = true
            self.setupNotification()

            let initialValue = self.loadValue()
            if self.cacheEnabled {
                self.cache = initialValue
            }
            self.subject.send(initialValue)
        }
    }

    private func setupNotification() {
        guard let ud = storage as? UserDefaults else { return }

        notificationObserver = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: ud,
            queue: .main // 主线程更新UI安全
        ) { [weak self] _ in
            guard let self = self else { return }
            self.queue.async(flags: .barrier) {
                let newValue = self.loadValue()
                if self.cacheEnabled {
                    self.cache = newValue
                }
                self.subject.send(newValue)
            }
        }
    }

    private func loadValue() -> T? {
        guard let rawValue = storage.object(forKey: key) else {
            return defaultValue
        }

        if isDirectlyStorableType() {
            return rawValue as? T ?? defaultValue
        }

        if let data = rawValue as? Data {
            return _decodeIfConforming(to: T.self, from: data) ?? defaultValue
        }

        return rawValue as? T ?? defaultValue
    }

    private func encodeIfNeeded(_ value: T) -> Any? {
        if isDirectlyStorableType() {
            return value
        }
        if let encodable = value as? Encodable {
            return try? JSONEncoder().encode(AnyEncodable(encodable))
        }
        return nil
    }

    /// 判断类型是否是 UserDefaults 等支持的原生类型（递归判断 Optional 包裹类型）
    private func isDirectlyStorableType(_ type: Any.Type = T.self) -> Bool {
        // 如果是 Optional<T>，递归判断 Wrapped 是否可存储
        if let optional = type as? OptionalUnwrappable.Type {
            return isDirectlyStorableType(optional.wrappedType)
        }

        // 判断基础类型
        switch type {
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

    public var wrappedValue: T? {
        get {
            if cacheEnabled {
                return cache ?? defaultValue
            } else {
                return loadValue()
            }
        }
        set {
            initializeIfNeeded()
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }

                if newValue == nil {
                    self.storage.removeObject(forKey: self.key)
                    let resetValue = self.loadValue()
                    if self.cacheEnabled {
                        self.cache = resetValue
                    }
                    self.subject.send(resetValue)
                } else if let encoded = self.encodeIfNeeded(newValue!) {
                    self.storage.set(encoded, forKey: self.key)
                    if self.cacheEnabled {
                        self.cache = newValue
                    }
                    self.subject.send(newValue)
                } else {
                    print("[Preference] Encode failed for key: \(self.key), type: \(T.self)")
                }

                if self.useSyncWrite, let ud = self.storage as? UserDefaults {
                    ud.synchronize()
                }
            }
        }
    }
}

// MARK: - 解码辅助

private func _decodeIfConforming<T: Decodable>(to _: T.Type, from data: Data) -> T? {
    try? JSONDecoder().decode(T.self, from: data)
}

private func _decodeIfConforming<T>(to _: T.Type, from _: Data) -> T? {
    nil
}

// MARK: - 类型擦除 Encodable

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
