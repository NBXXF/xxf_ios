//  SentryTracker.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

import Foundation
import Sentry
import XXFTracker

/// 使用 sentry 作为上报渠道
public final class SentryTracker: ChanelTracker {
    /// 初始化
    /// - Parameters:
    ///   - dsn: dsn 上报全地址
    public convenience init(dsn: String) {
        self.init { options in
            options.dsn = dsn
            #if DEBUG
                options.debug = true
            #else
                options.debug = false
            #endif

            // Adds IP for users.
            // For more information, visit: https://docs.sentry.io/platforms/apple/data-management/data-collected/
            options.sendDefaultPii = true

            // 卡顿时间
            options.appHangTimeoutInterval = 1.0
        }
    }

    public init(configureOptions: @escaping (Options) -> Void) {
        SentrySDK.start(configureOptions: configureOptions)
    }

    /// 上报方法
    /// - Parameters:
    ///   - data: 转换器返回的字符串信息
    ///   - extra: 附加的键值对信息
    public func onTracking(data: Any, extra: [AnyHashable: Any], converterChain: TrackerConverterChain) {
        if let error = data as? Error {
            SentrySDK.capture(error: error)
        } else {
            var extraCopy = extra
            let data = converterChain.convert(data: data, extra: &extraCopy)
            // 1️⃣ 判断 breadcrumb 类型
            let breadcrumbLevel: SentryLevel = {
                let lower = data.lowercased()
                if lower.contains("error") || lower.contains("exception") || lower.contains("fail") {
                    return .error
                } else {
                    return .info
                }
            }()

            // 2️⃣ 留下 Breadcrumb
            let breadcrumb = Breadcrumb()
            breadcrumb.level = breadcrumbLevel
            breadcrumb.message = data
            breadcrumb.data = extra.reduce(into: [String: Any]()) { dict, pair in
                let (key, value) = pair
                dict[String(describing: key)] = value
            }
            SentrySDK.addBreadcrumb(breadcrumb)

            // 4️⃣ 上报到 Sentry
            SentrySDK.capture(message: data)
        }
    }
}
