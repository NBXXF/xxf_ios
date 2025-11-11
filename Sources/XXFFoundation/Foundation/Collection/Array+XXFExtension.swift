//
//  Array+XXFExtension.swift
//  xxf_ios
//  数组拓展
//  Created by xxf on 7/7.
//

import Collections
import Foundation

public extension Array {
    // MARK: 过滤nil

    /// 类似 Kotlin 的 mapNotNull，映射并过滤 nil
    func mapNotNil<T>(_ transform: (Element) -> T?) -> [T] {
        compactMap(transform)
    }

    // MARK: 安全处理角标,swifterSwift 官方有 arr[safe: 1]

    /// 安全获取元素，越界返回 nil
    func getOrNil(_ index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }

    /// 安全获取元素，越界返回默认值
    func at(_ index: Int, default defaultValue: Element) -> Element {
        getOrNil(index) ?? defaultValue
    }

    // MARK: 转字典

    /// Kotlin: associateBy { it.id } — 默认保留最后一个（覆盖重复 key）
    func associateBy<K: Hashable>(_ keySelector: (Element) -> K) -> [K: Element] {
        var result: [K: Element] = [:]
        for element in self {
            result[keySelector(element)] = element
        }
        return result
    }

    /// Kotlin: associateBy(keySelector, valueTransform) — 默认保留最后一个（覆盖重复 key）
    func associateBy<K: Hashable, V>(
        keySelector: (Element) -> K,
        valueTransform: (Element) -> V
    ) -> [K: V] {
        var result: [K: V] = [:]
        for element in self {
            let key = keySelector(element)
            let value = valueTransform(element)
            result[key] = value
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

    // MARK: 分组

    /// 根据给定的键选择器对集合中的元素进行分组。
    ///
    /// 该方法使用标准库的 `Dictionary(grouping:by:)`，
    /// 根据闭包 `keySelector` 从元素中提取键（Key），
    /// 将所有具有相同键的元素归为一组，
    /// 返回一个无序的字典，其中键对应分组的键，值是该键对应的元素数组。
    ///
    /// - Parameter keySelector: 一个闭包，用于从元素中提取键。
    /// - Returns: 一个字典 `[K: [Element]]`，
    ///   键为提取的键，值为对应键的所有元素数组。
    ///
    /// - 注意：
    /// 返回的字典是无序的，即键的顺序是不确定的。
    /// 如果需要保持分组键的顺序，请使用有序版本的 `groupByOrdered`。
    func groupBy<K: Hashable>(_ keySelector: (Element) -> K) -> [K: [Element]] {
        Dictionary(grouping: self, by: keySelector)
    }

    /// 根据给定的键选择器对集合中的元素进行分组，并允许对分组的值进行映射。
    ///
    /// 该方法使用标准库的 `Dictionary(grouping:by:)`，
    /// 根据闭包 `keySelector` 从元素中提取键（Key），
    /// 将所有具有相同键的元素归为一组，然后对分组中的值使用 `valueTransform` 转换。
    ///
    /// - Parameters:
    ///   - keySelector: 一个闭包，用于从元素中提取键。
    ///   - valueTransform: 一个闭包，用于将每个元素映射为新的值类型。
    /// - Returns: 一个字典 `[K: [V]]`，
    ///   键为提取的键，值为经过转换后的元素数组。
    ///
    /// - 注意：
    /// 返回的字典是无序的，即键的顺序是不确定的。
    /// 如果需要保持分组键的顺序，请使用有序版本的 `groupByOrdered`。
    func groupBy<K: Hashable, V>(_ keySelector: (Element) -> K,
                                 valueTransform: (Element) -> V) -> [K: [V]]
    {
        Dictionary(grouping: self, by: keySelector)
            .mapValues { $0.map(valueTransform) }
    }

    /// 按照元素出现的顺序进行分组，返回一个保持插入顺序的有序字典。
    ///
    /// 该方法根据 `keySelector` 提取每个元素的键，
    /// 将具有相同键的元素归为一组，且分组顺序与第一次出现的键的顺序保持一致。
    ///
    /// - Parameter keySelector: 一个闭包，用于从元素中提取键（Key）。
    /// - Returns: 一个 `OrderedDictionary`，键是提取的键，值是对应键的元素数组，且键的顺序与元素首次出现时相同。
    ///
    /// - 注意：
    /// `K` 只需遵守 `Hashable`，无需实现 `Comparable`，
    /// 因为这里的排序是基于元素首次出现的顺序，而非键的自然顺序。
    func groupByOrdered<K: Hashable>(_ keySelector: (Element) -> K) -> OrderedDictionary<K, [Element]> {
        var result = OrderedDictionary<K, [Element]>()
        for element in self {
            let key = keySelector(element)
            if result[key] == nil {
                result[key] = [element]
            } else {
                result[key]!.append(element)
            }
        }
        return result
    }

    /// 按照键的自然顺序（升序）进行分组，返回一个按键排序的有序字典。
    ///
    /// 该方法根据 `keySelector` 提取每个元素的键，
    /// 将具有相同键的元素归为一组，
    /// 并且最终结果中的键会按照升序排列。
    ///
    /// - Parameter keySelector: 一个闭包，用于从元素中提取键（Key）。
    /// - Returns: 一个 `OrderedDictionary`，键是提取的键，值是对应键的元素数组，键的顺序为升序排列。
    ///
    /// - 注意：
    /// `K` 需要同时遵守 `Hashable` 和 `Comparable`，
    /// 以便对键进行排序。
    func groupBySortedKey<K: Hashable & Comparable>(_ keySelector: (Element) -> K) -> OrderedDictionary<K, [Element]> {
        var map = [K: [Element]]()
        for element in self {
            let key = keySelector(element)
            map[key, default: []].append(element)
        }
        let sortedKeys = map.keys.sorted()
        return OrderedDictionary(uniqueKeysWithValues: sortedKeys.map { ($0, map[$0]!) })
    }

    /// 按指定顺序的 keys 分组并展平，支持自定义返回元素类型（可混合分组标题和元素）
    ///
    /// - Parameters:
    ///   - keys: 分组顺序列表，结果顺序严格按照此顺序
    ///   - keySelector: 从元素选取分组 key
    ///   - makeSection: 根据 key 和分组元素生成自定义类型数组（比如插入分组标题）
    /// - Returns: 扁平化数组，元素类型为泛型 R，空分组会被过滤掉
    func groupByOrderedFlat<K: Hashable, R>(
        keys: [K],
        keySelector: (Element) -> K,
        makeSection: @escaping (K, [Element]) -> [R]
    ) -> [R] {
        let keySet = Set(keys)
        var ordered = OrderedDictionary<K, [Element]>(minimumCapacity: keys.count)
        for key in keys {
            ordered[key] = []
        }

        for element in self {
            let key = keySelector(element)
            guard keySet.contains(key) else { continue }
            ordered[key, default: []].append(element)
        }

        return ordered.lazy
            .filter { !$0.value.isEmpty }
            .flatMap { makeSection($0.key, $0.value) }
            .map { $0 } // 转换为 Array 返回
    }

    /// Kotlin: associateByGroup { it.id }（同 groupBy）
    func associateByGroup<K: Hashable>(_ keySelector: (Element) -> K) -> [K: [Element]] {
        groupBy(keySelector)
    }

    /// Returns a new array, sorted stably according to the given predicate.
    ///
    /// - 中文说明: 稳定排序。和标准库 `sorted(by:)` 不同，
    ///   该方法在元素相等时会保留原始顺序，确保排序结果稳定。
    ///
    /// If two elements are considered equal, their relative order is preserved.
    ///
    /// - Parameter areInIncreasingOrder: A predicate that returns true if its first
    ///   argument should be ordered before its second argument; otherwise, false.
    ///   当返回 `true` 时，表示第一个元素应该排在第二个元素之前。
    ///
    /// - Returns: A new array of the elements of the sequence, sorted stably.
    ///   返回一个新的数组，元素按稳定排序后的顺序排列。
    @inlinable
    func sortedStable(
        by areInIncreasingOrder: (Element, Element) throws -> Bool
    ) rethrows -> [Element] {
        return try enumerated().sorted { lhs, rhs in
            let ab = try areInIncreasingOrder(lhs.element, rhs.element)
            if ab { return true }
            let ba = try areInIncreasingOrder(rhs.element, lhs.element)
            if ba { return false }
            // 相等时保持原始顺序
            return lhs.offset < rhs.offset

        }.map { $0.element }
    }
}
