//
//  PreferenceBinding.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Combine

/// 用法参考`PreferencesDemo`
@propertyWrapper
public struct PreferenceBinding<T, Owner: PreferenceProvider> {
    private var wrapper: PreferenceWrapper<T?, Owner>

    public var wrappedValue: T? {
        get { wrapper.wrappedValue ?? nil }
        set { wrapper.wrappedValue = newValue }
    }

    public var projectedValue: AnyPublisher<T?, Never> {
        wrapper.projectedValue
            .map { $0 ?? nil } // 把 T?? 转成 T?
            .eraseToAnyPublisher()
    }

    public init(_ key: String, default defaultValue: T?, useSyncWrite: Bool = true, cacheEnabled: Bool = true) {
        wrapper = PreferenceWrapper(
            wrappedValue: defaultValue,
            key,
            owner: Owner.shared,
            useSyncWrite: useSyncWrite,
            cacheEnabled: cacheEnabled
        )
    }
}
