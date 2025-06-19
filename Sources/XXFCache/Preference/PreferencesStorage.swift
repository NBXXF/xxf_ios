//
//  PreferencesStorage.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//
import Foundation

// MARK: - 存储接口抽象，默认使用 UserDefaults

public protocol PreferencesStorage: AnyObject {
    func object(forKey key: String) -> Any?
    func set(_ value: Any?, forKey key: String)
    func removeObject(forKey key: String)
}

extension UserDefaults: PreferencesStorage {}
