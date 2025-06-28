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

    public init(
        port: Int = 8080,
        onCreated: @Sendable (Application) -> Void
    ) async throws {
        #if DEBUG
            let env: Environment = .development
        #else
            let env: Environment = .production
        #endif

        let app = try await Application.make(env)
        app.http.server.configuration.port = port

        // 这里 onCreated 已经是 @Sendable，不会捕获非 Sendable 的 self
        onCreated(app)
        self.app = app
    }

    public func start() {
        // 已经在跑就直接返回
        if isRunning.load(ordering: .relaxed) { return }

        // 把要用到的实例都拉到局部常量，闭包里就不会捕获 self
        let app = self.app
        let runningFlag = isRunning

        task = Task.detached(priority: .background) { @Sendable in
            // 启动 HTTP
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
        // 仅在真的运行时发关闭信号
        guard isRunning.load(ordering: .relaxed) else { return }

        // 同样先把 app 拉到局部常量
        let app = self.app
        Task.detached { @Sendable in
            app.running?.stop()
        }
    }
}
