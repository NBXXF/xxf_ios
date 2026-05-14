//
//  WebEventResponse.swift
//  xxf_ios
//  h5->native event body
//  Created by xxf on 5/13.
//
import Foundation
import XXFJson

public struct WebEventResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String?
    public let data: T

    public static func success(data: T, message: String? = "ok") -> WebEventResponse<T> {
        WebEventResponse(code: 200, message: message, data: data)
    }

    public static func fail(data: T, message: String? = "fail", code: Int = -1024) -> WebEventResponse<T> {
        WebEventResponse(code: code, message: message, data: data)
    }
}

public extension WebEventResponse where T == AnyCodable {
    static func webviewReleased() -> WebEventResponse<AnyCodable> {
        WebEventResponse<AnyCodable>(
            code: -1,
            message: "BridgeWebView has been released",
            data: AnyCodable(NSNull())
        )
    }

    static func webviewOnWebEventNotSet() -> WebEventResponse<AnyCodable> {
        WebEventResponse<AnyCodable>(
            code: -2,
            message: "onWebEvent is not set",
            data: AnyCodable(NSNull())
        )
    }

    static func webviewNotHandle(eventName: String) -> WebEventResponse<AnyCodable> {
        WebEventResponse.fail(
            data: AnyCodable(NSNull()),
            message: "Unhandled web event: \(eventName)",
            code: 404
        )
    }
}
