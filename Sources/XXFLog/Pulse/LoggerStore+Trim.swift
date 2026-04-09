//
//  LoggerStore+Trim.swift
//  xxf_ios
//
//  Created by xxf on 2023/8/26.
//
import Atomics
import Foundation
import Pulse

public extension LoggerStore {
    /// 自动清理日志缓存
    ///
    /// - Parameters:
    ///   - batch: 每处理多少条日志触发一次内存清理，默认 `500`
    ///   - sizeLimit: 数据库 + blob 最大占用，单位字节，默认 `15_000_000` (约 15 MB)
    ///   - trimRatio: 超过 `sizeLimit` 时清理比例，默认 `0.7` (清理 70%)
    ///   - sweepInterval: 自动清理间隔，单位秒，默认 `600` (10 分钟)
    func enableAutoTrim(
        batch: Int = 500,
        sizeLimit: Int64 = 15_000_000,
        trimRatio: Double = 0.7,
        sweepInterval: TimeInterval = 600
    ) {
        // 使用原子计数器保证线程安全
        let counter = ManagedAtomic(0)

        // 配置数据库占用和自动清理策略
        configuration.sizeLimit = sizeLimit
        configuration.trimRatio = trimRatio
        configuration.sweepInterval = sweepInterval

        // 每次日志事件触发时的处理
        configuration.willHandleEvent = { [weak self] event in
            guard let self else { return event }

            let current = counter.wrappingIncrementThenLoad(ordering: .relaxed)

            // 每 batch 条日志清理一次内存缓存
            if current % batch == 0 {
                self.clearMemoryCachesSafely()
            }

            return event
        }
    }
}
