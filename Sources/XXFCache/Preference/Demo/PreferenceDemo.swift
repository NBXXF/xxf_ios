//
//  PreferenceDemo.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

import Combine
import Foundation

final class PreferencesDemo: PreferenceProvider {
    nonisolated(unsafe) static let shared = PreferencesDemo()
    let storage: PreferencesStorage = UserDefaults.standard

    /// 非可选值，必须提供默认值
    @PreferenceBinding<Int,PreferencesDemo>("loginCount", default: 0)
     var loginCount: Int?

    /// 可选值，自动默认 nil（支持 @PreferenceBinding("nickname") 简写）
    @PreferenceBinding<String,PreferencesDemo>("nickname",default: "")
     var nickname: String?

    /// 可选值，也可以指定默认值
    @PreferenceBinding<String,PreferencesDemo>("region", default: "CN")
     var region: String?

    
    @PreferenceBinding<Profile,PreferencesDemo>("profile",default: nil)
     var profile: Profile?
    
    /// Codable 类型（可选）
    struct Profile: Codable {
        var name: String
        var age: Int
    }

}
