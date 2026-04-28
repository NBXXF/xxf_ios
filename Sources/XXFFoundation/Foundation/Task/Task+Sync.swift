//
//  Task+Sync.swift
//  xxf_ios
//  将异步编程同步
//  Created by xxf on 8/22.
//

import Foundation

private final class _TaskWaitBox<T: Sendable>: @unchecked Sendable {
    private let lock = NSLock()
    private var value: Result<T, Error>?
    let semaphore = DispatchSemaphore(value: 0)

    func finish(_ result: Result<T, Error>) {
        lock.lock()
        value = result
        lock.unlock()
        semaphore.signal()
    }

    func take() -> Result<T, Error>? {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

public extension Task where Failure == Error {
    /// 执行同步 block 并返回 Task 的结果
    /// - Parameter block: 同步执行的闭包
    /// - Returns: Task 的返回值
    static func sync(_ block: @escaping @Sendable () async throws -> Success) throws -> Success {
        let task = Task {
            try await block()
        }
        return try task.wait()
    }

    /// 避免aync 关键之传递
    /// - Returns: 返回执行结果
    func wait() throws -> Success {
        // 判断是否在主线程,不能在主线程,会卡死
        requireChildThread()

        let box = _TaskWaitBox<Success>()

        // 新开一个 detached Task，避免 @Sendable 闭包捕获可变局部状态。
        Task<Void, Never>.detached(priority: nil) { [task = self, box] in
            do {
                let value = try await task.value
                box.finish(.success(value))
            } catch {
                box.finish(.failure(error))
            }
            return ()
        }

        box.semaphore.wait()

        switch box.take() {
            case let .success(value):
                return value
            case let .failure(error):
                throw error
            case .none:
                throw AppError("Task did not complete")
        }
    }
}
