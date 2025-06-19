//
//  PreferenceProvider.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

// MARK: - 持有者协议

/// 用法参考`UserDefaultsPreferenceProvider`
public protocol PreferenceProvider: AnyObject {
    static var storage: PreferencesStorage { get }
}
