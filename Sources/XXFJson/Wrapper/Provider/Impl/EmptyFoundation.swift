//
//  EmptyFoundation.swift
//  xxf_ios
//
//  Foundation 常用类型的内置默认值 Provider
//
//  Created by xxf
//

import Foundation

// MARK: - URL

/// 可选 URL 默认值：`nil`
///
/// ```swift
/// @CodingDefault<EmptyURL> var avatar: URL?
/// ```
///
/// - Note: URL 没有"空 URL"的合理概念（`URL(string: "")` 返回 nil），
///   所以 Provider.Value 是 `URL?`，默认为 `nil`
public enum EmptyURL: CodingDefaultValueProvider {
    public static let defaultValue: URL? = nil
}

// MARK: - UUID

/// UUID 默认值：全零 UUID（`00000000-0000-0000-0000-000000000000`）
///
/// 业界常用的 "null UUID"，适合没有值时的占位符。
///
/// ```swift
/// @CodingDefault<EmptyUUID> var id: UUID
/// ```
public enum EmptyUUID: CodingDefaultValueProvider {
    public static let defaultValue: UUID = UUID(uuid: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
}

// MARK: - Data

/// 空 Data 默认值：`Data()`
///
/// ```swift
/// @CodingDefault<EmptyData> var payload: Data
/// ```
public enum EmptyData: CodingDefaultValueProvider {
    public static var defaultValue: Data { Data() }
}

// MARK: - Decimal

/// Decimal 默认值：`0`
///
/// 金融 / 精度敏感场景优先用 Decimal 而不是 Double。
///
/// ```swift
/// @CodingDefault<EmptyDecimal> var amount: Decimal
/// ```
public enum EmptyDecimal: CodingDefaultValueProvider {
    public static var defaultValue: Decimal { Decimal(0) }
}
