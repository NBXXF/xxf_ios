//
//  Standard.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/28.
//

import Foundation

public extension Optional {
    /// 使用 `letDo`，并传入 `it` 作为命名，更接近 Kotlin 的风格
    func `let`<R>(_ block: (_ it: Wrapped) -> R) -> R? {
        guard let value = self else { return nil }
        return block(value)
    }
}

public extension NSObject {
    /// 类似 Kotlin 的 `let`
    @discardableResult
    func `let`<R>(_ block: (Self) -> R) -> R {
        return block(self as! Self)
    }

    /// 类似 Kotlin 的 `apply`，用于修改对象并返回自己
    func apply(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }

    /// run: 使用当前值进行某种处理并返回结果
    func run<R>(_ block: (Self) -> R) -> R {
        return block(self as! Self)
    }

    /// 类似 Kotlin 的 `also`，用于修改对象并返回自己
    @discardableResult
    func also(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }
}

// 对 struct 类型使用 apply 的辅助函数
func with<T>(_ value: T, block: (inout T) -> Void) -> T {
    var copy = value
    block(&copy)
    return copy
}

// MARK: - 其他方案

// 缺点自定义的swift类需要手动写下面的扩展模版声明
// 2.采用Sourcery框架来自动生成
// 3.还有一个方案swift宏
// protocol RunExtensible {}
//
// extension RunExtensible {
//    func run<T>(_ block: (Self) -> T) -> T {
//        return block(self)
//    }
// }
//
//// 常用类型扩展一下
// extension String: RunExtensible {}
// extension Int: RunExtensible {}
// extension Double: RunExtensible {}
// extension Array: RunExtensible {}
// extension Dictionary: RunExtensible {}
// extension NSObject: RunExtensible {} // 所有 class 类型都继承 NSObject
