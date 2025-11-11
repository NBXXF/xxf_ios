//
//  TimeZone.swift
//  xxf_ios
//
//  Created by xxf on 8/31.
//
public extension Notification.Name {
    static let appTimeZoneDidChange = Notification.Name("AppTimeZoneDidChange")
}

public extension TimeZone {
    private nonisolated(unsafe) static var _appTimeZone: TimeZone = .current

    /// 应用内全局可修改 TimeZone（不影响系统），仅内存缓存,未持久化,方便非主工程的库来使用
    static var appTimeZone: TimeZone {
        get { _appTimeZone }
        set {
            _appTimeZone = newValue
            NotificationCenter.default.post(
                name: .appTimeZoneDidChange,
                object: TimeZone.self,
                userInfo: ["timeZone": newValue]
            )
        }
    }
}
