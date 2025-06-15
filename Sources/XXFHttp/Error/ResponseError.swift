//
//  ResponseError.swift
//  xxf_ios
//  网络异常
//  Created by trl on /6/10.
//

import Foundation

public struct ResponseError: Error, CustomStringConvertible {
    /// HTTP 状态码，比如 400、401、500 等
    public let statusCode: Int?

    /// 错误描述信息
    public let message: String

    /// 底层错误（可选）
    public let underlyingError: Error?

    public init(statusCode: Int? = nil, message: String, underlyingError: Error? = nil) {
        self.statusCode = statusCode
        self.message = message
        self.underlyingError = underlyingError
    }

    public var description: String {
        var desc = "HttpException"
        if let code = statusCode {
            desc += " (statusCode: \(code))"
        }
        desc += ": \(message)"
        if let err = underlyingError {
            desc += " | underlyingError: \(err)"
        }
        return desc
    }
}
