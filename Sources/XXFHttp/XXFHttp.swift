//
//  XXFHttp.swift
//  xxf_ios
//  缓存api实例
//  Created by xxf on 5/29.
//

// MARK: - - 继续暴露到引用层

@_exported import Moya
@_exported import RxMoya

import Foundation
import Moya
import RxSwift

public final class XXFHttp: @unchecked Sendable {
    public static let shared = XXFHttp()

    private var pool = [ObjectIdentifier: Any]()
    private let queue = DispatchQueue(label: "com.xxf.providerPool.queue")

    // 对外接口
    public func getApiService<T: TargetType>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)

        return queue.sync {
            if let existing = pool[key] as? MoyaProvider<T> {
                return existing
            }

            let newProvider = MoyaProvider<T>()
            pool[key] = newProvider
            return newProvider
        }
    }

    // 对外接口
    public func getApiService<T: BaseApiService>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)

        return queue.sync {
            if let existing = pool[key] as? MoyaProvider<T> {
                return existing
            }

            let newProvider: MoyaProvider<T> = type.adaptClient()
            pool[key] = newProvider
            return newProvider
        }
    }

    // 移除某个TargetType对应的provider
    public func remove<T: TargetType>(for type: T.Type) -> MoyaProvider<T>? {
        let key = ObjectIdentifier(type)
        return queue.sync {
            pool.removeValue(forKey: key) as? MoyaProvider<T>
        }
    }

    // 清空所有缓存
    public func clear() {
        queue.sync {
            pool.removeAll()
        }
    }
}

/// 增加拓展,业务可直接使用
public extension TargetType {
    @inlinable
    static var apiService: Reactive<MoyaProvider<Self>> {
        return XXFHttp.shared.getApiService(for: Self.self).rx
    }

    @inlinable
    static var rawApiService: MoyaProvider<Self> {
        return XXFHttp.shared.getApiService(for: Self.self)
    }
}

/// 增加拓展,业务可直接使用
public extension BaseApiService {
    @inlinable
    static var apiService: Reactive<MoyaProvider<Self>> {
        return XXFHttp.shared.getApiService(for: Self.self).rx
    }

    @inlinable
    static var rawApiService: MoyaProvider<Self> {
        return XXFHttp.shared.getApiService(for: Self.self)
    }
}
