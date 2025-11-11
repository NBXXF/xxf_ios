//
//  Local+Extension.swift
//  xxf_ios
//  语言相关
//  Created by xxf on 6/26.
//

import Foundation

public extension Locale {
    /// ISO 639-1 两位语言码（如 "en", "zh"）
    var isoLanguageCode: String {
        if #available(macOS 13.0, iOS 16.0, *) {
            return self.language.languageCode?.identifier ?? "und"
        } else {
            return languageCode ?? "und"
        }
    }

    /// ISO 3166-1 两位地区码（如 "US", "CN"）
    var isoRegionCode: String {
        if #available(macOS 13.0, iOS 16.0, *) {
            return self.region?.identifier ?? "ZZ"
        } else {
            return regionCode ?? "ZZ"
        }
    }

    /// ISO 15924 脚本码（如 "Latn", "Hans"）
    var isoScriptCode: String {
        if #available(macOS 13.0, iOS 16.0, *) {
            return self.language.script?.identifier ?? "Zzzz"
        } else {
            return scriptCode ?? "Zzzz"
        }
    }

    /// IETF BCP 47 语言标识（如 "en-US", "zh-Hans-CN"）
    var bcp47Identifier: String {
        var components: [String] = []

        let lang = isoLanguageCode
        let script = isoScriptCode
        let region = isoRegionCode

        if lang != "und" { components.append(lang) }
        if script != "Zzzz" { components.append(script) }
        if region != "ZZ" { components.append(region) }

        return components.joined(separator: "-")
    }

    /// 当前设备用户首选语言（BCP 47 格式，如 "zh-Hans-CN"）
    static var preferredBCP47Language: String {
        let tag = Locale.preferredLanguages.first ?? "und"
        return tag.replacingOccurrences(of: "_", with: "-")
    }

    /// 当前设备用户首选语言的 Locale
    static var preferredLocale: Locale {
        Locale(identifier: Locale.preferredLanguages.first ?? "und")
    }

    /// 是否是中文（包括简体/繁体）
    var isChinese: Bool {
        return isoLanguageCode == "zh"
    }

    /// 是否是英文
    var isEnglish: Bool {
        return isoLanguageCode == "en"
    }

    /// 用于数据库存储或匹配的统一语言 key（ ISO 639-1 两位语言码（如 "en", "zh"））
    var dbLanguageKey: String {
        return isoLanguageCode.lowercased()
    }
}
