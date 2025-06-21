//
//  ColumnCache.swift
//  xxf_ios
//
//  Created by trl on 2025/6/21.
//

import Foundation
import GRDB
import XXFDatabase

/// 用于缓存不同类型的 Column 数组
enum ColumnCache {
    private nonisolated(unsafe) static var cache: [ObjectIdentifier: [Column]] = [:]
    private static let lock = NSLock()

    static func columns<K: BaseColumnCodingKey>(for type: K.Type) -> [Column] {
        let key = ObjectIdentifier(type)

        lock.lock()
        defer { lock.unlock() }

        if let cached = cache[key] {
            return cached
        }

        let result = type.allCases.map { $0.column }
        cache[key] = result
        return result
    }
}
