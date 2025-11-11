//
//  LogLevel.swift
//  xxf_ios
//
//  Created by xxf on 5/23.
//

public enum LogLevel: Int, Comparable {
    case debug = 1
    case info = 2
    case warning = 3
    case error = 4

    // 额外提供一个描述字符串属性
    public var description: String {
        switch self {
        case .debug: return "🐛 DEBUG"
        case .info: return "ℹ️ INFO"
        case .warning: return "⚠️ WARNING"
        case .error: return "❌ ERROR"
        }
    }

    // Comparable 协议实现，默认比较原始值即可
    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}
