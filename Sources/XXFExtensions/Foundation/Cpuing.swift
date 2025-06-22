//
//  Cpuing.swift
//  xxf_ios
//
//  Created by trl on 6/11.
//
import Darwin
import Foundation

/// 返回当前进程的 user + system CPU 时间（秒）
@discardableResult
@inlinable
@inline(__always)
func currentCPUTime() -> TimeInterval {
    var usage = rusage()
    getrusage(RUSAGE_SELF, &usage)
    let user = TimeInterval(usage.ru_utime.tv_sec) + TimeInterval(usage.ru_utime.tv_usec) / 1_000_000
    let system = TimeInterval(usage.ru_stime.tv_sec) + TimeInterval(usage.ru_stime.tv_usec) / 1_000_000
    return user + system
}

@discardableResult
@inlinable
@inline(__always)
func measureCPUUsage(of block: () -> Void) -> Double {
    let cpuStart = currentCPUTime()
    let timeStart = CFAbsoluteTimeGetCurrent()

    block()

    let cpuEnd = currentCPUTime()
    let timeEnd = CFAbsoluteTimeGetCurrent()

    let cpuTime = cpuEnd - cpuStart
    let wallTime = timeEnd - timeStart

    guard wallTime > 0 else { return 0 }

    let usage = (cpuTime / wallTime) * 100
    return usage
}

/// 测量代码块执行期间的多核累积 CPU 使用率百分比，可能超过 100%
/// - Parameters:
///   - onlyDebug: 仅在 Debug 模式下测量，Release 模式传 true 会跳过测量直接执行 block
///   - block: 需要测量的同步代码块
/// - Returns: 多核累积 CPU 使用率百分比（满载4核CPU可达400%）
@discardableResult
@inlinable
@inline(__always)
public func measureCPUUsage(onlyDebug: Bool = true, _ block: () -> Void) -> Double {
    #if DEBUG
        return measureCPUUsage(of: block)
    #else
        if onlyDebug {
            block()
            return 0
        } else {
            return measureCPUUsage(of: block)
        }
    #endif
}
