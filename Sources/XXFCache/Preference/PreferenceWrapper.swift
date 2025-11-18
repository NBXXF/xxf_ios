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

    public init(
        wrappedValue defaultValue: T?,
        _ key: String,
        useSyncWrite: Bool = true,
        cacheEnabled: Bool = true
    ) {
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
                if let cache = cache {
                    return cache
                } else {
                    cache = loadValue()
                    return cache ?? defaultValue
                }
            } else {
                return loadValue() ?? defaultValue
            }
        }
        set {
            initializeIfNeeded()
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }

                switch newValue {
                    case .some(let value):
                        // 有值：尝试编码和存储
                        if let encoded = self.encodeIfNeeded(value) {
                            self.storage.set(encoded, forKey: self.key)
                            if self.cacheEnabled {
                                self.cache = newValue
                            }
                            self.subject.send(newValue)
                        } else {
                            print("[Preference] Encode failed for key: \(self.key), type: \(T.self)")
                            // 编码失败也视为要设置为 nil
                            self.storage.removeObject(forKey: self.key)
                            if self.cacheEnabled {
                                self.cache = nil
                            }
                            self.subject.send(nil)
                        }

                    case .none:
                        // 明确为 nil：移除存储
                        self.storage.removeObject(forKey: self.key)
                        if self.cacheEnabled {
                            self.cache = nil
                        }
                        self.subject.send(nil)
                }

                if self.useSyncWrite, let ud = self.storage as? UserDefaults {
                    ud.synchronize()
                }
            }
        }
    }
}

// MARK: - 解码辅助

private func _decodeIfConforming<T>(
    to _: T.Type,
    from data: Data
) -> T? {
    // 1. 首先处理可选类型
    if let optionalType = T.self as? OptionalUnwrappable.Type {
        /// print("[Preference] Detected optional type: \(T.self)")

        if let wrappedType = optionalType.wrappedType as? any Decodable.Type {
            /// print("[Preference] Wrapped type is Decodable: \(wrappedType)")

            do {
                // 尝试解码非可选版本
                let decoded = try JSONDecoder().decode(wrappedType, from: data)
                return optionalType.createOptional(with: decoded) as? T
            } catch {
                print("[Preference] Optional decoding error: \(error)")
            }
        }
    }

    // 2. 处理非可选 Decodable 类型
    if let decodableType = T.self as? any Decodable.Type {
        /// print("[Preference] Trying as non-optional Decodable: \(decodableType)")

        do {
            let decoded = try JSONDecoder().decode(decodableType, from: data)
            return decoded as? T
        } catch {
            print("[Preference] Non-optional decoding error: \(error)")
        }
    }

    // 3. 最后尝试 JSONSerialization
    do {
        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
        if let value = jsonObject as? T {
            return value
        }
    } catch {
        print("[Preference] JSONSerialization error: \(error)")
    }

    return nil
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
