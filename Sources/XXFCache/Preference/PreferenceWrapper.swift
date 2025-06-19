//
//  PreferenceWrapper.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Combine
import Foundation

// MARK: - 属性包装器

@propertyWrapper
public class PreferenceWrapper<T, Owner: PreferenceProvider>: NSObject {
    private let key: String
    private let defaultValue: T? // 改成可选
    private unowned let owner: Owner

    private let queue = DispatchQueue(label: "com.xxf.preference", attributes: .concurrent)
    private let subject: CurrentValueSubject<T?, Never> // 支持可选类型

    private let useSyncWrite: Bool
    private var kvoObservation: NSKeyValueObservation?

    var projectedValue: AnyPublisher<T?, Never> {
        subject.eraseToAnyPublisher()
    }

    init(wrappedValue defaultValue: T?, _ key: String, owner: Owner, useSyncWrite: Bool = true) {
        self.key = key
        self.defaultValue = defaultValue
        self.owner = owner
        self.useSyncWrite = useSyncWrite
        subject = CurrentValueSubject(defaultValue)
        super.init()
        setupKVO()
        subject.send(loadValue())
    }

    deinit {
        kvoObservation?.invalidate()
    }

    private func setupKVO() {
        guard let ud = owner.storage as? UserDefaults else { return }
        kvoObservation = ud.observe(\.dictionaryRepresentation, options: [.new]) { [weak self] _, change in
            guard let self = self else { return }
            if let newDict = change.newValue, newDict.keys.contains(self.key) {
                let newValue = self.loadValue()
                self.subject.send(newValue)
            }
        }
    }

    private func loadValue() -> T? {
        let storage = owner.storage
        if T.self is OptionalProtocol.Type {
            return decodeIfNeeded(from: storage) ?? defaultValue
        } else {
            return decodeIfNeeded(from: storage) ?? defaultValue
        }
    }

    private func decodeIfNeeded(from storage: PreferencesStorage) -> T? {
        if let data = storage.object(forKey: key) as? Data {
            let decoder = JSONDecoder()
            if let value = try? decoder.decode(T.self, from: data) {
                return value
            } else {
                #if DEBUG
                    print("⚠️ JSON decode failed for key '\(key)'")
                #endif
            }
        }
        return storage.object(forKey: key) as? T
    }

    private func encodeIfNeeded(_ value: T) -> Any? {
        if let codableValue = value as? Codable {
            return try? JSONEncoder().encode(codableValue)
        }
        return value
    }

    var wrappedValue: T? {
        get {
            queue.sync { loadValue() }
        }
        set {
            queue.async(flags: .barrier) { [weak self] in
                guard let self = self else { return }
                let storage = self.owner.storage

                if let optional = newValue as? OptionalProtocol, optional.isNil {
                    storage.removeObject(forKey: self.key)
                } else if let encoded = newValue.flatMap(self.encodeIfNeeded) {
                    storage.set(encoded, forKey: self.key)
                }

                if self.useSyncWrite, let ud = storage as? UserDefaults {
                    ud.synchronize()
                }

                self.subject.send(newValue)
            }
        }
    }
}
