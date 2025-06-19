//
//  PreferenceDemo.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Combine
import Foundation

final class PreferencesDemo: PreferenceProvider {
    static let shared = PreferencesDemo()
    let storage: PreferencesStorage = UserDefaults.standard

    /// 非可选值，必须提供默认值
    @PreferenceBinding("loginCount", default: 0)
    static var loginCount: Int

    /// 可选值，自动默认 nil（支持 @PreferenceBinding("nickname") 简写）
    @PreferenceBinding("nickname")
    static var nickname: String?

    /// 可选值，也可以指定默认值
    @PreferenceBinding("region", default: "CN")
    static var region: String?

    /// Codable 类型（可选）
    struct Profile: Codable {
        var name: String
        var age: Int
    }

    @PreferenceBinding("profile")
    static var profile: Profile?
}
