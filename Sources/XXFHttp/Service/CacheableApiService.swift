//
//  CacheableApiService.swift
//  xxf_ios
//
//  可缓存 API 服务协议
//
//  功能说明:
//  定义 API 服务的缓存相关配置，包括拦截器、缓存策略和缓存实例。
//  业务方可以通过重写这些属性来自定义缓存行为。
//
//  ┌─────────────────────────────────────────────────────────────────┐
//  │                    CacheableApiService                          │
//  ├─────────────────────────────────────────────────────────────────┤
//  │ cacheInterceptor  │ 决定响应是否应被缓存（类级别）              │
//  │ httpCache         │ 使用的缓存实例（类级别，可自定义）          │
//  │ cachePolicy       │ 缓存策略（实例级别，每个接口可不同）        │
//  └─────────────────────────────────────────────────────────────────┘
//
//  Created by xxf on 3/4.
//

// MARK: - 可缓存 API 服务协议

/// 可缓存 API 服务协议
///
/// 定义 API 服务的缓存相关配置。实现此协议的 API 服务可以使用 HTTP 缓存功能。
///
/// ## 自定义缓存行为
///
/// ### 1. 自定义缓存拦截器
/// ```swift
/// enum MyApiService: RestApiService {
///     static var cacheInterceptor: any CacheInterceptor {
///         StatusCodeRangeCacheInterceptor(range: 200...299)
///     }
/// }
/// ```
///
/// ### 2. 自定义缓存实例（用于业务隔离）
/// ```swift
/// enum MyApiService: RestApiService {
///     static var httpCache: HttpCache {
///         HttpCache(config: HttpCacheConfig(
///             memoryCountLimit: 100,
///             memoryCostLimit: 16 * 1024 * 1024,
///             diskCacheName: "MyBusinessCache"
///         ))
///     }
/// }
/// ```
///
/// ### 3. 自定义缓存策略
/// ```swift
/// enum MyApiService: RestApiService {
///     case getUserInfo(id: Int)
///
///     var cachePolicy: CacheType {
///         switch self {
///         case .getUserInfo:
///             return .firstCache(maxAge: 3600)  // 先读缓存，1小时有效
///         }
///     }
/// }
/// ```
public protocol CacheableApiService {
    /// 缓存拦截器：决定是否跳过缓存
    ///
    /// 默认使用 `DefaultCacheInterceptor`（statusCode == 200 且 Content-Type 为 JSON）
    ///
    /// - Note: 这是类级别的配置，同一 API 服务的所有接口共享相同的拦截器
    static var cacheInterceptor: any CacheInterceptor { get }

    /// HTTP 缓存实例
    ///
    /// 默认使用 `HttpCache.shared` 全局共享实例。
    /// 业务方可以重写此属性来使用独立的缓存实例，实现缓存隔离。
    ///
    /// ## 使用场景
    /// - 不同业务模块需要独立的缓存空间
    /// - 需要不同的缓存配置（如内存大小、磁盘路径等）
    /// - 测试环境需要隔离的缓存实例
    ///
    /// - Note: 这是类级别的配置，同一 API 服务的所有接口共享相同的缓存实例
    /// - Important: 自定义实例需要业务方自行管理生命周期
    static var httpCache: HttpCache { get }

    /// 缓存策略，包含缓存模式、有效期和可选的自定义 key
    ///
    /// 默认 `.onlyRemote`（不使用缓存）
    ///
    /// - Note: 这是实例级别的配置，每个接口可以有不同的缓存策略
    /// - SeeAlso: `CacheType` 了解所有可用的缓存策略
    var cachePolicy: CacheType { get }
}
