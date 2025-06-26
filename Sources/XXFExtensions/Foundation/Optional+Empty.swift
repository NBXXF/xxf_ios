//
//  Optional+Empty.swift
//  xxf_ios
//  空值的问题
//  Created by xxf on 6/26.
//
import Foundation

public extension Optional {
    /// 当 Optional 不为 nil 时返回其值，否则返回你提供的 default
    func or(_ defaultValue: Wrapped) -> Wrapped {
        return self ?? defaultValue
    }
}

public extension Optional where Wrapped: RangeReplaceableCollection {
    /// 当 Optional 集合（包括 String、Array、Dictionary、Set、Data 等）为 nil 时，返回空集合/空字符串
    var orEmpty: Wrapped {
        return self ?? .init()
    }
}

public extension Optional where Wrapped: Numeric {
    /// 当 Optional 为 nil 时返回 0
    var orZero: Wrapped { self ?? 0 }
}

public extension Optional where Wrapped == Bool {
    /// 当 Optional 为 nil 时返回 false
    var orFalse: Bool { self ?? false }
}
