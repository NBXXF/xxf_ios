//
//  EmptyBool.swift
//  xxf_ios
//
//  Bool 默认值 Provider
//
//  Created by xxf
//

import Foundation

/// Bool 默认值：`false`
public enum False: CodingDefaultValueProvider {
    public static let defaultValue: Bool = false
}

/// Bool 默认值：`true`
public enum True: CodingDefaultValueProvider {
    public static let defaultValue: Bool = true
}
