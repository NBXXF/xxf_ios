//
//  ServerApplication.swift
//  xxf_ios
//  服务器app
//  Created by xxf on /6/2.
//
import Vapor

public final class ServerApplication {
    private let app: Application
    private var isRunning = false

    public init(app: Application) {
        self.app = app
    }

    public init(onCreated: (Application) -> Void) {
        #if DEBUG
            app = Application(.development)
        #else
            app = Application(.production)
        #endif
        onCreated(app)
    }

    public func start() throws {
        precondition(!Thread.isMainThread, "must call in background thread!")
        guard !isRunning else { return }
        isRunning = true
        try app.run()
    }

    public func stop() throws {
        precondition(!Thread.isMainThread, "must call in background thread!")
        guard isRunning else { return }
        app.shutdown()
        isRunning = false
    }
}
