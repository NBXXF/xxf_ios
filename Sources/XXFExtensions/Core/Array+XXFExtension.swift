//
//  Array+XXFExtension.swift
//  xxf_ios
//  数组拓展
//  Created by xxf on 7/7.
//

import Foundation

public extension Array {
    /// 类似 Kotlin 的 mapNotNull，映射并过滤 nil
    func mapNotNil<T>(_ transform: (Element) -> T?) -> [T] {
        compactMap(transform)
    }

    /// Kotlin: associateBy { it.id } — 默认保留最后一个（覆盖重复 key）
    func associateBy<K: Hashable>(_ keySelector: (Element) -> K) -> [K: Element] {
        var result: [K: Element] = [:]
        for element in self {
            result[keySelector(element)] = element
        }
        return result
    }

    /// Kotlin: associateBy { it.id } — 保留第一个（不覆盖重复 key）
    func associateByFirst<K: Hashable>(_ keySelector: (Element) -> K) -> [K: Element] {
        var result: [K: Element] = [:]
        for element in self {
            let key = keySelector(element)
            if result[key] == nil {
                result[key] = element
            }
        }
        return result
    }

    /// Kotlin: associate { it.id to it.name } — 默认保留最后一个（覆盖）
    func associate<K: Hashable, V>(_ transform: (Element) -> (K, V)) -> [K: V] {
        var result: [K: V] = [:]
        for element in self {
            let (key, value) = transform(element)
            result[key] = value
        }
        return result
    }

    /// Kotlin: associateWith { it.name } — Element 作为 key，覆盖重复 key
    func associateWith<V>(_ valueSelector: (Element) -> V) -> [Element: V] where Element: Hashable {
        var result: [Element: V] = [:]
        for element in self {
            result[element] = valueSelector(element)
        }
        return result
    }

    /// Kotlin: groupBy { it.id }
    func groupBy<K: Hashable>(_ keySelector: (Element) -> K) -> [K: [Element]] {
        Dictionary(grouping: self, by: keySelector)
    }

    /// Kotlin: associateByGroup { it.id }（同 groupBy）
    func associateByGroup<K: Hashable>(_ keySelector: (Element) -> K) -> [K: [Element]] {
        groupBy(keySelector)
    }
}
