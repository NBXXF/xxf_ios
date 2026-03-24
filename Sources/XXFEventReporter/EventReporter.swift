//
//  EventReporter.swift
//  xxf_ios
//  事件上报模块入口
//  Created by Claude on 2026/3/24.
//

import Foundation

// MARK: - 便捷方法

public extension EventReporter {
    /// 快速上报事件（无参数）
    static func report(_ event: String) {
        shared.reportEvent(event)
    }

    /// 快速上报事件（带参数）
    static func report(_ event: String, params: [String: Any]) {
        shared.reportEvent(event, parameters: params)
    }

    /// 异步上报事件
    static func reportAsync(_ event: String, params: [String: Any] = [:]) {
        shared.reportEventAsync(event, parameters: params)
    }
}