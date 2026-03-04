//
//  HttpCache.swift
//  xxf_ios
//
//  Created by xxf on 2026/3/4.
//

import Foundation
import Moya
import XXFSpeed

/// 网络响应缓存条目
public struct CacheEntry: @unchecked Sendable {
    public let response: Response
    public let cachedAt: Date

    public init(response: Response, cachedAt: Date = Date()) {
        self.response = response
        self.cachedAt = cachedAt
    }

    /// 检查缓存是否在有效期内
    public func isValid(maxAge: TimeInterval) -> Bool {
        guard maxAge.isFinite else { return true }
        return Date().timeIntervalSince(cachedAt) < maxAge
    }
}

/// HTTP 缓存管理器
/// 基于 LRU 缓存的纯存储层
public final class HttpCache: @unchecked Sendable {
    public static let shared = HttpCache()

    private let cache: LRUCache<String, CacheEntry>

    /// 初始化缓存
    /// - Parameters:
    ///   - countLimit: 最大缓存数量，默认 512
    ///   - totalCostLimit: 最大缓存容量（字节），默认 256MB
    public init(countLimit: Int = 512, totalCostLimit: Int = 256 * 1024 * 1024) {
        cache = LRUCache(totalCostLimit: totalCostLimit, countLimit: countLimit)
    }

    // MARK: - 读取

    /// 读取缓存
    public func get(forKey key: String, maxAge: TimeInterval = .infinity) -> Response? {
        guard let entry = cache.value(forKey: key) else {
            return nil
        }
        guard entry.isValid(maxAge: maxAge) else {
            cache.removeValue(forKey: key)
            return nil
        }
        return entry.response
    }

    /// 检查缓存是否存在且有效
    public func contains(forKey key: String, maxAge: TimeInterval = .infinity) -> Bool {
        get(forKey: key, maxAge: maxAge) != nil
    }

    // MARK: - 写入

    /// 写入缓存（通过拦截器判断是否缓存）
    public func set(_ response: Response, forKey key: String, interceptor: any CacheInterceptor) {
        guard !interceptor.shouldSkipCache(response) else { return }
        forceSet(response, forKey: key)
    }

    /// 强制写入缓存（不经过拦截器）
    public func forceSet(_ response: Response, forKey key: String) {
        let entry = CacheEntry(response: response)
        let cost = response.data.count
        cache.setValue(entry, forKey: key, cost: cost)
    }

    // MARK: - 删除

    /// 移除缓存
    @discardableResult
    public func remove(forKey key: String) -> Response? {
        cache.removeValue(forKey: key)?.response
    }

    /// 清空所有缓存
    public func removeAll() {
        cache.removeAllValues()
    }

    // MARK: - 信息

    /// 当前缓存数量
    public var count: Int { cache.count }

    /// 当前缓存总大小（字节）
    public var totalCost: Int { cache.totalCost }
}
