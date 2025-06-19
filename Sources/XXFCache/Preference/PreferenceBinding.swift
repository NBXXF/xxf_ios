//
//  PreferenceBinding.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Combine

@propertyWrapper
public struct PreferenceBinding<T, Owner: PreferenceProvider> {
    private var wrapper: PreferenceWrapper<T?, Owner>

    var wrappedValue: T? {
        get { wrapper.wrappedValue }
        set { wrapper.wrappedValue = newValue }
    }

    var projectedValue: AnyPublisher<T?, Never> {
        wrapper.projectedValue
    }

    /// 显式指定默认值
    init(wrappedValue defaultValue: T?, _ key: String) {
        wrapper = PreferenceWrapper(
            wrappedValue: defaultValue,
            key,
            owner: Owner.shared,
            useSyncWrite: true
        )
    }

    /// 可自定义 useSyncWrite
    init(_ key: String, default defaultValue: T?, useSyncWrite: Bool = true) {
        wrapper = PreferenceWrapper(
            wrappedValue: defaultValue,
            key,
            owner: Owner.shared,
            useSyncWrite: useSyncWrite
        )
    }

    /// 可选类型自动推导 nil
    init(_ key: String) where T: ExpressibleByNilLiteral {
        wrapper = PreferenceWrapper(
            wrappedValue: nil,
            key,
            owner: Owner.shared,
            useSyncWrite: true
        )
    }
}
