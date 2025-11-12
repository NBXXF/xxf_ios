//
//  String+XXFExtension.swift
//  xxf_ios
//
//  Created by xxf on 8/10.
//

public extension String {
    /// 将字符串转换为 URL（识别网络 URL 与本地路径）
    var asURL: URL? {
        let trimmed = trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        if let url = URL(string: trimmed), url.scheme != nil {
            return url
        }
        return URL(fileURLWithPath: trimmed)
    }

    enum TruncateAt {
        case start
        case middle
        case end
    }

    /// 截断字符串，高效且 Unicode 安全
    /// - Parameters:
    ///   - maxLength: 最大字符长度
    ///   - truncateAt: 截断位置（start / middle / end）
    ///   - ellipsis: 省略符号，默认 "…"
    /// - Returns: 截断后的字符串
    func truncate(maxLength: Int,
                  truncateAt: TruncateAt = .middle,
                  ellipsis: String = "…") -> String
    {
        return ellipsize(maxLength: maxLength, truncateAt: truncateAt, ellipsis: ellipsis)
    }

    /// 截断字符串，高效且 Unicode 安全
    /// - Parameters:
    ///   - maxLength: 最大字符长度
    ///   - truncateAt: 截断位置（start / middle / end）
    ///   - ellipsis: 省略符号，默认 "…"
    /// - Returns: 截断后的字符串
    func ellipsize(maxLength: Int,
                   truncateAt: TruncateAt = .middle,
                   ellipsis: String = "…") -> String
    {
        guard !isEmpty, maxLength > 0 else { return self }
        guard count > maxLength else { return self }

        switch truncateAt {
            case .end:
                let endIndex = index(startIndex, offsetBy: max(maxLength - ellipsis.count, 0))
                return String(self[startIndex ..< endIndex]) + ellipsis

            case .start:
                let startIndex = index(endIndex, offsetBy: -max(maxLength - ellipsis.count, 0))
                return ellipsis + String(self[startIndex ..< endIndex])

            case .middle:
                let adjustedLength = max(maxLength - ellipsis.count, 0)
                let firstHalf = (adjustedLength + 1) / 2
                let secondHalf = adjustedLength / 2
                let start = prefix(firstHalf)
                let end = suffix(secondHalf)
                return "\(start)\(ellipsis)\(end)"
        }
    }
}
