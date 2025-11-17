//
//  Number+Extension.swift
//  xxf_ios
//
//  Created by xxf on 11/17.
//
import Foundation

public extension BinaryInteger {
    /// 将整数转换为短视频风格/社区评论缩写字符串（K/M/万）,K还是万 根据applocal相关
    /// - Returns: 缩写后的字符串，例如 "532", "1.2K", "1.2万"
    func abbreviated() -> String {
        // 将 BinaryInteger 转换为 Int64，再创建 NSNumber
        let number = NSNumber(value: Int64(self))
        var config = ImmutableNumberFormatter.Configuration()
        config.maximumFractionDigits = 1
        return NumberFormatter.cachedInstance(
            configuration: config)
            .format(number)
    }

    func shortCount() -> String {
        return self.abbreviated()
    }
}
