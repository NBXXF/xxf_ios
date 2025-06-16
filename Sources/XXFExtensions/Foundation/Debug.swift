//
//  Debug.swift
//  xxf_ios
//  debug工具
//  Created by xxf on 6/11.
//

import Darwin
import Foundation

// MARK: - 时间基准配置

/// 获取 mach 时间单位比率（将 mach_absolute_time 转换为纳秒）
@usableFromInline
let timebaseInfo: mach_timebase_info_data_t = {
    var info = mach_timebase_info_data_t()
    mach_timebase_info(&info)
    return info
}()

// MARK: - 耗时测量方法

/// 测量代码块运行耗时（单位：秒）
@discardableResult
@inlinable
@inline(__always)
func measureTime(onlyDebug: Bool = true, _ block: () -> Void) -> TimeInterval {
    #if DEBUG
        return measureBlock(block)
    #else
        if onlyDebug {
            block()
            return 0
        } else {
            return measureBlock(block)
        }
    #endif
}

/// 真正的 mach 时间测量逻辑
@inlinable
@inline(__always)
func measureBlock(_ block: () -> Void) -> TimeInterval {
    let start = mach_absolute_time()
    block()
    let end = mach_absolute_time()

    let elapsed = end - start
    let nanos = Double(elapsed) * Double(timebaseInfo.numer) / Double(timebaseInfo.denom)
    return nanos / 1_000_000_000 // 返回秒数
}

/// 测量代码块耗时（纳秒）
@inlinable
@inline(__always)
public func measureTimeNanos(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1_000_000_000)
}

/// 测量代码块耗时（微秒）
@inlinable
@inline(__always)
public func measureTimeMicros(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1_000_000)
}

/// 测量代码块耗时（毫秒）
@inlinable
@inline(__always)
public func measureTimeMillis(onlyDebug: Bool = true, _ block: () -> Void) -> Int {
    Int(measureTime(onlyDebug: onlyDebug, block) * 1000)
}

// MARK: - 格式化输出

@inlinable
@inline(__always)
func formatTimeoutMessage(nanos: Int, limit: DispatchTimeInterval) -> String {
    "block run time out: took \(nanos) ns, limit \(limit.toNanoseconds) ns"
}

@inlinable
@inline(__always)
func formatTimeoutMessage(nanos: Int, limit: Int) -> String {
    "block run time out: took \(nanos) ns, limit \(limit) ns"
}

// MARK: - Debug 断言（仅在 Debug 模式下触发）

@inlinable
@inline(__always)
public func assertMeasureTime(condition: DispatchTimeInterval, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: true, block)
    assert(nanos <= condition.toNanoseconds, formatTimeoutMessage(nanos: nanos, limit: condition))
}

@available(*, deprecated, message: "assertMeasureTime")
@inlinable
@inline(__always)
public func assertMeasureTimeNanos(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: true, block)
    assert(nanos <= condition, formatTimeoutMessage(nanos: nanos, limit: condition))
}

@available(*, deprecated, message: "assertMeasureTime")
@inlinable
@inline(__always)
public func assertMeasureTimeMicros(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: true, block)
    let limit = condition * 1000
    assert(nanos <= limit, formatTimeoutMessage(nanos: nanos, limit: limit))
}

@available(*, deprecated, message: "assertMeasureTime")
@inlinable
@inline(__always)
public func assertMeasureTimeMillis(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: true, block)
    let limit = condition * 1_000_000
    assert(nanos <= limit, formatTimeoutMessage(nanos: nanos, limit: limit))
}

// MARK: - 通用断言（Release 和 Debug 都生效）

@inlinable
@inline(__always)
public func preconditionMeasureTime(condition: DispatchTimeInterval, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: false, block)
    precondition(nanos <= condition.toNanoseconds, formatTimeoutMessage(nanos: nanos, limit: condition))
}

@available(*, deprecated, message: "preconditionMeasureTime")
@inlinable
@inline(__always)
public func preconditionMeasureTimeNanos(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: false, block)
    precondition(nanos <= condition, formatTimeoutMessage(nanos: nanos, limit: condition))
}

@available(*, deprecated, message: "preconditionMeasureTime")
@inlinable
@inline(__always)
public func preconditionMeasureTimeMicros(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: false, block)
    let limit = condition * 1000
    precondition(nanos <= limit, formatTimeoutMessage(nanos: nanos, limit: limit))
}

@available(*, deprecated, message: "preconditionMeasureTime")
@inlinable
@inline(__always)
public func preconditionMeasureTimeMillis(condition: Int, _ block: () -> Void) {
    let nanos = measureTimeNanos(onlyDebug: false, block)
    let limit = condition * 1_000_000
    precondition(nanos <= limit, formatTimeoutMessage(nanos: nanos, limit: limit))
}
