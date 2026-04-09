//
//  ImmutableMeasurementFormatter.swift
//  xxf_ios
//  通用测量单位格式化工具，线程安全，高效复用
//  Created by xxf on 2023/8/15.
//

import CoreGraphics
import Foundation

public final class ImmutableMeasurementFormatter {
    // MARK: - 全局默认配置

    private var cacheKey: String
    private let formatter: MeasurementFormatter

    // 支持的初始化参数
    public struct Configuration: CustomStringConvertible, StandardExtensible {
        /// 语言环境
        public var locale: Locale = .appLocale

        /// 单位显示风格
        public var unitStyle: MeasurementFormatter.UnitStyle = .medium

        /// 单位选择方式
        public var unitOptions: MeasurementFormatter.UnitOptions = .naturalScale

        /// 最小小数位
        public var minimumFractionDigits: Int = 0

        /// 最大小数位
        public var maximumFractionDigits: Int = 2

        public init() {}

        public var description: String {
            var parts: [String] = []
            parts.append("locale:\(locale.identifier)")
            parts.append("unitStyle:\(unitStyle.rawValue)")
            parts.append("unitOptions:\(unitOptions.rawValue)")
            parts.append("minFraction:\(minimumFractionDigits)")
            parts.append("maxFraction:\(maximumFractionDigits)")
            return parts.joined(separator: "_")
        }
    }

    // 使用 Configuration 初始化
    public init(configuration: Configuration) {
        // 生成缓存 key
        cacheKey = "com.xxf.ImmutableMeasurementFormatter.\(configuration.description)"

        if let cached = Thread.current.threadDictionary[cacheKey] as? MeasurementFormatter {
            formatter = cached
        } else {
            let newFormatter = MeasurementFormatter()

            // 基础属性，所有版本都支持
            newFormatter.unitStyle = configuration.unitStyle
            newFormatter.unitOptions = configuration.unitOptions
            newFormatter.numberFormatter.minimumFractionDigits = configuration.minimumFractionDigits
            newFormatter.numberFormatter.maximumFractionDigits = configuration.maximumFractionDigits

            // 高版本系统可用属性
            #if compiler(>=5.9) && canImport(UIKit)
                if #available(iOS 17.0, macOS 14.0, *) {
                    newFormatter.locale = configuration.locale
                }
            #endif

            Thread.current.threadDictionary[cacheKey] = newFormatter
            formatter = newFormatter
        }
    }

    // MARK: - 格式化方法

    /// 格式化数值并指定单位
    ///
    /// - 参数 value: 数值，可以是 Double、Float、Int、CGFloat 等
    /// - 参数 unit: 单位类型，常用 Unit 子类示例：
    ///
    ///     - **UnitLength** (长度单位)
    ///         - .meters        米
    ///         - .kilometers    千米
    ///         - .centimeters   厘米
    ///         - .millimeters   毫米
    ///         - .miles         英里
    ///         - .yards         码
    ///         - .feet          英尺
    ///         - .inches        英寸
    ///
    ///     - **UnitMass** (质量/重量单位)
    ///         - .grams         克
    ///         - .kilograms     千克
    ///         - .ounces        盎司
    ///         - .pounds        磅
    ///
    ///     - **UnitDuration** (时间单位)
    ///         - .seconds       秒
    ///         - .minutes       分钟
    ///         - .hours         小时
    ///
    ///     - **UnitSpeed** (速度单位)
    ///         - .metersPerSecond        米/秒
    ///         - .kilometersPerHour      千米/小时
    ///         - .milesPerHour           英里/小时
    ///
    ///     - **UnitVolume** (体积单位)
    ///         - .liters        升
    ///         - .milliliters   毫升
    ///         - .cups          杯
    ///
    ///     - **UnitTemperature** (温度单位)
    ///         - .celsius       摄氏度
    ///         - .fahrenheit    华氏度
    ///         - .kelvin        开尔文
    ///
    ///     - **UnitInformationStorage** (信息存储/字节单位)
    ///         - .bytes         字节
    ///         - .kilobytes     千字节
    ///         - .megabytes     兆字节
    ///         - .gigabytes     千兆字节
    ///
    public func format<T: BinaryFloatingPoint>(_ value: T, unit: Unit) -> String {
        return formatter.string(from: Measurement(value: Double(value), unit: unit))
    }

    public func format<T: BinaryInteger>(_ value: T, unit: Unit) -> String {
        return formatter.string(from: Measurement(value: Double(value), unit: unit))
    }

    public func format(_ value: CGFloat, unit: Unit) -> String {
        return formatter.string(from: Measurement(value: Double(value), unit: unit))
    }
}
