//
//  UserAPI.swift
//  xxf_ios
//
//  Created by trl on 2025/6/27.
//
import Foundation
import Vapor

public protocol ApiController: CaseIterable {
    var method: HTTPMethod { get }
    var pathComponent: String { get }

    func handleFuture(req: Request) -> EventLoopFuture<Response>

    func handle(req: Request) -> Response
}

extension ApiController {
    func handleFuture(req: Request) -> EventLoopFuture<Response> {
        let response = handle(req: req)
        return req.eventLoop.makeSucceededFuture(response)
    }
}
