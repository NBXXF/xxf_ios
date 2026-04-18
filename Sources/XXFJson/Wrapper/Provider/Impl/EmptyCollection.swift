//
//  EmptyCollection.swift
//  xxf_ios
//
//  集合类型的内置默认值 Provider
//
//  Created by xxf
//

import Foundation

/// 空数组默认值：`[]`
///
/// ```swift
/// @CodingDefault<EmptyArray<String>> var tags: [String]
/// @CodingDefault<EmptyArray<Product>> var products: [Product]
/// ```
public enum EmptyArray<Element: Codable>: CodingDefaultValueProvider {
    public static var defaultValue: [Element] { [] }
}

/// 空字典默认值：`[:]`
///
/// ```swift
/// @CodingDefault<EmptyDict<String, String>> var extras: [String: String]
/// ```
public enum EmptyDict<Key: Hashable & Codable, Value: Codable>: CodingDefaultValueProvider {
    public static var defaultValue: [Key: Value] { [:] }
}

/// 空 Set 默认值：`[]`
///
/// ```swift
/// @CodingDefault<EmptySet<Int>> var userIds: Set<Int>
/// ```
public enum EmptySet<Element: Hashable & Codable>: CodingDefaultValueProvider {
    public static var defaultValue: Set<Element> { [] }
}
