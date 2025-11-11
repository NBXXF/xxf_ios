//
//  DateComponentsFormatter+XXFExtension.swift
//  xxf_ios
//  时间间隔格式化工具扩展，线程安全，高效复用
//  Created by xxf on 8/11.
//

import Foundation

public extension DateComponentsFormatter {
    /// 获取缓存实例,高效
    /// - Parameter configuration: 格式化配置
    /// - Returns: 格式化器
    static func cachedInstance(
        configuration: ImmutableDateComponentsFormatter.Configuration
    ) -> ImmutableDateComponentsFormatter {
        return ImmutableDateComponentsFormatter(configuration: configuration)
    }
}
