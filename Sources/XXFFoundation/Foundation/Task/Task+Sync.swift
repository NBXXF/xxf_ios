//
//  Task+Sync.swift
//  xxf_ios
//  将异步编程同步
//  Created by xxf on 8/22.
//

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

        var result: Result<Success, Error>?
        let semaphore = DispatchSemaphore(value: 0)

        // 新开一个 Task，不用 detached
        Task<Void, Error> {
            do {
                let value = try await self.value
                result = .success(value)
            } catch {
                result = .failure(error)
            }
            semaphore.signal()
            // 不需要再 return，因为闭包返回类型为 Void
        }

        semaphore.wait()

        switch result {
        case let .success(value):
            return value
        case let .failure(error):
            throw error
        case .none:
            throw AppError("Task did not complete")
        }
    }
}
