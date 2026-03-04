//
//  CacheType.swift
//  xxf_ios
//
//  Created by xxf on 2025/3/4.
//

import Foundation

/// 网络请求缓存策略
/// 通过关联值配置缓存有效期和自定义缓存 key
public enum CacheType: Sendable {
    /// 先从本地缓存拿取，然后从服务器拿取
    /// 可能会 onNext 两次，如果本地没有缓存最少执行 onNext 一次
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认无限
    ///   - key: 自定义缓存 key，默认自动生成
    case firstCache(maxAge: TimeInterval = .infinity, key: String? = nil)

    /// 先从服务器获取，没有网络读取本地缓存
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认无限
    ///   - key: 自定义缓存 key，默认自动生成
    case firstRemote(maxAge: TimeInterval = .infinity, key: String? = nil)

    /// 只从服务器拿取（默认行为，不使用缓存）
    case onlyRemote

    /// 只从本地缓存中拿取，没有缓存执行逻辑同 Observable.empty()
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认无限
    ///   - key: 自定义缓存 key，默认自动生成
    case onlyCache(maxAge: TimeInterval = .infinity, key: String? = nil)

    /// 如果本地存在就返回本地的，否则返回网络的数据
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认无限
    ///   - key: 自定义缓存 key，默认自动生成
    case ifCache(maxAge: TimeInterval = .infinity, key: String? = nil)

    /// 读取上次的缓存，上次没有缓存就返回网络的数据，然后同步缓存；
    /// 上次有缓存，也会同步网络数据但不会 onNext
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认无限
    ///   - key: 自定义缓存 key，默认自动生成
    case lastCache(maxAge: TimeInterval = .infinity, key: String? = nil)
}

// MARK: - 便捷属性

public extension CacheType {
    /// 获取缓存有效期
    var maxAge: TimeInterval {
        switch self {
        case .onlyRemote:
            return 0
        case let .firstCache(maxAge, _),
             let .firstRemote(maxAge, _),
             let .onlyCache(maxAge, _),
             let .ifCache(maxAge, _),
             let .lastCache(maxAge, _):
            return maxAge
        }
    }

    /// 获取自定义缓存 key（如果有）
    var customKey: String? {
        switch self {
        case .onlyRemote:
            return nil
        case let .firstCache(_, key),
             let .firstRemote(_, key),
             let .onlyCache(_, key),
             let .ifCache(_, key),
             let .lastCache(_, key):
            return key
        }
    }

    /// 是否需要缓存
    var needsCache: Bool {
        switch self {
        case .onlyRemote:
            return false
        default:
            return true
        }
    }
}
