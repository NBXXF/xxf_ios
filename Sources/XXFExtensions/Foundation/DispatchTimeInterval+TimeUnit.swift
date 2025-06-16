//
//  DispatchTimeInterval+TimeUnit.swift
//  xxf_ios
//  时间戳转换,借鉴Java TimeUnit类
//  Created by xxf on 6/6.
//

import Foundation

public extension DispatchTimeInterval {
    /// 转换为纳秒 (ns)
    var toNanoseconds: Int {
        switch self {
        case let .seconds(s): return s * 1_000_000_000
        case let .milliseconds(ms): return ms * 1_000_000
        case let .microseconds(us): return us * 1000
        case let .nanoseconds(ns): return ns
        case .never: return .max
        @unknown default: return .max
        }
    }

    /// 转换为微秒 (µs)
    var toMicroseconds: Int {
        switch self {
        case let .seconds(s): return s * 1_000_000
        case let .milliseconds(ms): return ms * 1000
        case let .microseconds(us): return us
        case let .nanoseconds(ns): return ns / 1000
        case .never: return .max
        @unknown default: return .max
        }
    }

    /// 转换为毫秒 (ms)
    var toMilliseconds: Int {
        switch self {
        case let .seconds(s): return s * 1000
        case let .milliseconds(ms): return ms
        case let .microseconds(us): return us / 1000
        case let .nanoseconds(ns): return ns / 1_000_000
        case .never: return .max
        @unknown default: return .max
        }
    }

    /// 转换为秒 (s)
    var toSeconds: Int {
        switch self {
        case let .seconds(s): return s
        case let .milliseconds(ms): return ms / 1000
        case let .microseconds(us): return us / 1_000_000
        case let .nanoseconds(ns): return ns / 1_000_000_000
        case .never: return .max
        @unknown default: return .max
        }
    }

    /// 判断是否为 `.never`
    var isNever: Bool {
        if case .never = self {
            return true
        }
        return false
    }
}
