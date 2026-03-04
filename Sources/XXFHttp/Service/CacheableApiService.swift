//
//  CacheableApiService.swift
//  xxf_ios
//
//  Created by xxf on 3/4.
//

public protocol CacheableApiService {
    /// 缓存拦截器：决定是否跳过缓存
    /// 默认使用 DefaultCacheInterceptor（statusCode == 200 且 Content-Type 为 JSON）
    static var cacheInterceptor: any CacheInterceptor { get }

    /// 缓存配置，包含缓存策略、有效期和可选的自定义 key
    /// 默认 .onlyRemote（不使用缓存）
    var cacheConfig: CacheType { get }
}
