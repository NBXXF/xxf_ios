//
//  ByteCountFormatter+XXFExtension.swift
//  xxf_ios
//  文件大小格式化工具扩展，线程安全，高效复用
//  Created by xxf on 8/15.
//

public extension ByteCountFormatter {
    /// 获取缓存实例,高效
    /// - Parameter configuration: 格式化配置
    /// - Returns: 格式化器
    static func cachedInstance(
        configuration: ImmutableByteCountFormatter.Configuration
    ) -> ImmutableByteCountFormatter {
        return ImmutableByteCountFormatter(configuration: configuration)
    }
}
