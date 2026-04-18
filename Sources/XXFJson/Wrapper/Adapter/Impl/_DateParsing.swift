//
//  _DateParsing.swift
//  xxf_ios
//
//  日期解析内部辅助（供 ISO8601DateAdapter / ISO8601OptionalDateAdapter 复用）。
//
//  Created by xxf
//

import Foundation

/// 日期解析辅助
///
/// - Note: 内部使用，不对外暴露
internal enum _DateParsing {

    /// 带毫秒的 ISO8601 formatter（编码默认格式）
    static let encodeFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return f
    }()

    /// 不带毫秒的 ISO8601 formatter
    static let plainFormatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    /// 兜底 formatter 列表（常见非标准 ISO 格式）
    static let fallbackFormatters: [DateFormatter] = {
        let fmts = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSSXXXXX",   // 带微秒 + 时区
            "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX",      // 带毫秒 + 时区
            "yyyy-MM-dd'T'HH:mm:ssXXXXX",          // 无毫秒 + 时区
            "yyyy-MM-dd HH:mm:ss",                 // 空格分隔
            "yyyy-MM-dd",                          // 仅日期
            "yyyy/MM/dd HH:mm:ss",                 // 斜杠
            "yyyy/MM/dd"
        ]
        return fmts.map { fmt in
            let f = DateFormatter()
            f.locale = Locale(identifier: "en_US_POSIX")
            f.timeZone = TimeZone(secondsFromGMT: 0)
            f.dateFormat = fmt
            return f
        }
    }()

    /// 字符串 → Date
    ///
    /// 尝试顺序：
    /// 1. 带毫秒 ISO8601
    /// 2. 不带毫秒 ISO8601
    /// 3. 兜底 formatter 列表
    /// 4. 纯数字字符串（按时间戳处理）
    static func parseString(_ str: String) -> Date? {
        let trimmed = str.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return nil }

        if let d = encodeFormatter.date(from: trimmed) { return d }
        if let d = plainFormatter.date(from: trimmed) { return d }
        for f in fallbackFormatters {
            if let d = f.date(from: trimmed) { return d }
        }
        if let ts = Double(trimmed) {
            return dateFromTimestamp(ts)
        }
        return nil
    }

    /// 时间戳 → Date（秒 / 毫秒自动识别）
    ///
    /// 阈值：1e12（约等于 2001 年的毫秒值）
    /// - `|ts| ≥ 1e12`：视为毫秒（`Date(timeIntervalSince1970: ts / 1000)`）
    /// - 否则：视为秒
    ///
    /// 支持负值（epoch 之前的时间）
    static func dateFromTimestamp(_ ts: Double) -> Date {
        if abs(ts) >= 1_000_000_000_000 {
            return Date(timeIntervalSince1970: ts / 1000)
        }
        return Date(timeIntervalSince1970: ts)
    }

    /// Date → ISO8601 字符串（带毫秒）
    static func encodeISO8601(_ date: Date) -> String {
        encodeFormatter.string(from: date)
    }
}
