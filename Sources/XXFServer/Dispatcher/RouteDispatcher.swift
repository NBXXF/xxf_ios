//
//  RouteHandler.swift
//  xxf_ios
//  请求中间件
//  Created by xxf on /6/2.
//
import Vapor

public protocol RouteDispatcher: Sendable {
    @Sendable
    func onDispatch(req: Request) async throws -> Response
}
