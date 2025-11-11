//
//  BaseApiService.swift
//  xxf_ios
//  日志联动
//  Created by xxf on /6/8.
//
import Alamofire
import Foundation
import Pulse

open class LoggerEventMonitor: EventMonitor, @unchecked Sendable {
    // MARK: - Singleton

    public static let shared = LoggerEventMonitor()

    // MARK: - Enable Switch

    public var isEnabled = true

    // MARK: - Logger

    public var logger: NetworkLogger

    public init(isEnabled: Bool = true, logger: NetworkLogger = .shared) {
        self.isEnabled = isEnabled
        self.logger = logger
    }

    // MARK: - EventMonitor methods

    open func request(_: Request, didCreateTask task: URLSessionTask) {
        guard isEnabled else { return }
        logger.logTaskCreated(task)
    }

    open func urlSession(_: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard isEnabled else { return }
        logger.logDataTask(dataTask, didReceive: data)
    }

    open func urlSession(_: URLSession, task: URLSessionTask, didFinishCollecting metrics: URLSessionTaskMetrics) {
        guard isEnabled else { return }
        logger.logTask(task, didFinishCollecting: metrics)
    }

    open func urlSession(_: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard isEnabled else { return }
        logger.logTask(task, didCompleteWithError: error)
    }
}
