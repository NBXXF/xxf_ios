//
//  UserAPI.swift
//  xxf_ios
//  将请求平摊到各个Controller里面,分而治之
//  Created by trl on 2025/6/27.
//
import Vapor

public protocol BaseApiController: CaseIterable, Sendable {
    var basePath: String { get }
    var method: HTTPMethod { get }
    var pathComponent: String { get }

    @Sendable
    func dispatch(req: Request) -> EventLoopFuture<Response>

    @Sendable
    func onRequest(req: Request) throws -> Response
}

extension BaseApiController {
    @Sendable
    func dispatch(req: Request) -> EventLoopFuture<Response> {
        do {
            return try req.eventLoop.makeSucceededFuture(onRequest(req: req))
        } catch {
            return req.eventLoop.makeFailedFuture(error)
        }
    }

    public static func registerAll(on app: Application) {
        for api in allCases {
            let fullPath: [PathComponent] = [api.basePath, api.pathComponent].map(toPathComponent)

            switch api.method {
            case .GET:
                app.get(fullPath, use: api.dispatch)
            case .POST:
                app.post(fullPath, use: api.dispatch)
            case .PUT:
                app.put(fullPath, use: api.dispatch)
            case .DELETE:
                app.delete(fullPath, use: api.dispatch)
            case .PATCH:
                app.patch(fullPath, use: api.dispatch)
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

    private static func toPathComponent(_ string: String) -> PathComponent {
        if string.hasPrefix(":") {
            return .parameter(String(string.dropFirst()))
        } else {
            return .constant(string)
        }
    }
}
