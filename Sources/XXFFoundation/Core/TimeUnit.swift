//
//  TimeUnit.swift
//  xxf_ios
//  比DispatchTimeInterval 全
//  Created by xxf on 6/9.
//

import Foundation

/// 再取一个别名,用于代码提示,比DispatchTimeInterval 全
public typealias DispatchTimeUnit = TimeUnit

public enum TimeUnit: Comparable, CustomStringConvertible {
    case nanoseconds(Double)
    case microseconds(Double)
    case milliseconds(Double)
    case seconds(Double)
    case minutes(Double)
    case hours(Double)
    case days(Double)

    // MARK: - 转换为秒

    public var inSeconds: TimeInterval {
        switch self {
        case let .nanoseconds(n): return n / 1_000_000_000
        case let .microseconds(u): return u / 1_000_000
        case let .milliseconds(m): return m / 1000
        case let .seconds(s): return s
        case let .minutes(m): return m * 60
        case let .hours(h): return h * 3600
        case let .days(d): return d * 24 * 3600
        }
    }

    public var inMilliseconds: Double { inSeconds * 1000 }
    public var inMicroseconds: Double { inSeconds * 1_000_000 }
    public var inNanoseconds: Double { inSeconds * 1_000_000_000 }
    public var inMinutes: Double { inSeconds / 60 }
    public var inHours: Double { inSeconds / 3600 }
    public var inDays: Double { inSeconds / (3600 * 24) }

    // MARK: - CustomStringConvertible

    public var description: String {
        switch self {
        case let .nanoseconds(n): return "\(n) ns"
        case let .microseconds(u): return "\(u) μs"
        case let .milliseconds(m): return "\(m) ms"
        case let .seconds(s): return "\(s) s"
        case let .minutes(m): return "\(m) min"
        case let .hours(h): return "\(h) h"
        case let .days(d): return "\(d) d"
        }
    }

    // MARK: - Comparable

    public static func < (lhs: TimeUnit, rhs: TimeUnit) -> Bool {
        return lhs.inNanoseconds < rhs.inNanoseconds
    }

    public static func == (lhs: TimeUnit, rhs: TimeUnit) -> Bool {
        return lhs.inNanoseconds == rhs.inNanoseconds
    }
}
