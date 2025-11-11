//
//  ImmutableDateFormatter.swift
//  xxf_ios
//  时间格式化工具，线程安全，高效复用
//  Created by xxf on 8/11.
//

import Foundation

public final class ImmutableDateFormatter {
    // MARK: - 全局默认配置（可修改）

    private var cacheKey: String

    private let formatter: DateFormatter

    // 支持的初始化参数
    public struct Configuration: CustomStringConvertible, StandardExtensible {
        /// 日期样式，影响日期部分的显示格式，默认中等风格 `.medium`
        public var dateStyle: DateFormatter.Style = .medium

        /// 时间样式，影响时间部分的显示格式，默认中等风格 `.medium`
        public var timeStyle: DateFormatter.Style = .medium

        /// 语言环境，决定格式化时使用的区域设置（如语言、数字格式等）
        public var locale: Locale = .appLocale

        /// 时区，决定时间的时区偏移
        public var timeZone: TimeZone = .appTimeZone

        /// 是否启用相对日期格式化（如 “今天”、“昨天”）
        public var doesRelativeDateFormatting: Bool = false

        /// 自定义的日期时间格式字符串,完全固定的日期格式
        public var dateFormat: String?

        /// 本地化模板格式字符串,模板化的本地化格式
        public var usesLocalizedTemplate: String?

        public init() {}

        public var description: String {
            var parts: [String] = []
            parts.append("dateStyle:\(dateStyle.rawValue)")
            parts.append("timeStyle:\(timeStyle.rawValue)")
            parts.append("locale:\(locale.identifier)")
            parts.append("timeZone:\(timeZone.identifier)")
            parts.append("relative:\(doesRelativeDateFormatting)")
            parts.append("dateFormat:\(dateFormat ?? "nil")")
            parts.append("template:\(usesLocalizedTemplate ?? "nil")")
            return parts.joined(separator: "_")
        }
    }

    // 使用 Configuration 初始化
    public init(configuration: Configuration) {
        // 生成缓存key
        cacheKey = "com.xxf.ImmutableDateFormatter.\(configuration.description)"

        if let cached = Thread.current.threadDictionary[cacheKey] as? DateFormatter {
            formatter = cached
        } else {
            let newFormatter = DateFormatter()

            // 语言环境
            newFormatter.locale = configuration.locale

            // 时区
            newFormatter.timeZone = configuration.timeZone

            // 相对日期格式
            newFormatter.doesRelativeDateFormatting = configuration.doesRelativeDateFormatting

            if let dateFormat = configuration.dateFormat {
                newFormatter.dateFormat = dateFormat
            } else if let template = configuration.usesLocalizedTemplate {
                newFormatter.setLocalizedDateFormatFromTemplate(template)
            } else {
                newFormatter.dateStyle = configuration.dateStyle
                newFormatter.timeStyle = configuration.timeStyle
            }

            Thread.current.threadDictionary[cacheKey] = newFormatter
            formatter = newFormatter
        }
    }

    // 只暴露格式化接口
    public func format(_ date: Date) -> String {
        return formatter.string(from: date)
    }

    // 时间反格式化
    public func date(from string: String) -> Date? {
        return formatter.date(from: string)
    }
}
