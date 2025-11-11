//
//  Dictionary+ValueCollection.swift
//  xxf_ios
//
//  Created by xxf on 8/7.
//
public extension Dictionary where Value: Collection {
    /// 移除value空数组
    mutating func removeEmptyValues() {
        for (key, value) in self where value.isEmpty {
            self.removeValue(forKey: key)
        }
    }
}
