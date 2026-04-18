//
//  EmptyDate.swift
//  xxf_ios
//
//  Date 默认值 Provider
//
//  Created by xxf
//

import Foundation

/// 远古时间默认值：`Date.distantPast`
///
/// 常用于"创建时间缺失时"的兜底。
public enum DistantPast: CodingDefaultValueProvider {
    public static var defaultValue: Date { Date.distantPast }
}

/// 远未来时间默认值：`Date.distantFuture`
public enum DistantFuture: CodingDefaultValueProvider {
    public static var defaultValue: Date { Date.distantFuture }
}

/// 当前时间默认值：`Date()`
///
/// - Warning: 每次访问都会返回"当下"时间（不是 app 启动时的时间），
///   所以不同实例拿到的默认值会不同。多数场景用 `DistantPast` 更稳
public enum Now: CodingDefaultValueProvider {
    public static var defaultValue: Date { Date() }
}

/// Epoch 默认值：`Date(timeIntervalSince1970: 0)`（1970-01-01 UTC）
public enum Epoch: CodingDefaultValueProvider {
    public static var defaultValue: Date { Date(timeIntervalSince1970: 0) }
}
