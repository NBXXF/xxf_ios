//
//  ControllerRegister.swift
//  xxf_ios
//  注册器
//  Created by xxf on /6/2.
//
import Vapor

enum ControllerRegister {
    #if DEBUG
        private nonisolated(unsafe) static var usedRouteGroups = Set<String>()
    #endif
    /// 注册一个 RestApiController 类型的所有 API
    static func register<C: RestApiController>(on app: Application, type _: C.Type, dispatcher: ControllerDispatcher? = nil) {
        /// 避免路径重复注册替换,debug模式校验就行了
        #if DEBUG
            if let group = C.routeGroup, !group.isEmpty {
                if !usedRouteGroups.insert(group).inserted {
                    fatalError("Duplicate routeGroup: '\(group)'. Please ensure each RestApiController has a unique routeGroup.")
                }
            }
        #endif

        let dispatcher = dispatcher ?? DefaultControllerDispatcher()
        for api in C.allCases {
            let fullPath: [PathComponent] = {
                if let group = C.routeGroup, !group.isEmpty {
                    return Self.toPathComponents(group) + Self.toPathComponents(api.routePath)
                } else {
                    return Self.toPathComponents(api.routePath)
                }
            }()
            // 调度器中间件 dispatch
            let handler: @Sendable (Request) -> EventLoopFuture<Response> = { req in
                let interceptors = C.interceptors

                // 1. willSend 链处理
                let requestFuture = interceptors.reduce(req.eventLoop.makeSucceededFuture(req)) { future, interceptor in
                    future.flatMap { interceptor.willSend(request: $0) }
                }

                return requestFuture.flatMap { finalReq in
                    let responseFuture = dispatcher.onDispatch(req: finalReq, controller: api)

                    return responseFuture
                        // 成功响应时处理
                        .flatMap { response in
                            interceptors.reduce(req.eventLoop.makeSucceededFuture(response)) { future, interceptor in
                                future.flatMap {
                                    interceptor.didReceive(response: $0, error: nil, for: finalReq)
                                }
                            }
                        }
                        // 错误响应时处理
                        .flatMapError { error in
                            interceptors.reduce(req.eventLoop.makeFailedFuture(error)) { future, interceptor in
                                future.flatMapError { err in
                                    interceptor.didReceive(response: nil, error: err, for: finalReq)
                                }
                            }
                        }
                }
            }

            switch api.method {
            case .GET:
                app.get(fullPath, use: handler)
            case .POST:
                app.post(fullPath, use: handler)
            case .PUT:
                app.put(fullPath, use: handler)
            case .DELETE:
                app.delete(fullPath, use: handler)
            case .PATCH:
                app.patch(fullPath, use: handler)
            default:
                app.on(api.method, fullPath) { req in
                    let message = "❗️Unsupported HTTP method: \(api.method) for /\(fullPath.map(\.description).joined(separator: "/"))"
                    return req.eventLoop.makeSucceededFuture(
                        Response(status: .internalServerError, body: .init(string: message))
                    )
                }
            }
        }
    }

    /// 校验一下为空的问题
    /// 以及按斜杠进行拆分
    private static func toPathComponents(_ routePath: String) -> [PathComponent] {
        #if DEBUG
            let trimmedRoute = routePath.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmedRoute == routePath else {
                fatalError("The whole routePath contains leading or trailing whitespace: '\(routePath)'")
            }
            guard !routePath.contains("//") else {
                fatalError("The routePath contains consecutive slashes: '\(routePath)'")
            }
        #endif

        let segments = routePath.split(separator: "/").map(String.init)

        return segments.map { segment in
            #if DEBUG
                let trimmed = segment.trimmingCharacters(in: .whitespacesAndNewlines)
                guard trimmed == segment else {
                    fatalError("Path segment contains leading or trailing whitespace: '\(segment)' in routePath: '\(routePath)'")
                }
            #endif
            if segment.hasPrefix(":") {
                return .parameter(String(segment.dropFirst()))
            } else {
                return .constant(segment)
            }
        }
    }
}
