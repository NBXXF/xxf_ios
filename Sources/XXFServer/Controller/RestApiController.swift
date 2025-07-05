//
//  UserAPI.swift
//  xxf_ios
//  将请求平摊到各个Controller里面,分而治之
//  设计参考springboot和moya
//  Created by xxf on /6/2.
//
import Vapor
import XXFJson

public protocol RestApiController: RouteDispatcher, CaseIterable, Sendable {
    /// 拦截器
    static var interceptors: [Interceptor] { get }
    /// 路由分组前缀，比如 "/api/users"
    static var routeGroup: String? { get }
    /// 相对路径，比如 "/:id" 或 "/create"
    var routePath: String { get }
    /// 支持请求方式(单一route,没必要支持多种)
    var method: HTTPMethod { get }

    /// 执行响应,通用响应,覆盖99%的场景,当然业务也可以覆盖onDispatch完全自定义
    /// 执行响应，建议使用 `async` 以支持客户端断开时自动中断, 前提是自己没有包装Task
    /// 业务可选     try Task.checkCancellation() // 可选，响应 cancel 更敏感, 前提是自己没有包装Task
    @Sendable
    func onRequest(req: Request) async throws -> any BaseResponseDto
}

public extension RestApiController {
    /// 默认interceptors
    static var interceptors: [any Interceptor] {
        []
    }

    /// 默认分组
    static var routeGroup: String? { return nil }
}

public extension RouteDispatcher where Self: RestApiController {
    func onDispatch(req: Request) async throws -> Response {
        let dto = try await onRequest(req: req)
        let encoded = try Json.toJson(dto)
        let vaporResponse = Response(status: .ok, body: .init(string: encoded))
        vaporResponse.headers.contentType = .json
        return vaporResponse
    }
}
