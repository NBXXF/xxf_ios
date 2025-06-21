//
//  ColumnNameCache.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//

import Foundation

/// 用于缓存不同类型的 Column 名称数组
enum ColumnNameCache {
    private nonisolated(unsafe) static var cache: [ObjectIdentifier: [String]] = [:]
    private static let queue = DispatchQueue(label: "ColumnNameCache.queue", attributes: .concurrent)

    static func columns<K: BaseColumnCodingKey>(for type: K.Type) -> [String] {
        let key = ObjectIdentifier(type)

        // 并发安全读取缓存
        var cached: [String]?
        queue.sync {
            cached = cache[key]
        }
        if let cached = cached {
            return cached
        }

        // 缓存不存在，计算结果
        let result = type.allCases.map { $0.name }

        // 写缓存用 barrier 保证写入原子性
        queue.async(flags: .barrier) {
            cache[key] = result
        }

        return result
    }
}
