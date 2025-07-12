//
//  TrackerHandleCallback.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

public protocol TrackerHandleCallback {
    /**
     * Tracker 前处理.
     *
     * - Parameters:
     *   - data: 原始上报数据
     *   - extra: 额外可变字典
     * - Returns: 返回额外的自定义信息上报
     */
    func onTrackHandleStart(data: Any, extra: inout [AnyHashable: Any]) -> [AnyHashable: Any]
}
