//
//  CacheInterceptor.swift
//  xxf_ios
//
//  缓存拦截器
//
//  功能说明:
//  缓存拦截器用于决定 HTTP 响应是否应该被缓存。
//  通过实现 `CacheInterceptor` 协议，可以自定义缓存策略。
//
//  内置拦截器:
//  ┌────────────────────────┬────────────────────────────────────────┐
//  │ 拦截器                  │ 行为                                   │
//  ├────────────────────────┼────────────────────────────────────────┤
//  │ DefaultCacheInterceptor│ 仅缓存 200 且 Content-Type 为 JSON    │
//  │ StatusCodeInterceptor  │ 仅检查状态码                           │
//  │ AllowAllInterceptor    │ 允许所有响应缓存                       │
//  │ DenyAllInterceptor     │ 禁止所有响应缓存                       │
//  │ BlockCacheInterceptor  │ 自定义闭包判断                         │
//  │ CompositeInterceptor   │ 组合多个拦截器                         │
//  └────────────────────────┴────────────────────────────────────────┘
//
//  Created by xxf on 3/4.
//

import Moya

// MARK: - 缓存拦截器协议

/// 缓存拦截器协议
///
/// 决定响应是否应该被缓存。实现此协议以自定义缓存策略。
///
/// ## 使用示例
/// ```swift
/// struct CustomCacheInterceptor: CacheInterceptor {
///     func shouldSkipCache(_ response: Response) -> Bool {
///         // 只缓存成功的响应
///         return response.statusCode != 200
///     }
/// }
/// ```
public protocol CacheInterceptor: Sendable {
    /// 判断是否跳过缓存
    /// - Parameter response: 网络响应
    /// - Returns: true 表示跳过缓存（不缓存），false 表示缓存
    func shouldSkipCache(_ response: Response) -> Bool
}

// MARK: - 默认缓存拦截器

/// 默认缓存拦截器
///
/// 仅当满足以下条件时才缓存响应：
/// - HTTP 状态码为 200
/// - Content-Type 包含 "application/json"
///
/// 这是最常用的拦截器，适用于 JSON API 响应缓存。
public struct DefaultCacheInterceptor: CacheInterceptor {
    /// 创建默认缓存拦截器
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        // 状态码必须是 200
        guard response.statusCode == 200 else { return true }

        // Content-Type 必须是 JSON
        guard let contentType = response.response?.value(forHTTPHeaderField: "Content-Type"),
              contentType.lowercased().contains("application/json")
        else { return true }

        // 空数据不缓存
        guard !response.data.isEmpty else { return true }

        return false
    }
}

// MARK: - 状态码拦截器

/// 仅检查状态码的拦截器
///
/// 只要状态码匹配就缓存，不检查 Content-Type。
/// 适用于需要缓存非 JSON 响应的场景。
public struct StatusCodeCacheInterceptor: CacheInterceptor {
    /// 有效的状态码
    public let validStatusCode: Int

    /// 创建状态码拦截器
    /// - Parameter statusCode: 允许缓存的状态码，默认 200
    public init(statusCode: Int = 200) {
        validStatusCode = statusCode
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        response.statusCode != validStatusCode
    }
}

/// 状态码范围拦截器
///
/// 状态码在指定范围内时缓存。
public struct StatusCodeRangeCacheInterceptor: CacheInterceptor {
    /// 有效的状态码范围
    public let validRange: ClosedRange<Int>

    /// 创建状态码范围拦截器
    /// - Parameter range: 允许缓存的状态码范围，默认 200...299
    public init(range: ClosedRange<Int> = 200 ... 299) {
        validRange = range
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        !validRange.contains(response.statusCode)
    }
}

// MARK: - 允许/禁止所有

/// 允许所有响应缓存的拦截器
///
/// 任何响应都会被缓存，包括错误响应。
/// - Warning: 谨慎使用，可能导致缓存错误数据
public struct AllowAllCacheInterceptor: CacheInterceptor {
    /// 创建允许所有的拦截器
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        false
    }
}

/// 禁止所有响应缓存的拦截器
///
/// 任何响应都不会被缓存。
/// 用于临时禁用缓存或调试。
public struct DenyAllCacheInterceptor: CacheInterceptor {
    /// 创建禁止所有的拦截器
    public init() {}

    public func shouldSkipCache(_ response: Response) -> Bool {
        true
    }
}

// MARK: - 闭包拦截器

