//
//  OptionalUnwrappable.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Foundation

// MARK: - Optional 拆包协议

/// 用于从 Optional<T> 中提取 Wrapped 类型
protocol OptionalUnwrappable {
    /// 返回 Optional 包装的内部类型
    static var wrappedType: Any.Type { get }
}

extension Optional: OptionalUnwrappable {
    static var wrappedType: Any.Type {
        return Wrapped.self
    }
}
