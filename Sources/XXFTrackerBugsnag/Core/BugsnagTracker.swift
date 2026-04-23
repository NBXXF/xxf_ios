//  BugsnagTracker.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

import Bugsnag

// import BugsnagPerformance
import Foundation
import XXFTracker

/// 使用 Bugsnag 作为上报渠道
open class BugsnagTracker: ChanelTracker {
    /// 初始化
    /// - Parameters:
    ///   - apiKey: appkey
    public init(apiKey: String) {
        guard !Bugsnag.isStarted() else { return }

        // —— 1. 配置 Crash + Hang 检测 ——
        let config = BugsnagConfiguration(apiKey)
        config.releaseStage = Self.detectEnvironment()
        config.appVersion = Self.detectAppVersion()
        config.autoTrackSessions = true
        config.enabledErrorTypes.appHangs = true
        config.enabledBreadcrumbTypes = [.navigation, .user, .log, .state]

        // 可选：自定义 beforeSend 逻辑
        config.addOnSendError { _ in
            // 过滤开发环境、或特定错误等
            true
        }

        // 启动 Bugsnag（会自动捕获 Crash、Signal Crash、OOM、Hang）
        Bugsnag.start(with: config)

//        // —— 2. 配置 Performance Monitoring ——
//        // 如果你希望收集网络、UI 渲染等性能指标
//        let perfConfig = BugsnagPerformanceConfiguration(apiKey: apiKey)
//        // 可选：调整采样率或自定义事务埋点
//        // perfConfig.sampleRate = 0.5  // 50% 采样
//        BugsnagPerformance.start(configuration: perfConfig)
    }

    public init(config: BugsnagConfiguration
        //   perfConfig: BugsnagPerformanceConfiguration? = nil
    ) {
        guard !Bugsnag.isStarted() else { return }

        // 启动 Bugsnag（会自动捕获 Crash、Signal Crash、OOM、Hang）
        Bugsnag.start(with: config)
//
//        // 如果你希望收集网络、UI 渲染等性能指标
//        if let perfConfig = perfConfig {
//            BugsnagPerformance.start(configuration: perfConfig)
//        }
    }

    // MARK: - 可选辅助方法

    private static func detectEnvironment() -> String {
        #if DEBUG
            return "development"
        #else
            return "production"
        #endif
    }

    private static func detectAppVersion() -> String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown"
    }

    /// 上报到 Bugsnag
    /// - Parameters:
    ///   - data: 原始数据
    ///   - extra: 附加的键值对信息
    open func onTracking(data: Any, extra: [AnyHashable: Any], converterChain: TrackerConverterChain) {
        // 创建一个可变副本
        var extraCopy = extra
        let data = converterChain.convert(data: data, extra: &extraCopy)
        // 1. 判断 breadcrumb 类型
        let breadcrumbType: BSGBreadcrumbType = {
            let lower = data.lowercased()
            if lower.contains("error") || lower.contains("exception") || lower.contains("fail") {
                return .error
            } else {
                return .log
            }
        }()

        // 2. 留下面包屑
        Bugsnag.leaveBreadcrumb(
            data,
            metadata: extra,
            type: breadcrumbType
        )

        // 3. 构造 userInfo
        var userInfo = extra.reduce(into: [String: Any]()) { dict, pair in
            let (key, value) = pair
            dict[String(describing: key)] = value
        }

        // 如果存在错误名，设置错误描述
        if let errorName = extra[ErrorTrackerConverter.KEY_ERROR_NAME] as? String {
            userInfo[NSLocalizedDescriptionKey] = errorName
        }

        // 4. 无论如何都上报错误
        let nsError = NSError(
            domain: "com.xxf.tracker",
            code: 0,
            userInfo: userInfo
        )
        Bugsnag.notifyError(nsError)
    }
}
