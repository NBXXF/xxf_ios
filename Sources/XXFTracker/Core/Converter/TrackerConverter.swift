//
//  TrackerConverter.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

public protocol TrackerConverter {
    /**
     * 将 data 转换成字符串，可以用于日志
     *
     * - Parameters:
     *   - data: 输入数据
     *   - extra: 可变的额外信息字典
     *   - chanel: 渠道采集器
     * - Returns: 转换后的字符串，返回 nil 表示无法转换，交由下一个转换器处理
     */
    func convert(data: Any, extra: inout [AnyHashable: Any], chanel: ChanelTracker) -> String?
}
