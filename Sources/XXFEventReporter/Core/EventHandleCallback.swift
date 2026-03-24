//
//  EventHandleCallback.swift
//  xxf_ios
//  事件上报拦截回调
//  Created by xxf
//

import Foundation

// MARK: - EventHandleCallback

public protocol EventHandleCallback {
    /// 事件上报前处理
    /// - Parameters:
    ///   - event: 原始事件名称
    ///   - parameters: 可变参数字典
    /// - Returns: 返回额外的自定义参数，将合并到最终参数中
    func onEventHandleStart(event: String, parameters: inout [String: Any]) -> [String: Any]

    /// 事件上报后处理（可选）
    /// - Parameters:
    ///   - event: 事件名称
    ///   - parameters: 最终参数
    ///   - success: 是否上报成功
    func onEventHandleEnd(event: String, parameters: [String: Any], success: Bool)
}

// MARK: - 默认实现

public extension EventHandleCallback {
    func onEventHandleEnd(event: String, parameters: [String: Any], success: Bool) {
        // 默认空实现
    }
}
