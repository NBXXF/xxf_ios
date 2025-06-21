//
//  ColumnCache.swift
//  xxf_ios
//
//  Created by xxf on 6/21.
//

import Foundation
import GRDB
import XXFDatabase

/// 用于缓存 Column 数组
enum ColumnCache {
    private nonisolated(unsafe) static var cache: [ObjectIdentifier: [Column]] = [:]
    private static let queue = DispatchQueue(label: "ColumnCache.queue", attributes: .concurrent)

    static func columns<K: BaseColumnCodingKey>(for type: K.Type) -> [Column] {
        let key = ObjectIdentifier(type)

        // 并发安全读取缓存
        var cached: [Column]?
        queue.sync {
            cached = cache[key]
        }
        if let cached = cached {
            return cached
        }

        // 缓存不存在，计算结果
        let result = type.allCases.map { $0.column }

        // 写缓存用 barrier 保证写入的原子性和线程安全
        queue.async(flags: .barrier) {
            cache[key] = result
        }

        return result
    }
}
