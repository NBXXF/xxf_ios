//
//  Reporter.swift
//  xxf_ios
//  事件上报，支持内部多渠道
//  Created by xxf
//

import Foundation

// MARK: - Type Alias

public typealias XXFEventReporter = EventReporter
public typealias Reporter = EventReporter

// MARK: - EventReporter

/// 事件上报，支持同步 & 异步，多渠道并发安全上报
public final class EventReporter: @unchecked Sendable {
    public static let shared = EventReporter()

    /// 用于异步上报的队列
    private let operationQueue: OperationQueue = {
        let q = OperationQueue()
        q.name = "com.xxf.reporter.queue"
        q.maxConcurrentOperationCount = 2
        q.qualityOfService = .utility
        return q
    }()

    /// 用于保护共享状态的锁
    private let stateLock = NSLock()

    /// 事件渠道列表
    private var _eventChannels: [EventChannel] = []

    /// 上报拦截回调
    private var _handleCallback: EventHandleCallback?

    private init() {}

    // MARK: - 配置接口

    /// 设置上报拦截器
    public func setHandleCallback(_ callback: EventHandleCallback?) {
        stateLock.withLock {
            _handleCallback = callback
        }
    }

    /// 注册事件渠道，优先级最高，插入到最前面
    public func registerChannel(_ channel: EventChannel) {
        stateLock.withLock {
            _eventChannels.insert(channel, at: 0)
        }
    }

    /// 移除指定渠道
    public func unregisterChannel(_ channel: EventChannel) {
        stateLock.withLock {
            _eventChannels.removeAll { $0 === channel }
        }
    }

    // MARK: - 事件上报

    /// 上报事件
    /// - Parameters:
    ///   - event: 事件名称
    ///   - parameters: 事件参数，默认空字典
    public func reportEvent(_ event: String, parameters: [String: Any] = [:]) {
        // 快速 snapshot
        let (channels, handleCallback) = stateLock.withLock { () -> ([EventChannel], EventHandleCallback?) in
            return (_eventChannels, _handleCallback)
        }

        var paramsMutable = parameters
        let startParams = handleCallback?.onEventHandleStart(event: event, parameters: &paramsMutable)
            ?? [:]

        // 合并 startParams 与 paramsMutable
        var merged: [String: Any] = startParams
        for (k, v) in paramsMutable {
            merged[k] = v
        }

        // 多个渠道都上报
        for channel in channels {
            channel.onEventReported(event: event, parameters: merged)
        }
    }

    /// 异步上报事件
    /// - Parameters:
    ///   - event: 事件名称
    ///   - parameters: 事件参数，默认空字典
    public func reportEventAsync(_ event: String, parameters: [String: Any] = [:]) {
        // 按值捕获
        let eventCopy = event
        let paramsCopy = parameters

        let op = ReportEventOperation(
            reporter: self,
            event: eventCopy,
            parameters: paramsCopy
        )
        operationQueue.addOperation(op)
    }

    // MARK: - 批量上报

    /// 批量上报事件
    /// - Parameters:
    ///   - events: 事件列表 (eventName, parameters)
    public func reportEvents(_ events: [(event: String, parameters: [String: Any])]) {
        for (event, params) in events {
            reportEvent(event, parameters: params)
        }
    }

    /// 异步批量上报事件
    /// - Parameters:
    ///   - events: 事件列表
    public func reportEventsAsync(_ events: [(event: String, parameters: [String: Any])]) {
        let eventsCopy = events
        let op = BlockOperation { [weak self] in
            self?.reportEvents(eventsCopy)
        }
        operationQueue.addOperation(op)
    }

    // MARK: - 自定义 Operation

    /// 自定义 Operation，安全捕获参数
    private final class ReportEventOperation: Operation, @unchecked Sendable {
        unowned let reporter: EventReporter
        let event: String
        let parameters: [String: Any]

        init(reporter: EventReporter,
             event: String,
             parameters: [String: Any])
        {
            self.reporter = reporter
            self.event = event
            self.parameters = parameters
        }

        override func main() {
            reporter.reportEvent(event, parameters: parameters)
        }
    }
}
