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
