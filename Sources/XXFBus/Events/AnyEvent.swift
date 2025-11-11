//
//  AnyEvent.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

/// 万能事件包装类
public final class AnyEvent {
    let value: Any
    public init(_ value: Any) {
        self.value = value
    }

    public func asType<T>(_: T.Type) -> T? {
        return value as? T
    }
}
