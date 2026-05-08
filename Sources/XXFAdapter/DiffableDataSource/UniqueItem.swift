//
//  UniqueItem.swift
//  xxf_ios
//  无缝支持用了UICollectionViewDiffableDataSource 且又数据重复的,无缝替换
//  Created by xxf on 5/7.
//

import Foundation

public final class UniqueItem<Value: Hashable>: Hashable, @unchecked Sendable {
    public let id: String
    public var value: Value

    public init(id: String = UUID().uuidString, value: Value) {
        self.id = id
        self.value = value
    }

    /// 用随机id 来标识
    public static func wrap(_ items: [Value]) -> [UniqueItem<Value>] {
        items.map { UniqueItem<Value>(value: $0) }
    }

    /// 用index位置来标识
    public static func wrapWithIndex(_ items: [Value]) -> [UniqueItem<Value>] {
        items.enumerated().map { index, item in
            UniqueItem<Value>(id: String(index), value: item)
        }
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(value)
    }

    public static func == (lhs: UniqueItem, rhs: UniqueItem) -> Bool {
        lhs.id == rhs.id && lhs.value == rhs.value
    }
}
