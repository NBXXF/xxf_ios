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

    /// 去掉末尾 `/`（除根目录），轻量级替代 URL.standardizedFileURL.path
    var standardizedPathFast: String {
        if count > 1, hasSuffix(System.fileSeparator) {
            return String(dropLast())
        }
        return self
    }
}

public extension Optional where Wrapped == String {
    /// 判断字符串是否为 nil 或空字符串
    var isNilOrEmpty: Bool {
        return self?.isEmpty ?? true
    }
}
