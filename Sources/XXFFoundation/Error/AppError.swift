/// 通用错误类型
//
//  AppError.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

import Foundation

/// 通用错误类型
open class AppError: Error, CustomNSError, LocalizedError, CustomStringConvertible, @unchecked Sendable {
    /// 默认 domain（CustomNSError 协议要求）
    public static let errorDomain: String = "com.xxf.app.error"
    private let code: Int
    private let userInfo: [String: Any]
    private let domain: String

    public init(_ message: String,
                code: Int = -1,
                domain: String = AppError.errorDomain,
                userInfo: [String: Any] = [:])
    {
        var finalUserInfo = userInfo
        if finalUserInfo[NSLocalizedDescriptionKey] == nil {
            /// 将code 打印一下
            let fullDescription = "\(code):\(message)"
            finalUserInfo[NSLocalizedDescriptionKey] = fullDescription
        }
        self.userInfo = finalUserInfo
        self.code = code
        self.domain = domain
    }

    /// 实例的自定义 domain
    public var errorDomain: String {
        return domain
    }

    public var message: String {
        return userInfo[NSLocalizedDescriptionKey] as? String ?? "Unknown Error"
    }

    public var errorCode: Int {
        return code
    }

    public var errorUserInfo: [String: Any] {
        return userInfo
    }

    public var description: String {
        // 使用 type(of: self) 获取实际类型名，属性部分保留父类字段
        "\(type(of: self))(domain: \(domain), code: \(code), message: \(message))"
    }

    // 2. 实现 LocalizedError 的 errorDescription（核心！系统会用它作为 localizedDescription）
    public var errorDescription: String? {
        return "\(code):\(message)"
    }
}
