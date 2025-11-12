//
//  Tracker.swift
//  xxf_ios
//  采集错误,聚合多个渠道,比如sentry,bugly...
//  Created by xxf on 7/12.
//

import Foundation

// 增加命名冲突问题
public typealias XXFTracer = Tracker

/// 采集错误、日志等，支持同步 & 异步，多渠道并发安全上报
public final class Tracker: TrackerConverterChain, @unchecked Sendable {
    public static let shared = Tracker()

    /// 用于异步上报的队列
    private let operationQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "com.xxf.tracker.queue"
        q.maxConcurrentOperationCount = 2
        q.qualityOfService = .utility
        return q
    }()

    /// 用锁保护共享状态
    private let stateLock = NSLock()

    /// 转换器、渠道、回调都要在 isolationQueue 上读写
    private var _trackerConverters: [TrackerConverter] = [
        ErrorTrackerConverter(),
        StringTrackerConverter()
    ]
    private var _chanelBatchTrackers: [ChanelTracker] = []
    private var _trackerHandleCallback: TrackerHandleCallback?

    private init() {}

    // MARK: - 配置接口

    /// 设置上报拦截器
    public func setTrackerHandleCallback(_ callback: TrackerHandleCallback?) {
        _trackerHandleCallback = callback
    }

    /// 注册转换器，优先级最高，插入到最前面
    public func registerConverter(_ converter: TrackerConverter) {
        _trackerConverters.insert(converter, at: 0)
    }

    /// 注册采集渠道，优先级最高，插入到最前面
    public func registerChanelTracker(_ chanelTracker: ChanelTracker) {
        _chanelBatchTrackers.insert(chanelTracker, at: 0)
    }

    // MARK: - 转换数据

    public func convert(data: Any, extra: inout [AnyHashable: Any]) -> String {
        // 快速 snapshot
        let converters = stateLock.withLock { () -> ([TrackerConverter]) in
            return _trackerConverters
        }

        var tempExtra = extra
        var convertResult: String?

        if converters.first(where: {
            let c = $0.convert(data: data, extra: &tempExtra)
            if let s = c {
                convertResult = s
                return true
            }
            return false
        }) != nil, let str = convertResult {
            return str
        } else {
            return "\(data)"
        }
    }

    // MARK: - 同步 & 异步采集

    /// 同步采集数据
    /// - Parameters:
    ///   - data: 原始数据
    ///   - extra: 用于配置参数等，控制不同 SDK 或渠道，默认空字典
    public func track(data: Any, extra: [AnyHashable: Any] = [:]) {
        // 快速 snapshot
        let (channels, handleCallback) = stateLock.withLock { () -> ([ChanelTracker], TrackerHandleCallback?) in
            return (_chanelBatchTrackers, _trackerHandleCallback)
        }

        var extraMutable = extra
        let startExtra = handleCallback?.onTrackHandleStart(data: data, extra: &extraMutable)
            ?? [:]

        // 合并 startExtra 与 tempExtra
        var merged = startExtra
        for (k, v) in extraMutable {
            merged[k] = v
        }

        /// 多个渠道都采集
        for chanel in channels {
            chanel.onTracking(data: data, extra: merged, converterChain: self)
        }
    }

    /// 异步采集数据
    /// - Parameters:
    ///   - data: 原始数据
    ///   - extra: 配置参数，默认空字典
    public func trackAsync(data: Any, extra: [AnyHashable: Any] = [:]) {
        // 按值捕获
        let dataCopy = data
        let extraCopy = extra

        // 用自定义 Operation 不触发 @Sendable 校验
        let op = TrackOperation(
            tracker: self,
            data: dataCopy,
            extra: extraCopy
        )
        operationQueue.addOperation(op)
    }

    /// 自定义 Operation，不会被强制标记 @Sendable，安全捕获 Any/[AnyHashable:Any]
    private final class TrackOperation: Operation, @unchecked Sendable {
        unowned let tracker: Tracker
        let data: Any
        let extra: [AnyHashable: Any]

        init(tracker: Tracker,
             data: Any,
             extra: [AnyHashable: Any])
        {
            self.tracker = tracker
            self.data = data
            self.extra = extra
        }

        override func main() {
            tracker.track(data: data, extra: extra)
        }
    }
}
