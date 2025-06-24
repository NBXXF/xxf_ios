//
//  Once.swift
//  xxf_ios
//
//  Created by xxf on 6/22.
//

import Foundation

private final class OnceTracker {
    nonisolated(unsafe) static let shared = OnceTracker()
    private var tokens = Set<String>()
    private let queue = DispatchQueue(label: "com.yourapp.runOnceQueue", attributes: .concurrent)

    func perform(token: String, block: () -> Void) {
        // 先无锁并发读取判断
        var tokenExists = false
        queue.sync {
            tokenExists = tokens.contains(token)
        }
        guard !tokenExists else { return }

        // 写操作同步栅栏执行，保证 block 同步执行
        queue.sync(flags: .barrier) {
            if !self.tokens.contains(token) {
                self.tokens.insert(token)
                block()
            }
        }
    }

    func performOrThrow(token: String, block: () throws -> Void) throws {
        var tokenExists = false
        queue.sync {
            tokenExists = tokens.contains(token)
        }
        guard !tokenExists else { return }

        try queue.sync(flags: .barrier) {
            if !self.tokens.contains(token) {
                try block()
                self.tokens.insert(token)
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
