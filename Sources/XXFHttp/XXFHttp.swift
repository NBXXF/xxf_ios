//
//  XXFHttp.swift
//  xxf_ios
//  缓存api实例
//  Created by xxf on /5/29.
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

    /// 通过重载函数实现类型约束判断：在这里自动调用 createProvider()
    private func _createIfAnnotated<T: TargetType>(_ type: T.Type) -> MoyaProvider<T> {
        _createIfAnnotated_impl(type)
    }

    // MARK: - Annotated 版本：符合 UserClientAdapterAnnotatable 的类型

    private func _createIfAnnotated_impl<T: TargetType & UserClientAdapterAnnotatable>(_: T.Type) -> MoyaProvider<T> {
        return T.adaptClient()
    }

    // MARK: - 默认版本：不符合 Annotatable 的类型

    private func _createIfAnnotated_impl<T: TargetType>(_: T.Type) -> MoyaProvider<T> {
        return MoyaProvider<T>()
    }

    // 对外接口
    public func getApiService<T: TargetType>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)

        return queue.sync {
            if let existing = pool[key] as? MoyaProvider<T> {
                return existing
            }

            let newProvider: MoyaProvider<T> = _createIfAnnotated(T.self)
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
}
