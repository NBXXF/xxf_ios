//
//  ChanelTracker.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

/// 渠道采集, 同一个 app 可能有多个采集 SDK
/// 比如同时有 Sentry 也可能有 BugLy
public protocol ChanelTracker {
    func onTracking(data: String, extra: [AnyHashable: Any])
}
