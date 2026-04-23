//
//  FirebaseTracker.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//

#if os(iOS)
import FirebaseCore
import FirebaseCrashlytics
import Foundation
import XXFTracker

/// 使用 Firebase Crashlytics 作为上报渠道
///
/// 建议先在 App 启动时完成 Firebase 初始化：`FirebaseApp.configure()`
open class FirebaseTracker: ChanelTracker {
    /// 是否已经初始化 Firebase
    public static var isConfigured: Bool {
        FirebaseApp.app() != nil
    }

    /// 如果还没初始化则尝试初始化
    /// - Returns: 是否执行了 `FirebaseApp.configure()`
    @discardableResult
    public static func configureIfNeeded() -> Bool {
        guard !isConfigured else { return false }
        FirebaseApp.configure()
        return true
    }

    /// - Parameter autoConfigureIfNeeded: 是否在初始化时自动调用 `configureIfNeeded()`
    public init(autoConfigureIfNeeded: Bool = false) {
        if autoConfigureIfNeeded {
            Self.configureIfNeeded()
        }
    }

    /// 上报方法
    /// - Parameters:
    ///   - data: 原始数据
    ///   - extra: 附加的键值对信息
    open func onTracking(data: Any, extra: [AnyHashable: Any], converterChain: TrackerConverterChain) {
        guard Self.isConfigured else {
            assertionFailure("FirebaseApp 尚未初始化，请先调用 FirebaseApp.configure()")
            return
        }

        let crashlytics = Crashlytics.crashlytics()

        // Crashlytics custom key 在下次崩溃也可能会被带上，这里仅承载轻量上下文
        for (key, value) in extra {
            crashlytics.setCustomValue(normalizeValue(value), forKey: String(describing: key))
        }

        if let error = data as? Error {
            crashlytics.record(error: error)
            return
        }

        var extraCopy = extra
        let message = converterChain.convert(data: data, extra: &extraCopy)
        crashlytics.log(message)

        var userInfo = extra.reduce(into: [String: Any]()) { dict, pair in
            let (key, value) = pair
            dict[String(describing: key)] = normalizeValue(value)
        }
        userInfo[NSLocalizedDescriptionKey] = message

        let nsError = NSError(
            domain: "com.xxf.tracker.firebase",
            code: 0,
            userInfo: userInfo
        )
        crashlytics.record(error: nsError)
    }

    private func normalizeValue(_ value: Any) -> Any {
        switch value {
        case is String, is NSNumber, is Int, is Double, is Float, is Bool:
            return value
        case let convertible as CustomStringConvertible:
            return convertible.description
        default:
            return String(describing: value)
        }
    }
}
#endif
