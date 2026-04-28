//
//  Untitled.swift
//  xxf_ios
//  UserDefaults 实现的key-value存储
//  Created by xxf on 6/19.
//
import Foundation

open class UserDefaultsPreferenceProvider: PreferenceProvider {
    public static let storage: any PreferencesStorage & Sendable = UserDefaults.standard

    public init() {}
//
//    /// 非可选值，必须提供默认值
//    @PreferenceBinding<Int, PreferencesDemo>("loginCount", default: 0)
//    var loginCount: Int?
//
//    /// 可选值，自动默认 nil（支持 @PreferenceBinding("nickname") 简写）
//    @PreferenceBinding<String, PreferencesDemo>("nickname", default: "")
//    var nickname: String?
//
//    /// 可选值，也可以指定默认值
//    @PreferenceBinding<String, PreferencesDemo>("region", default: "CN")
//    var region: String?
//
//    @PreferenceBinding<Profile, PreferencesDemo>("profile", default: nil)
//    var profile: Profile?
//
//    /// Codable 类型（可选）
//    struct Profile: Codable {
//        var name: String
//        var age: Int
//    }
}
