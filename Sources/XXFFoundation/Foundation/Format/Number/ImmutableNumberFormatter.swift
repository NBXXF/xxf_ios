//
//  ImmutableNumberFormatter.swift
//  xxf_ios
//  数字格式化工具，线程安全，高效复用
//  Created by xxf on 8/15.
//

import Foundation
import XXFSpeed

public final class ImmutableNumberFormatter {
    // MARK: - 全局默认配置（可修改）

    private var cacheKey: String
    private let formatter: NumberFormatter

    // MARK: - 配置结构

    public struct Configuration: CustomStringConvertible, StandardExtensible {
        /// 数字样式（小数、百分比、货币等）
        public var numberStyle: NumberFormatter.Style = .decimal

        /// 语言环境
        public var locale: Locale = .appLocale

        /// 最少小数位数
        public var minimumFractionDigits: Int = 0

        /// 最大小数位数
        public var maximumFractionDigits: Int = 2

        /// 是否使用分组（千分位）
        public var usesGroupingSeparator: Bool = true

        /// 自定义格式（如 "#,##0.00%"），优先级高于 numberStyle
        public var positiveFormat: String?

        public init() {}

        public var description: String {
            var parts: [String] = []
            parts.append("style:\(numberStyle.rawValue)")
            parts.append("locale:\(locale.identifier)")
            parts.append("minFraction:\(minimumFractionDigits)")
            parts.append("maxFraction:\(maximumFractionDigits)")
            parts.append("grouping:\(usesGroupingSeparator)")
            parts.append("format:\(positiveFormat ?? "nil")")
            return parts.joined(separator: "_")
        }
    }

    // MARK: - 初始化

    public init(configuration: Configuration) {
        // 生成缓存key
        cacheKey = "com.xxf.ImmutableNumberFormatter.\(configuration.description)"

        if let cached = Thread.current.threadDictionary[cacheKey] as? NumberFormatter {
            formatter = cached
        } else {
            let newFormatter = NumberFormatter()
            newFormatter.locale = configuration.locale
            newFormatter.numberStyle = configuration.numberStyle
            newFormatter.minimumFractionDigits = configuration.minimumFractionDigits
            newFormatter.maximumFractionDigits = configuration.maximumFractionDigits
            newFormatter.usesGroupingSeparator = configuration.usesGroupingSeparator
            if let format = configuration.positiveFormat {
                newFormatter.positiveFormat = format
            }
            Thread.current.threadDictionary[cacheKey] = newFormatter
            formatter = newFormatter
        }
    }

    // MARK: - 格式化方法

    public func format(_ number: NSNumber) -> String {
        return formatter.string(from: number) ?? String.empty
    }

    public func format(_ doubleValue: Double) -> String {
        return format(NSNumber(value: doubleValue))
    }

    public func format(_ floatValue: Float) -> String {
        return format(NSNumber(value: floatValue))
    }

    public func format(_ intValue: Int) -> String {
        return format(NSNumber(value: intValue))
    }

    public func format(_ int8Value: Int8) -> String {
        return format(NSNumber(value: int8Value))
    }

    public func format(_ int16Value: Int16) -> String {
        return format(NSNumber(value: int16Value))
    }

    public func format(_ int32Value: Int32) -> String {
        return format(NSNumber(value: int32Value))
    }

    public func format(_ int64Value: Int64) -> String {
        return format(NSNumber(value: int64Value))
    }

    public func format(_ uIntValue: UInt) -> String {
        return format(NSNumber(value: uIntValue))
    }

    public func format(_ uInt8Value: UInt8) -> String {
        return format(NSNumber(value: uInt8Value))
    }

    public func format(_ uInt16Value: UInt16) -> String {
        return format(NSNumber(value: uInt16Value))
    }

    public func format(_ uInt32Value: UInt32) -> String {
        return format(NSNumber(value: uInt32Value))
    }

    public func format(_ uInt64Value: UInt64) -> String {
        return format(NSNumber(value: uInt64Value))
    }

    public func format(_ cgFloatValue: CGFloat) -> String {
        return format(NSNumber(value: Double(cgFloatValue)))
    }
}
