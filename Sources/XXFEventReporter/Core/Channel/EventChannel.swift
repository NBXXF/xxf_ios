//
//  EventChannel.swift
//  xxf_ios
//  事件上报渠道，支持多个渠道同时上报
//  Created by xxf on 2019/5/28.
//

import Foundation

// MARK: - EventChannel

/// 事件上报渠道协议，同一个 app 可能有多个上报 SDK
/// 比如同时有 Firebase Analytics、AppsFlyer、友盟等
public protocol EventChannel: AnyObject {
    /// 渠道名称
    var channelName: String { get }

    /// 上报事件时调用
    /// - Parameters:
    ///   - event: 事件名称
    ///   - parameters: 事件参数
    func onEventReported(event: String, parameters: [String: Any])

    /// 是否支持该事件（可选实现，默认返回 true）
    /// - Parameter event: 事件名称
    /// - Returns: 是否支持上报
    func supports(event: String) -> Bool
}

// MARK: - 默认实现

public extension EventChannel {
    func supports(event: String) -> Bool {
        return true
    }
}