/// 闭包缓存拦截器
///
/// 使用闭包自定义缓存逻辑，适用于简单的自定义场景。
///
/// ## 使用示例
/// ```swift
/// let interceptor = BlockCacheInterceptor { response in
///     // 跳过大于 1MB 的响应
///     return response.data.count > 1024 * 1024
/// }
/// ```
public struct BlockCacheInterceptor: CacheInterceptor {
    /// 判断闭包
    private let block: @Sendable (Response) -> Bool

    /// 创建闭包拦截器
    /// - Parameter block: 判断闭包，返回 true 表示跳过缓存
    public init(_ block: @escaping @Sendable (Response) -> Bool) {
        self.block = block
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        // 直接调用闭包，闭包本身不会抛出异常
        return block(response)
    }
}

// MARK: - 组合拦截器

/// 组合缓存拦截器
///
/// 将多个拦截器组合在一起，支持 AND/OR 逻辑。
///
/// ## 使用示例
/// ```swift
/// // AND 逻辑：所有拦截器都允许才缓存
/// let andInterceptor = CompositeCacheInterceptor(
///     interceptors: [StatusCodeCacheInterceptor(), CustomInterceptor()],
///     mode: .allMustAllow
/// )
///
/// // OR 逻辑：任一拦截器允许就缓存
/// let orInterceptor = CompositeCacheInterceptor(
///     interceptors: [Interceptor1(), Interceptor2()],
///     mode: .anyAllows
/// )
/// ```
public struct CompositeCacheInterceptor: CacheInterceptor {
    /// 组合模式
    public enum Mode: Sendable {
        /// 所有拦截器都必须允许缓存（AND 逻辑）
        case allMustAllow
        /// 任一拦截器允许就缓存（OR 逻辑）
        case anyAllows
    }

    /// 内部拦截器列表
    private let interceptors: [any CacheInterceptor]

    /// 组合模式
    private let mode: Mode

    /// 创建组合拦截器
    /// - Parameters:
    ///   - interceptors: 拦截器列表
    ///   - mode: 组合模式，默认 allMustAllow
    public init(interceptors: [any CacheInterceptor], mode: Mode = .allMustAllow) {
        self.interceptors = interceptors
        self.mode = mode
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        guard !interceptors.isEmpty else {
            // 空列表，默认允许缓存
            return false
        }

        switch mode {
        case .allMustAllow:
            // 任一拦截器跳过，就跳过
            return interceptors.contains { $0.shouldSkipCache(response) }

        case .anyAllows:
            // 所有拦截器都跳过，才跳过
            return interceptors.allSatisfy { $0.shouldSkipCache(response) }
        }
    }
}

// MARK: - 条件拦截器

/// 条件缓存拦截器
///
/// 根据条件选择不同的拦截器。
public struct ConditionalCacheInterceptor: CacheInterceptor {
    /// 条件判断闭包
    private let condition: @Sendable (Response) -> Bool

    /// 条件为真时使用的拦截器
    private let trueInterceptor: any CacheInterceptor

    /// 条件为假时使用的拦截器
    private let falseInterceptor: any CacheInterceptor

    /// 创建条件拦截器
    /// - Parameters:
    ///   - condition: 条件判断闭包
    ///   - trueInterceptor: 条件为真时使用的拦截器
    ///   - falseInterceptor: 条件为假时使用的拦截器
    public init(
        condition: @escaping @Sendable (Response) -> Bool,
        trueInterceptor: any CacheInterceptor,
        falseInterceptor: any CacheInterceptor
    ) {
        self.condition = condition
        self.trueInterceptor = trueInterceptor
        self.falseInterceptor = falseInterceptor
    }

    public func shouldSkipCache(_ response: Response) -> Bool {
        if condition(response) {
            return trueInterceptor.shouldSkipCache(response)
        } else {
            return falseInterceptor.shouldSkipCache(response)
        }
    }
}

// MARK: - 便捷扩展

public extension CacheInterceptor {
    /// 组合两个拦截器（AND 逻辑）
    /// - Parameter other: 另一个拦截器
    /// - Returns: 组合后的拦截器
    func and(_ other: any CacheInterceptor) -> CompositeCacheInterceptor {
        CompositeCacheInterceptor(interceptors: [self, other], mode: .allMustAllow)
    }

    /// 组合两个拦截器（OR 逻辑）
    /// - Parameter other: 另一个拦截器
    /// - Returns: 组合后的拦截器
    func or(_ other: any CacheInterceptor) -> CompositeCacheInterceptor {
        CompositeCacheInterceptor(interceptors: [self, other], mode: .anyAllows)
    }
}
