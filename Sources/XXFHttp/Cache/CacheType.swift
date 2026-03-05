//
//  CacheType.swift
//  xxf_ios
//
//  网络请求缓存策略枚举
//
//  缓存策略说明:
//  ┌─────────────┬─────────────────────────────────────────────────────────┐
//  │ 策略         │ 行为                                                    │
//  ├─────────────┼─────────────────────────────────────────────────────────┤
//  │ firstCache  │ 先返回缓存，再请求网络（可能发射 1-2 次）                 │
//  │ firstRemote │ 先请求网络，失败时回退缓存                                │
//  │ onlyRemote  │ 只走网络，不使用缓存（默认行为）                          │
//  │ onlyCache   │ 只读缓存，没有缓存则 empty()                              │
//  │ ifCache     │ 有缓存用缓存，无缓存走网络                                │
//  │ lastCache   │ 返回缓存后静默更新网络（有缓存时只发射一次）              │
//  └─────────────┴─────────────────────────────────────────────────────────┘
//
//  使用场景:
//  - firstCache: 列表页，需要快速展示旧数据
//  - firstRemote: 详情页，优先展示最新数据
//  - onlyRemote: 实时数据，如股票价格
//  - onlyCache: 离线模式
//  - ifCache: 配置数据，变化不频繁
//  - lastCache: 用户信息，后台静默更新
//
//  Created by xxf on 2025/3/4.
//

import Foundation

// MARK: - 缓存策略

/// 网络请求缓存策略
///
/// 通过关联值配置缓存有效期和自定义缓存 key。
/// 在 `RestApiService` 中通过 `cacheConfig` 属性返回对应的策略。
///
/// ## 使用示例
/// ```swift
/// enum UserAPI: RestApiService {
///     case getUserInfo(id: String)
///
///     var cacheConfig: CacheType {
///         switch self {
///         case .getUserInfo:
///             // 先返回缓存，再请求网络，缓存1小时
///             return .firstCache(maxAge: 3600)
///         }
///     }
/// }
/// ```
public enum CacheType: Sendable {
    // MARK: - Constants

    /// 默认缓存有效期：3天
    public static let defaultMaxAge: TimeInterval = 3 * 24 * 60 * 60

    /// 短期缓存有效期：1小时
    public static let shortMaxAge: TimeInterval = 60 * 60

    /// 长期缓存有效期：30天
    public static let longMaxAge: TimeInterval = 30 * 24 * 60 * 60

    // MARK: - Cases

    /// 先从本地缓存获取，然后从服务器获取
    ///
    /// 可能会 onNext 两次（先缓存后网络）。
    /// 如果本地没有缓存，最少执行 onNext 一次。
    /// 适用于需要快速展示旧数据的列表页。
    ///
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认3天
    ///   - key: 自定义缓存 key，默认自动生成
    case firstCache(maxAge: TimeInterval = CacheType.defaultMaxAge, key: String? = nil)

    /// 先从服务器获取，网络失败时读取本地缓存
    ///
    /// 优先展示最新数据，网络异常时降级使用缓存。
    /// 适用于需要最新数据但又不能完全离线的场景。
    ///
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认3天
    ///   - key: 自定义缓存 key，默认自动生成
    case firstRemote(maxAge: TimeInterval = CacheType.defaultMaxAge, key: String? = nil)

    /// 只从服务器获取（默认行为，不使用缓存）
    ///
    /// 每次都请求网络，不读取也不写入缓存。
    /// 适用于实时性要求高的数据。
    case onlyRemote

    /// 只从本地缓存获取，没有缓存执行逻辑同 Observable.empty()
    ///
    /// 不发起网络请求，只读取本地缓存。
    /// 适用于离线模式或预加载检查。
    ///
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认3天
    ///   - key: 自定义缓存 key，默认自动生成
    case onlyCache(maxAge: TimeInterval = CacheType.defaultMaxAge, key: String? = nil)

