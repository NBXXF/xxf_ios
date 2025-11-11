
//
//  ImmutableDateComponentsFormatter.swift
//  xxf_ios
//  时间间隔格式化工具，线程安全，高效复用
//  Created by xxf on 8/11.
//

import Foundation

public final class ImmutableDateComponentsFormatter {
    // MARK: - 全局默认配置（可修改）

    private var cacheKey: String

    private let formatter: DateComponentsFormatter

    // 支持的初始化参数
    public struct Configuration: CustomStringConvertible, StandardExtensible {
        /// 可选的计时单位，默认小时、分钟、秒
        public var allowedUnits: NSCalendar.Unit = [.hour, .minute, .second]

        /// 时间间隔格式的显示风格，默认 positional (如 1:05:03)
        public var unitsStyle: DateComponentsFormatter.UnitsStyle = .positional

        /// 时间间隔显示时最大单位数，默认0不限制
        public var maximumUnitCount: Int = 0

        /// 时间间隔格式化时零值的显示行为，默认不显示零值
        public var zeroFormattingBehavior: DateComponentsFormatter.ZeroFormattingBehavior = []

        /// 语言环境，默认系统当前语言
        public var locale: Locale = .appLocale

        /// 时区，默认系统当前时区
        public var timeZone: TimeZone = .appTimeZone

        public init() {}

        public var description: String {
            var parts: [String] = []
            parts.append("allowedUnits:\(allowedUnits.rawValue)")
            parts.append("unitsStyle:\(unitsStyle.rawValue)")
            parts.append("maxUnitCount:\(maximumUnitCount)")
            parts.append("zeroFormattingBehavior:\(zeroFormattingBehavior.rawValue)")
            parts.append("locale:\(locale.identifier)")
            parts.append("timeZone:\(timeZone.identifier)")
            return parts.joined(separator: "_")
        }
    }

    // 使用 Configuration 初始化
    public init(configuration: Configuration) {
        // 生成缓存key
        cacheKey = "com.xxf.ImmutableDateComponentsFormatter.\(configuration.description)"

        if let cached = Thread.current.threadDictionary[cacheKey] as? DateComponentsFormatter {
            formatter = cached
        } else {
            let newFormatter = DateComponentsFormatter()

            newFormatter.allowedUnits = configuration.allowedUnits
            newFormatter.unitsStyle = configuration.unitsStyle
            newFormatter.maximumUnitCount = configuration.maximumUnitCount
            newFormatter.zeroFormattingBehavior = configuration.zeroFormattingBehavior

            // DateComponentsFormatter 没有直接 locale 属性，这里做兼容
            newFormatter.calendar = Calendar(identifier: configuration.locale.calendar.identifier)

            Thread.current.threadDictionary[cacheKey] = newFormatter
            formatter = newFormatter
        }
    }

    // 格式化时间间隔
    public func format(_ timeInterval: TimeInterval) -> String {
        let isNegative = timeInterval < 0
        let absInterval = abs(timeInterval)
        guard let formatted = formatter.string(from: absInterval) else {
            return "--:--"
        }
        return isNegative ? "-\(formatted)" : formatted
    }
}
