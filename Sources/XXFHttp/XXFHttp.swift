//
//  XXFHttp.swift
//  xxf_ios
//  缓存api实例
//  Created by xxf on 2025/5/29.
//

import Foundation
import Moya

public final class XXFHttp: @unchecked Sendable {
    static let shared = XXFHttp()

    private var pool = [ObjectIdentifier: Any]()
    private let queue = DispatchQueue(label: "com.xxf.providerPool.queue")

    func getApiService<T: TargetType>(for type: T.Type) -> MoyaProvider<T> {
        let key = ObjectIdentifier(type)
        return queue.sync {
            if let existing = pool[key] as? MoyaProvider<T> {
                return existing
            } else {
                let newProvider = MoyaProvider<T>()
                pool[key] = newProvider
                return newProvider
            }
        }
    }

    // 移除某个TargetType对应的provider
    func remove<T: TargetType>(for type: T.Type) {
        let key = ObjectIdentifier(type)
        _ = queue.sync {
            pool.removeValue(forKey: key)
        }
    }

    // 清空所有缓存
    func clear() {
        queue.sync {
            pool.removeAll()
        }
    }
}

/// 增加拓展,业务可直接使用
public extension TargetType {
    static var apiService: MoyaProvider<Self> {
        return XXFHttp.shared.getApiService(for: Self.self)
    }
}
