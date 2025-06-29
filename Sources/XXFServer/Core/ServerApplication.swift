//
//  ServerApplication.swift
//  xxf_ios
//  服务器app
//  Created by xxf on /6/2.
//

import Atomics
import Vapor

public final class ServerApplication {
    private let app: Application
    private var task: Task<Void, Error>?
    private let isRunning = ManagedAtomic(false)

    /// 初始化
    /// - Parameters:
    ///   - port: 端口
    ///   - eventLoopGroupProvider: 线程模型
    ///   - backlog: 允许最多n个待处理的连接排队。
    public init(
        port: Int = 8080,
        eventLoopGroupProvider: Application.EventLoopGroupProvider = .singleton,
        backlog: Int = 16,
        onCreated: @Sendable (Application) -> Void
    ) async throws {
        #if DEBUG
            let env = Environment(name: "development", arguments: ["vapor", "serve"])
        #else
            let env = Environment(name: "production", arguments: ["vapor", "serve"])
        #endif
        let app = try await Application.make(env, eventLoopGroupProvider)
        app.http.server.configuration.port = port
        app.http.server.configuration.backlog = backlog
        onCreated(app)
        self.app = app
    }

    public func start() {
        // 已经在跑就直接返回
        if isRunning.load(ordering: .relaxed) { return }

        let app = self.app
        let runningFlag = isRunning

        // 这里用普通 Task 继承上下文，方便日志和 actor 隔离等
        task = Task(priority: .background) { @Sendable in
            runningFlag.store(true, ordering: .relaxed)
            do {
                try await app.startup()
                try await app.running?.onStop.get()
            } catch {
                app.logger.error("Server run error: \(error)")
            }
            // 优雅关停
            do {
                try await app.asyncShutdown()
            } catch {
                app.logger.error("Server shutdown error: \(error)")
            }
            runningFlag.store(false, ordering: .relaxed)
        }
    }

    public func stop() {
        guard isRunning.load(ordering: .relaxed) else { return }

        let app = self.app
        // 停止服务器信号，简单操作用普通 Task 即可
        Task { @Sendable in
            app.running?.stop()
        }
    }
}
