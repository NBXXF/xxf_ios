//
//  Dictionary+XXFUnifed.swift
//  xxf_ios
//  array/set/dict 方法名字趋同
//  Created by xxf on 8/3.
//

public extension Dictionary {
    mutating func remove(_ key: Key) {
        removeValue(forKey: key)
    }

    mutating func removeAll<S: Sequence>(_ keys: S) where S.Element == Key {
        for key in keys {
            removeValue(forKey: key)
        }
    }

    mutating func clear() {
        removeAll()
    }

    /// 插入或更新单个键值对
    mutating func put(key: Key, value: Value) {
        self[key] = value
    }

    /// 批量插入/更新字典内容，key 冲突时取新的值
    mutating func put(contentsOf other: Dictionary) {
        merge(other) { _, new in new }
    }
}
