//
//  ImmutableNumberFormatter+XXFExtension.swift
//  xxf_ios
//  数字格式化工具扩展，线程安全，高效复用
//  Created by xxf on 8/11.
//

import Foundation

public extension NumberFormatter {
    /// 获取缓存实例,高效
    /// - Parameter configuration: 格式化配置
    /// - Returns: 格式化器
    static func cachedInstance(
        configuration: ImmutableNumberFormatter.Configuration
    ) -> ImmutableNumberFormatter {
        return ImmutableNumberFormatter(configuration: configuration)
    }
}
