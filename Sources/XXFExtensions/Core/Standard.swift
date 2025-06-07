//
//  Standard.swift
//  xxf_ios
//  高阶顶层函数,Swift 实现对象挂载高阶函数比较麻烦（有值类型Struct和引用类型)
// 2.采用Sourcery框架来自动生成,但也需要写注解,倾向于下面接口定义拓展
// 3.还有一个方案swift宏
//  Created by xxf on 2025/5/28.
//

import Foundation

// MARK: - Optional 的 let 顶层函数

@discardableResult
public func `let`<T, R>(_ optional: T?, _ block: (T) -> R) -> R? {
    guard let value = optional else { return nil }
    return block(value)
}

// MARK: - 通用 let 函数，返回 block 的结果

@discardableResult
public func `let`<T, R>(_ value: T, _ block: (T) -> R) -> R {
    return block(value)
}

// MARK: - 通用 apply 函数，修改对象并返回对象自身

@discardableResult
public func apply<T>(_ value: T, _ block: (inout T) -> Void) -> T {
    var copy = value
    block(&copy)
    return copy
}

// MARK: - run 函数，类似 let，返回 block 的结果

@discardableResult
public func run<T, R>(_ value: T, _ block: (T) -> R) -> R {
    return block(value)
}

// MARK: - also 函数，修改对象并返回自身

/// 注意参数没有加inout 值类型的struct注意级联使用
@discardableResult
public func also<T>(_ value: T, _ block: (T) -> Void) -> T {
    block(value)
    return value
}

// MARK: - with 函数

public func with<T>(_ value: T, block: (inout T) -> Void) -> T {
    var copy = value
    block(&copy)
    return copy
}

// MARK: - 协议方案

public protocol StandardExtensible {}

public extension StandardExtensible {
    @discardableResult
    func `let`<R>(_ block: (Self) -> R) -> R {
        block(self)
    }

    func apply(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }

    @discardableResult
    func run<R>(_ block: (Self) -> R) -> R {
        block(self)
    }

    /// 注意参数没有加inout 值类型的struct注意级联使用
    @discardableResult
    func also(_ block: (Self) -> Void) -> Self {
        block(self)
        return self
    }

    func with(_ block: (inout Self) -> Void) -> Self {
        var copy = self
        block(&copy)
        return copy
    }
}

extension NSObject: StandardExtensible {}
extension String: StandardExtensible {}
extension Int: StandardExtensible {}
extension Double: StandardExtensible {}
extension Array: StandardExtensible {}
extension Dictionary: StandardExtensible {}
// 你也可以让自定义类遵守 StandardExtensible
// class MyClass: StandardExtensible { ... }
// 或者
// extension MyClass: StandardExtensible { }

public extension Optional where Wrapped: StandardExtensible {
    func `let`<R>(_ block: (Wrapped) -> R) -> R? {
        guard let value = self else { return nil }
        return block(value)
    }

    @discardableResult
    func also(_ block: (Wrapped) -> Void) -> Wrapped? {
        if let value = self {
            block(value)
        }
        return self
    }
}
