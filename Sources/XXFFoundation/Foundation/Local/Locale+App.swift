//
//  Locale+App.swift
//  xxf_ios
//
//  Created by xxf on 8/31.
//

import Foundation
import ObjectiveC

private nonisolated(unsafe) var associatedAppLocaleKey: UInt8 = 0

public extension Notification.Name {
    /// 应用内自定义 Locale 变化通知
    static let appLocaleDidChange = Notification.Name("AppLocaleDidChange")
}

public extension Locale {
    private nonisolated(unsafe) static var _appLocale: Locale = .current

    /// 应用内全局可修改 Locale,仅内存缓存,未持久化,方便非主工程的库来使用
    /// 自带.current 是系统的设置
    static var appLocale: Locale {
        get { _appLocale }
        set {
            _appLocale = newValue
            NotificationCenter.default.post(
                name: .appLocaleDidChange,
                object: Locale.self,
                userInfo: ["locale": newValue]
            )
        }
    }
}
