//
//  ControllerDispatcher.swift
//  xxf_ios
//  RestController 调度中间件
//  Created by xxf on /6/2.
//
public protocol ControllerDispatcher: Sendable {
    /// 使用场景,可以分发成多态, 比如获取正常笔记和笔记历史版本,一般用户用不到
    func onDispatch<C: RestApiController>(req: Request, controller: C) async throws -> Response
}
