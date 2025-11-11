//
//  DefaultControllerDispatcher.swift
//  xxf_ios
//  默认调度中间件
//  Created by xxf on /6/2.
//
import Vapor

/// 默认控制器调度器，支持拦截器处理请求
public final class DefaultControllerDispatcher: ControllerDispatcher, @unchecked Sendable {
    public init() {}

    public func onDispatch<C: RestApiController>(req: Request, controller: C) async throws -> Response {
        return try await controller.onDispatch(req: req)
    }
}
