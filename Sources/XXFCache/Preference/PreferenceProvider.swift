//
//  PreferenceProvider.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

// MARK: - 持有者协议

public protocol PreferenceProvider: AnyObject {
    static var shared: Self { get }
    var storage: PreferencesStorage { get }
}
