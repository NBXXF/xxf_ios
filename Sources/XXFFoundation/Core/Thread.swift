//
//  Thread.swift
//  xxf_ios
//  线程检查相关相关
//  Created by xxf on 6/12.
//

import Foundation

@inlinable
@inline(__always)
public func requireMainThread(onlyDebug: Bool = true, file: StaticString = #file, line: UInt = #line) {
    let message = "Must be called from main thread in \(file):\(line)"
    if onlyDebug {
        assert(Thread.isMainThread, message, file: file, line: line)
    } else {
        precondition(Thread.isMainThread, message, file: file, line: line)
    }
}

@inlinable
@inline(__always)
public func requireChildThread(onlyDebug: Bool = true, file: StaticString = #file, line: UInt = #line) {
    let message = "Must be called from child thread in \(file):\(line)"
    if onlyDebug {
        assert(!Thread.isMainThread, message, file: file, line: line)
    } else {
        precondition(!Thread.isMainThread, message, file: file, line: line)
    }
}

private let mainQueue = DispatchQueue.main
public func runMainThread(_ block: @escaping () -> Void) {
    mainQueue.async {
        block()
    }
}

public func runMainThreadIfNeeded(_ block: @escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        mainQueue.async {
            block()
        }
    }
}
