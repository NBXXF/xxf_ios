//
//  Result.swift
//  xxf_ios
//
//  Created by xxfon /6/4.
//

import Foundation

// 顶层函数，捕获抛异常代码，返回 Result
public func runCatching<T>(_ block: () throws -> T) -> Result<T, Error> {
    do {
        return try .success(block())
    } catch {
        return .failure(error)
    }
}

public extension Result {
    /// 是否成功
    var isSuccess: Bool {
        if case .success = self { return true }
        return false
    }

    /// 是否失败
    var isFailure: Bool {
        return !isSuccess
    }

    /// 返回成功值或 nil
    func getOrNull() -> Success? {
        try? get()
    }

    /// 返回失败错误或 nil
    func exceptionOrNull() -> Failure? {
        if case let .failure(error) = self {
            return error
        }
        return nil
    }

    /// 返回成功值，失败则返回默认值
    func getOrElse(_ defaultValue: @autoclosure () -> Success) -> Success {
        (try? get()) ?? defaultValue()
    }

    /// 映射成功值
    func map<T>(_ transform: (Success) -> T) -> Result<T, Failure> {
        flatMap { .success(transform($0)) }
    }

    /// 映射失败错误
    func mapError<E: Error>(_ transform: (Failure) -> E) -> Result<Success, E> {
        switch self {
        case let .success(value):
            return .success(value)
        case let .failure(error):
            return .failure(transform(error))
        }
    }

    /// 根据成功或失败执行对应闭包，返回闭包返回值
    func fold<T>(onSuccess: (Success) -> T, onFailure: (Failure) -> T) -> T {
        switch self {
        case let .success(value):
            return onSuccess(value)
        case let .failure(error):
            return onFailure(error)
        }
    }

    /// 执行成功闭包，返回自身支持链式调用
    @discardableResult
    func onSuccess(_ action: (Success) -> Void) -> Result {
        if case let .success(value) = self {
            action(value)
        }
        return self
    }

    /// 执行失败闭包，返回自身支持链式调用
    @discardableResult
    func onFailure(_ action: (Failure) -> Void) -> Result {
        if case let .failure(error) = self {
            action(error)
        }
        return self
    }
}
