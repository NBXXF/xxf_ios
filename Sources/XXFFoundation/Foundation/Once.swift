//
//  Once.swift
//  xxf_ios
//
//  Created by xxf on 6/22.
//

import Foundation

private final class OnceTracker: @unchecked Sendable {
    /// shared 实例是不安全的,这里选择static
    private static let lock = NSLock()
    fileprivate static let shared = OnceTracker()
    private var tokens = Set<String>()
    private init() {}
    /// 同步执行，只执行一次（非抛错版本）
    func perform(token: String, block: () -> Void) {
        var shouldRun = false
        synchronized(Self.lock) {
            if !tokens.contains(token) {
                tokens.insert(token)
                shouldRun = true
            }
        }
        if shouldRun {
            block()
        }
    }

    /// 同步执行，只执行一次，支持 throws
    /// - 注意：只有 block 成功执行才会记录 token
    func performOrThrow(token: String, block: () throws -> Void) throws {
        var shouldRun = false
        synchronized(Self.lock) {
            if !tokens.contains(token) {
                tokens.insert(token) // 提前插入
                shouldRun = true
            }
        }
        if shouldRun {
            do {
                try block()
            } catch {
                // 出错就移除 token，下次可重试
                synchronized(Self.lock) {
                    tokens.remove(token)
                }
                throw error
            }
        }
    }
}

/// 整个进程只执行一次
/// - Parameters:
///   - token: 唯一标识
///   - block: 执行单元
public func runOnce(
    token: String? = nil,
    file: StaticString = #file,
    line: Int = #line,
    function: StaticString = #function,
    block: () -> Void
) {
    let defaultToken = "\(file):\(line):\(function)"
    OnceTracker.shared.perform(token: token ?? defaultToken, block: block)
}

/// 整个进程只执行一次
/// - Parameters:
///   - token: 标识
///   - block: 执行单元
/// - Throws: description
public func runOnceOrThrow(
    token: String? = nil,
    file: StaticString = #file,
    line: Int = #line,
    function: StaticString = #function,
    block: () throws -> Void
) throws {
    let defaultToken = "\(file):\(line):\(function)"
    try OnceTracker.shared.performOrThrow(token: token ?? defaultToken, block: block)
}

/// 整个scope实例只执行一次
/// - Parameters:
///   - token: 唯一标识
///   - block: 执行单元
public func runOnce(
    scope: AnyObject,
    token: String? = nil,
    file: StaticString = #file,
    line: Int = #line,
    function: StaticString = #function,
    block: () -> Void
) {
    let scopeId = String(ObjectIdentifier(scope).hashValue)
    let defaultToken = "\(file):\(line):\(function)\(scopeId)"
    OnceTracker.shared.perform(token: token ?? defaultToken, block: block)
}

/// 整个scope实例只执行一次
/// - Parameters:
///   - token: 标识
///   - block: 执行单元
/// - Throws: description
public func runOnceOrThrow(
    scope: AnyObject,
    token: String? = nil,
    file: StaticString = #file,
    line: Int = #line,
    function: StaticString = #function,
    block: () throws -> Void
) throws {
    let scopeId = String(ObjectIdentifier(scope).hashValue)
    let defaultToken = "\(file):\(line):\(function)\(scopeId)"
    try OnceTracker.shared.performOrThrow(token: token ?? defaultToken, block: block)
}
