//
//  ImmutableByteCountFormatter.swift
//  xxf_ios
//  文件大小格式化工具，线程安全，高效复用
//  Created by xxf on 8/15.
//

import Foundation

public final class ImmutableByteCountFormatter {
    // MARK: - 全局默认配置（可修改）

    private var cacheKey: String
    private let formatter: ByteCountFormatter

    // 支持的初始化参数
    public struct Configuration: CustomStringConvertible, StandardExtensible {
        /// 语言环境
        public var locale: Locale = .appLocale

        /// 显示样式（.file / .memory / .decimal / .binary 等）
        /**
         总结对比
         样式                      基数        单位大小写          用途
         .file                        1024       KB/MB                文件大小
         .memory               1024       KB/MB                内存大小
         .decimal                1000       kB/MB                十进制显示
         .binary                   1024       KB/MB                二进制显示，传统计算机用
         */
        public var countStyle: ByteCountFormatter.CountStyle = .file

        /// 限制允许的单位（如 [.useKB, .useMB]）
        public var allowedUnits: ByteCountFormatter.Units = []

        /// 是否包含单位
        public var includesUnit: Bool = true

        /// 是否包含字节数（单位后加括号显示原始字节数）
        public var includesCount: Bool = true

        /// 是否自适应选择单位（true 则会自动选择合适单位）
        public var isAdaptive: Bool = true

        /// 是否包含近似符号（例如 "~1 MB"）
        public var includesApproximationPhrase: Bool = false

        /// 是否允许非数字格式
        public var allowsNonnumericFormatting: Bool = true

        public init() {}

        public var description: String {
            var parts: [String] = []
            parts.append("locale:\(locale.identifier)")
            parts.append("countStyle:\(countStyle.rawValue)")
            parts.append("allowedUnits:\(allowedUnits.rawValue)")
            parts.append("includesUnit:\(includesUnit)")
            parts.append("includesCount:\(includesCount)")
            parts.append("isAdaptive:\(isAdaptive)")
            parts.append("includesApproximation:\(includesApproximationPhrase)")
            parts.append("allowsNonnumeric:\(allowsNonnumericFormatting)")
            return parts.joined(separator: "_")
        }
    }

    // 使用 Configuration 初始化
    public init(configuration: Configuration) {
        // 生成缓存 key
        cacheKey = "com.xxf.ImmutableByteCountFormatter.\(configuration.description)"

        if let cached = Thread.current.threadDictionary[cacheKey] as? ByteCountFormatter {
            formatter = cached
        } else {
            let newFormatter = ByteCountFormatter()

            // 基础属性，所有版本都支持
            newFormatter.countStyle = configuration.countStyle
            newFormatter.allowedUnits = configuration.allowedUnits
            newFormatter.includesUnit = configuration.includesUnit
            newFormatter.includesCount = configuration.includesCount
            newFormatter.isAdaptive = configuration.isAdaptive
            newFormatter.allowsNonnumericFormatting = configuration.allowsNonnumericFormatting

            // 高版本才支持的属性
//            #if compiler(>=5.9) && canImport(UIKit) // Swift 5.9 / Xcode 15+
//                if #available(iOS 17.0, macOS 14.0, *) {
//                    newFormatter.locale = configuration.locale
//                    newFormatter.includesApproximationPhrase = configuration.includesApproximationPhrase
//                }
//            #endif

            Thread.current.threadDictionary[cacheKey] = newFormatter
            formatter = newFormatter
        }
    }

    // 格式化字节数
    public func format(_ byteCount: Int64) -> String {
        return formatter.string(fromByteCount: byteCount)
    }

    // 格式化字节数 - Int
    public func format(_ byteCount: Int) -> String {
        return format(Int64(byteCount))
    }
}
