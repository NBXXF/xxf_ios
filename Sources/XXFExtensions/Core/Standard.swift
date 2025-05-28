//
//  Standard.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/28.
//

// MARK: - let（Optional 作用域）

public extension Optional {
    /// 使用 `letDo`，并传入 `it` 作为命名，更接近 Kotlin 的风格
    func letDo<R>(_ block: (_ it: Wrapped) -> R) -> R? {
        map(block)
    }
}

//// MARK: - apply（引用类型）
// extension AnyObject {
//    @discardableResult
//    func apply(_ block: (_ self: Self) -> Void) -> Self {
//        block(self)
//        return self
//    }
// }
//
//// MARK: - apply（值类型）
// extension Any {
//    @discardableResult
//    func apply(_ block: (_ it: inout Self) -> Void) -> Self {
//        var copy = self
//        block(&copy)
//        return copy
//    }
// }
//
//// MARK: - also（副作用执行）
// extension Any {
//    @discardableResult
//    func also(_ block: (_ it: Self) -> Void) -> Self {
//        block(self)
//        return self
//    }
// }
//
//// MARK: - run（块作用域）
// @inlinable
// func run<R>(_ block: () -> R) -> R {
//    return block()
// }
