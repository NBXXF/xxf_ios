//
//  Debug.swift
//  xxf_ios
//  debug工具
//  Created by trl on 6/11.
//

import Darwin
import Foundation

private let timebaseInfo: mach_timebase_info_data_t = {
    var info = mach_timebase_info_data_t()
    mach_timebase_info(&info)
    return info
}()

@discardableResult
private func measureTime(onlyDebug: Bool = true, _ block: () -> Void) -> TimeInterval {
    #if DEBUG
        // Debug 模式下，无论 onlyDebug true/false 都测量
        return measureBlock(block)
    #else
        if onlyDebug {
            // Release 模式且只想在 Debug 测量，则直接执行不测量
            block()
            return 0
        } else {
            // Release 模式且想测量，则仍然测量
            return measureBlock(block)
        }
    #endif
}

private func measureBlock(_ block: () -> Void) -> TimeInterval {
    let start = mach_absolute_time()
    block()
    let end = mach_absolute_time()

    let elapsed = end - start
    let nanos = Double(elapsed) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom)
    return nanos / 1_000_000_000 // 返回秒数
}

/// 纳秒
public func measureTimeNanos(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1_000_000_000)
}

/// 微秒
public func measureTimeMicros(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1_000_000)
}

/// 毫秒
public func measureTimeMillis(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1000)
}

/// 断言 指定运行超时时间,
/// - parameter condition：纳秒
/// - parameter block: 要执行的代码块
public func assertMeasureTimeNanos(condition: Int, _ block: () -> Void) {
    assert(Int(measureTime(onlyDebug: true, block) * 1_000_000_000) <= condition, "block run time out")
}

/// 断言 指定运行超时时间,
/// - parameter condition：微秒
/// - parameter block: 要执行的代码块
public func assertMeasureTimeMicros(condition: Int, _ block: () -> Void) {
    assert(Int(measureTime(onlyDebug: true, block) * 1_000_000_000) <= condition, "block run time out")
}

/// 断言 指定运行超时时间,
/// - parameter condition：毫秒
/// - parameter block: 要执行的代码块
public func assertMeasureTimeMillis(condition: Int, _ block: () -> Void) {
    assert(Int(measureTime(onlyDebug: true, block) * 1_000_000_000) <= condition, "block run time out")
}

/// 断言(包括release)  指定运行超时时间, 纳秒单位
/// - parameter condition: 纳秒阈值
/// - parameter block: 要执行的代码块
public func preconditionMeasureTimeNanos(condition: Int, _ block: () -> Void) {
    let nanos = Int(measureTime(onlyDebug: false, block) * 1_000_000_000)
    precondition(nanos <= condition, "block run time out: took \(nanos) ns, limit \(condition) ns")
}

/// 断言(包括release)  指定运行超时时间, 微秒单位
/// - parameter condition: 微秒阈值
/// - parameter block: 要执行的代码块
public func preconditionMeasureTimeMicros(condition: Int, _ block: () -> Void) {
    let micros = Int(measureTime(onlyDebug: false, block) * 1_000_000)
    precondition(micros <= condition, "block run time out: took \(micros) µs, limit \(condition) µs")
}

/// 断言(包括release) 指定运行超时时间, 毫秒单位
/// - parameter condition: 毫秒阈值
/// - parameter block: 要执行的代码块
public func preconditionMeasureTimeMillis(condition: Int, _ block: () -> Void) {
    let millis = Int(measureTime(onlyDebug: false, block) * 1000)
    precondition(millis <= condition, "block run time out: took \(millis) ms, limit \(condition) ms")
}