    /// 如果本地存在缓存就返回本地的，否则返回网络的数据
    ///
    /// 只发射一次，有缓存用缓存，无缓存走网络。
    /// 适用于变化不频繁的配置数据。
    ///
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认3天
    ///   - key: 自定义缓存 key，默认自动生成
    case ifCache(maxAge: TimeInterval = CacheType.defaultMaxAge, key: String? = nil)

    /// 读取上次的缓存，有缓存返回缓存并静默更新网络
    ///
    /// 有缓存时只发射一次（缓存），同时在后台静默请求网络更新缓存。
    /// 无缓存时发射网络响应。
    /// 适用于用户信息等需要后台更新的数据。
    ///
    /// - Parameters:
    ///   - maxAge: 缓存有效期（秒），默认3天
    ///   - key: 自定义缓存 key，默认自动生成
    case lastCache(maxAge: TimeInterval = CacheType.defaultMaxAge, key: String? = nil)
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
            // 确保返回有效的正数
            return max(0, maxAge)
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
            // 空字符串视为 nil
            return key?.isEmpty == true ? nil : key
        }
    }

    /// 是否需要缓存
    ///
    /// 返回 `true` 表示该策略会使用缓存（读或写）
    var needsCache: Bool {
        switch self {
        case .onlyRemote:
            return false
        default:
            return true
        }
    }

    /// 是否会读取缓存
    var readsCache: Bool {
        switch self {
        case .onlyRemote:
            return false
        default:
            return true
        }
    }

    /// 是否会写入缓存
    var writesCache: Bool {
        switch self {
        case .onlyRemote, .onlyCache:
            return false
        default:
            return true
        }
    }

    /// 策略的简短描述
    var description: String {
        switch self {
        case .firstCache:
            return "firstCache"
        case .firstRemote:
            return "firstRemote"
        case .onlyRemote:
            return "onlyRemote"
        case .onlyCache:
            return "onlyCache"
        case .ifCache:
            return "ifCache"
        case .lastCache:
            return "lastCache"
        }
    }
}

// MARK: - 便捷工厂方法

public extension CacheType {
    /// 创建 1 小时有效期的 firstCache 策略
    static var firstCacheShort: CacheType {
        .firstCache(maxAge: shortMaxAge)
    }

    /// 创建 30 天有效期的 firstCache 策略
    static var firstCacheLong: CacheType {
        .firstCache(maxAge: longMaxAge)
    }

    /// 创建 1 小时有效期的 ifCache 策略
    static var ifCacheShort: CacheType {
        .ifCache(maxAge: shortMaxAge)
    }

    /// 创建 30 天有效期的 ifCache 策略
    static var ifCacheLong: CacheType {
        .ifCache(maxAge: longMaxAge)
    }
}

// MARK: - Equatable

extension CacheType: Equatable {
    public static func == (lhs: CacheType, rhs: CacheType) -> Bool {
        switch (lhs, rhs) {
        case (.onlyRemote, .onlyRemote):
            return true
        case let (.firstCache(lhsAge, lhsKey), .firstCache(rhsAge, rhsKey)):
            return lhsAge == rhsAge && lhsKey == rhsKey
        case let (.firstRemote(lhsAge, lhsKey), .firstRemote(rhsAge, rhsKey)):
            return lhsAge == rhsAge && lhsKey == rhsKey
        case let (.onlyCache(lhsAge, lhsKey), .onlyCache(rhsAge, rhsKey)):
            return lhsAge == rhsAge && lhsKey == rhsKey
        case let (.ifCache(lhsAge, lhsKey), .ifCache(rhsAge, rhsKey)):
            return lhsAge == rhsAge && lhsKey == rhsKey
        case let (.lastCache(lhsAge, lhsKey), .lastCache(rhsAge, rhsKey)):
            return lhsAge == rhsAge && lhsKey == rhsKey
        default:
            return false
        }
    }
}
