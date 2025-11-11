//
//  PulseNetworkLoggerAdapter.swift
//  xxf_ios
//
//  Created by xxf on 7/16.
//

import Foundation
import Pulse
import Vapor

final class PulseNetworkLoggerAdapter {
    nonisolated(unsafe) static let shared = PulseNetworkLoggerAdapter()

    private let logger: NetworkLogger = .shared

    private var taskMap = [UUID: FakeURLSessionDataTask]()
    private var requestIDMap = NSMapTable<AnyObject, NSUUID>(keyOptions: .weakMemory, valueOptions: .strongMemory)
    private let lock = NSLock()

    // MARK: - 私有方法

    /// 清理 requestIDMap 中失效的 key
    private func cleanupRequestIDMap() {
        for case let key as AnyObject in requestIDMap.keyEnumerator().allObjects {
            if requestIDMap.object(forKey: key) == nil {
                requestIDMap.removeObject(forKey: key)
            }
        }
    }

    // MARK: - Public API

    /// 绑定 request 对象到 requestID
    func bind(id: UUID, to request: AnyObject) {
        lock.withLock {
            requestIDMap.setObject(id as NSUUID, forKey: request)
            cleanupRequestIDMap() // 顺便清理失效对象
        }
    }

    /// 根据 request 获取 requestID
    func requestID(for request: AnyObject) -> UUID? {
        lock.withLock {
            cleanupRequestIDMap() // 顺便清理失效对象
            return requestIDMap.object(forKey: request) as UUID?
        }
    }

    /// 创建并开始记录日志
    func startLog(requestID: UUID, request: URLRequest, requestBody: Data? = nil) {
        let task = FakeURLSessionDataTask(request: request)
        lock.withLock {
            taskMap[requestID] = task
        }

        logger.logTaskCreated(task)

        if let body = requestBody {
            logger.logDataTask(task, didReceive: body)
        }
    }

    /// 完成日志记录
    func finishLog(
        requestID: UUID,
        response: HTTPURLResponse?,
        responseBody: Data?,
        error: Error?
    ) {
        var task: FakeURLSessionDataTask?
        lock.withLock {
            task = taskMap.removeValue(forKey: requestID)
        }

        guard let task = task else { return }

        // 给 _response 赋值也加锁
        lock.withLock {
            task._response = response
        }

        if let body = responseBody {
            logger.logDataTask(task, didReceive: body)
        }

        logger.logTask(task, didCompleteWithError: error)
    }
}
