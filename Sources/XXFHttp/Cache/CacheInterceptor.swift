//
//  CacheInterceptor.swift
//  xxf_ios
//
//  Created by xxf on 3/4.
//

import Moya

/// 缓存拦截器协议
/// 决定响应是否应该被缓存
public protocol CacheInterceptor: Sendable {
    /// 判断是否跳过缓存
    /// - Parameter response: 网络响应
    /// - Returns: true 表示跳过缓存（不缓存），false 表示缓存
    func shouldSkipCache(_ response: Response) -> Bool
}

/// 默认缓存拦截器
/// 仅当 statusCode == 200 且 Content-Type 为 JSON 时才缓存
public struct DefaultCacheInterceptor: CacheInterceptor {
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        // 状态码必须是 200
        guard response.statusCode == 200 else { return true }

        // Content-Type 必须是 JSON
        guard let contentType = response.response?.value(forHTTPHeaderField: "Content-Type"),
              contentType.lowercased().contains("application/json")
        else { return true }

        return false
    }
}

/// 仅检查状态码的拦截器
public struct StatusCodeCacheInterceptor: CacheInterceptor {
    public let validStatusCode: Int

    public init(statusCode: Int = 200) {
        validStatusCode = statusCode
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        response.statusCode != validStatusCode
    }
}

/// 允许所有响应缓存的拦截器
public struct AllowAllCacheInterceptor: CacheInterceptor {
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        false
    }
}

/// 禁止所有响应缓存的拦截器
public struct DenyAllCacheInterceptor: CacheInterceptor {
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        true
    }
}

/// 闭包缓存拦截器
public struct BlockCacheInterceptor: CacheInterceptor {
    private let block: @Sendable (Response) -> Bool

    public init(_ block: @escaping @Sendable (Response) -> Bool) {
        self.block = block
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        block(response)
    }
}
