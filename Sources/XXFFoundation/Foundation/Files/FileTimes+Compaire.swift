//
//  FileTimes+Compaire.swift
//  xxf_ios
//  增加时间比较
//  Created by xxf on 8/21.
//

public extension FileTimes {
    /// 判断是否有任意时间大于指定日期
    func anyAfter(_ date: Date) -> Bool {
        [creationTime, modificationTime, accessTime, changeTime].compactMap { $0 }.contains { $0 > date }
    }

    /// 判断是否有任意时间小于指定日期
    func anyBefore(_ date: Date) -> Bool {
        [creationTime, modificationTime, accessTime, changeTime].compactMap { $0 }.contains { $0 < date }
    }

    /// 判断是否有任意时间落在指定区间 [start, end]
    func anyBetween(start: Date, end: Date) -> Bool {
        [creationTime, modificationTime, accessTime, changeTime]
            .compactMap { $0 }
            .contains { $0 >= start && $0 <= end }
    }

    /// 用法:  只组合 creationTime 和 modificationTime   let result1 = times.combinedString(using: [\.creationTime, \.modificationTime])
    /// 将指定的属性组合成字符串
    /// - Parameters:
    ///   - keyPaths: 要组合的属性 keyPath 列表
    ///   - formatter: 可选的日期格式化函数（默认用秒级时间戳）
    func combinedString(
        using keyPaths: [KeyPath<FileTimes, Date?>],
        formatter: ((Date?) -> String)? = nil
    ) -> String {
        let format: (Date?) -> String = formatter ?? { date in
            guard let date = date else { return "nil" }
            return String(Int(date.timeIntervalSince1970))
        }

        var result = String.empty
        for (index, keyPath) in keyPaths.enumerated() {
            if index > 0 { result.append("_") }
            let label = Self.label(for: keyPath)
            let value = format(self[keyPath: keyPath])
            result.append("\(label):\(value)")
        }
        return result
    }

    /// 映射 KeyPath -> 属性名
    ///  注意这里的硬编码 不能变
    private static func label(for keyPath: KeyPath<FileTimes, Date?>) -> String {
        switch keyPath {
            case \.creationTime: return "creationTime"
            case \.modificationTime: return "modificationTime"
            case \.accessTime: return "accessTime"
            case \.changeTime: return "changeTime"
            default: return "unknown"
        }
    }
}
