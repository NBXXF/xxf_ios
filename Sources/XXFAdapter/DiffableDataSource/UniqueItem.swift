//
//  UniqueItem.swift
//  xxf_ios
//  无缝支持用了UICollectionViewDiffableDataSource 且又数据重复的,无缝替换
//  Created by xxf on 5/7.
//

import Foundation

public final class UniqueItem<Value: Hashable>: NSObject, Hashable {
    public let id: UUID
    public var value: Value

    public init(value: Value) {
        self.id = UUID()
        self.value = value
        super.init()
    }

    public static func wrap(_ items: [Value]) -> [UniqueItem] {
        items.map { UniqueItem(value: $0) }
    }

    // MARK: - Hashable

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: UniqueItem, rhs: UniqueItem) -> Bool {
        lhs.id == rhs.id
    }
}
