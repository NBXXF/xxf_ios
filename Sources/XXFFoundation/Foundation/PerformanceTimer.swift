//
//  PerformanceTimer.swift
//  xxf_ios
//  高精度性能计时器
//  Created by xxf on 6/13.
//

import Darwin.Mach
import Foundation

/// 取一个别名,其他语言通用的名字
public typealias Stopwatch = PerformanceTimer

/// 高精度性能计时器（class 版本，支持同步/异步测量）
public final class PerformanceTimer: @unchecked Sendable {
    // MARK: - 属性

    private var startTime: UInt64?

    @inline(__always)
    private nonisolated(unsafe) static var timebaseInfo: mach_timebase_info_data_t = {
        var info = mach_timebase_info_data_t()
        mach_timebase_info(&info)
        return info
    }()

    public init() {}

    // MARK: - 核心方法

    /// 开始计时
    public func start() {
        startTime = mach_absolute_time()
    }

    /// 停止计时并返回耗时
    public func stop() -> TimeUnit {
        let elapsed = elapsed()
        startTime = nil
        return elapsed
    }

    /// 返回从 start 到现在的耗时，不停止计时
    public func elapsed() -> TimeUnit {
        guard let start = startTime else { return .milliseconds(0) }
        let now = mach_absolute_time()
        let elapsedNano = (now - start) * UInt64(Self.timebaseInfo.numer) / UInt64(Self.timebaseInfo.denom)
        return .nanoseconds(Double(elapsedNano))
    }

    // MARK: - 同步测量

    /// 执行同步闭包并返回结果及耗时
    @discardableResult
    public func measureTime(of block: () -> Void) -> TimeUnit {
        start()
        block()
        let elapsed = stop()
        return elapsed
    }
}
