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
import XXFFoundation

public final class XXFHttp: @unchecked Sendable {
    public static let shared = XXFHttp()

    private var pool = ConcurrentDictionary<ObjectIdentifier, Any>()

    // 对外接口
    public func getApiService<T: TargetType>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)

        if let existing = pool[key] as? HttpMoyaProvider<T> {
            return existing
        }
        let newProvider = HttpMoyaProvider<T>()
        pool[key] = newProvider
        return newProvider
    }

    // 对外接口
    public func getApiService<T: BaseApiService>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)

        if let existing = pool[key] as? HttpMoyaProvider<T> {
            return existing
        }

        let newProvider: HttpMoyaProvider<T> = type.adaptClient()
        pool[key] = newProvider
        return newProvider
    }

    // 移除某个TargetType对应的provider
    public func remove<T: TargetType>(for type: T.Type) -> MoyaProvider<T>? {
        let key = ObjectIdentifier(type)
        return pool.remove(key) as? HttpMoyaProvider<T>
    }

    // 清空所有缓存
    public func clear() {
        pool.removeAll()
    }
}

/// 增加拓展,业务可直接使用
public extension TargetType {
    @inlinable
    static var apiService: ReactiveProxy<MoyaProvider<Self>> {
        return XXFHttp.shared.getApiService(for: Self.self).rxProxy
    }

    @inlinable
    static var rawApiService: MoyaProvider<Self> {
        return XXFHttp.shared.getApiService(for: Self.self)
    }
}

/// 增加拓展,业务可直接使用
public extension BaseApiService {
    @inlinable
    static var apiService: ReactiveProxy<MoyaProvider<Self>> {
        return XXFHttp.shared.getApiService(for: Self.self).rxProxy
    }

    @inlinable
    static var rawApiService: MoyaProvider<Self> {
        return XXFHttp.shared.getApiService(for: Self.self)
    }
}
