//
//  CodingDefaultValueProvider.swift
//  xxf_ios
//
//  默认值提供者协议
//
//  Created by xxf
//

import Foundation

/// 默认值提供者
///
/// 通过类型参数向 `@CodingDefault<Provider>` 传递默认值。这种"类型级"配置
/// 让装饰器在 `init(from:)` 里也能拿到默认值（因为默认值是 static 属性，不需要
/// 实例状态），从而避免 Mirror / Macro。
///
/// 业务类型如果要自定义默认值，实现本协议即可：
///
/// ```swift
/// enum DefaultOrderStatus: CodingDefaultValueProvider {
///     static let defaultValue: OrderStatus = .unknown
/// }
///
/// struct User: Codable {
///     @CodingDefault<DefaultOrderStatus> var status: OrderStatus
/// }
/// ```
///
/// 常见基础类型的 Provider 已内置（见 Provider/Impl/ 下的文件）：
///
/// - 基础类型（EmptyBasic.swift）：
///   `EmptyString`、`EmptyInt`、`EmptyInt8`、`EmptyInt16`、`EmptyInt32`、`EmptyInt64`、
///   `EmptyUInt`、`EmptyUInt8`、`EmptyUInt16`、`EmptyUInt32`、`EmptyUInt64`、
///   `EmptyFloat`、`EmptyDouble`
/// - 布尔类型（EmptyBool.swift）：`False`、`True`
/// - 集合类型（EmptyCollection.swift）：`EmptyArray<Element>`、`EmptyDict<Key, Value>`、`EmptySet<Element>`
/// - 日期类型（EmptyDate.swift）：`DistantPast`、`DistantFuture`、`Now`、`Epoch`
/// - Foundation 类型（EmptyFoundation.swift）：`EmptyURL`、`EmptyUUID`、`EmptyData`、`EmptyDecimal`
public protocol CodingDefaultValueProvider {
    /// 被适配的目标类型
    associatedtype Value: Codable

    /// 默认值（static 属性，解码失败或缺失 key 时使用）
    static var defaultValue: Value { get }
}
