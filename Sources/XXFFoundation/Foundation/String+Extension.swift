//
//  String+Extension.swift
//  xxf_ios
//
//  Created by xxf on 6/27.
//

public extension String {
    /// 定义空字符串,避免业务代码看起来混乱
    static var empty: String {
        return ""
    }

    /// 判断字符串是否为空或仅包含空白字符
    var isBlank: Bool {
        return isEmpty || allSatisfy(\.isWhitespace)
    }

    /// 去掉末尾 `/`（除根目录），轻量级替代 URL.standardizedFileURL.path
    var standardizedPathFast: String {
        if count > 1, hasSuffix(System.fileSeparator) {
            return String(dropLast())
        }
        return self
    }
}

public extension Optional where Wrapped == String {
    /// 当 Optional<String> 为 nil 时返回空字符串
    var orEmpty: String {
        return self ?? .empty
    }

    /// 判断字符串是否为 nil 或空字符串
    var isEmpty: Bool {
        return self?.isEmpty ?? true
    }

    /// 判断字符串是否为 nil、空字符串，或仅包含空白字符
    var isBlank: Bool {
        return self?.isBlank ?? true
    }

    /// 判断字符串是否为 nil 或空字符串
    var isNilOrEmpty: Bool {
        return isEmpty
    }

    /// 将空白空字符串 转换成nil,否则就是原文
    var trimBlankToNil: String? {
        if isEmpty || isBlank {
            return nil
        }
        return self?.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
