//
//  Try.swift
//  xxf_ios
//  记录日志
//  Created by xxf on 9/2.
//

import Foundation
import Logging

/// 缓存的 Logger
public let __tryCachedLogger: Logger = {
    let logger = Logger(label: "com.xxf.try.log")
    return logger
}()

/// 尝试执行一段代码，如果成功返回 true，失败返回 false
@discardableResult
@inlinable
@inline(__always)
public func tryOrFalse(_ block: () throws -> Void) -> Bool {
    do {
        try block()
        return true
    } catch {
        return false
    }
}

/// 尝试执行一段代码，如果失败则记录日志
@inlinable
@inline(__always)
public func tryOrLog(_ block: () throws -> Void) {
    do {
        try block()
    } catch {
        __tryCachedLogger.error("Error: \(String(describing: error))")
    }
}

/// 尝试执行一段代码，如果成功返回 true，失败返回 false 并记录日志
@discardableResult
@inlinable
@inline(__always)
public func tryOrLogFalse(_ block: () throws -> Void) -> Bool {
    do {
        try block()
        return true
    } catch {
        __tryCachedLogger.error("Error: \(String(describing: error))")
        return false
    }
}

/// 尝试执行一段代码，如果成功返回 block 的返回值，失败则返回 nil
@inlinable
@inline(__always)
public func tryOrNil<T>(_ block: () throws -> T?) -> T? {
    do {
        return try block()
    } catch {
        return nil
    }
}

/// 尝试执行一段代码，如果成功返回 block 的返回值，失败返回 nil 并记录日志
@inlinable
@inline(__always)
public func tryOrLogNil<T>(_ block: () throws -> T?) -> T? {
    do {
        return try block()
    } catch {
        __tryCachedLogger.error("Error: \(String(describing: error))")
        return nil
    }
}

/// 尝试执行一段代码，如果失败则记录日志并重新抛出异常
@inlinable
@inline(__always)
public func tryOrLogThrow(_ block: () throws -> Void) throws {
    do {
        try block()
    } catch {
        __tryCachedLogger.error("Error: \(String(describing: error))")
        throw error
    }
}

/// 尝试执行一段代码，如果失败则记录日志并重新抛出异常，返回 block 的结果
@inlinable
@inline(__always)
public func tryOrLogThrow<T>(_ block: () throws -> T) throws -> T {
    do {
        return try block()
    } catch {
        __tryCachedLogger.error("Error: \(String(describing: error))")
        throw error
    }
}
