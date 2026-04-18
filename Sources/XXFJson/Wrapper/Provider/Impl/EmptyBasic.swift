//
//  EmptyBasic.swift
//  xxf_ios
//
//  基础数值 / 字符串类型的内置默认值 Provider
//
//  Created by xxf
//

import Foundation

// MARK: - String

/// String 默认值：`""`
public enum EmptyString: CodingDefaultValueProvider {
    public static let defaultValue: String = ""
}

// MARK: - 整型

/// Int 默认值：`0`
public enum EmptyInt: CodingDefaultValueProvider {
    public static let defaultValue: Int = 0
}

/// Int8 默认值：`0`
public enum EmptyInt8: CodingDefaultValueProvider {
    public static let defaultValue: Int8 = 0
}

/// Int16 默认值：`0`
public enum EmptyInt16: CodingDefaultValueProvider {
    public static let defaultValue: Int16 = 0
}

/// Int32 默认值：`0`
public enum EmptyInt32: CodingDefaultValueProvider {
    public static let defaultValue: Int32 = 0
}

/// Int64 默认值：`0`
public enum EmptyInt64: CodingDefaultValueProvider {
    public static let defaultValue: Int64 = 0
}

// MARK: - 无符号整型

/// UInt 默认值：`0`
public enum EmptyUInt: CodingDefaultValueProvider {
    public static let defaultValue: UInt = 0
}

/// UInt8 默认值：`0`
public enum EmptyUInt8: CodingDefaultValueProvider {
    public static let defaultValue: UInt8 = 0
}

/// UInt16 默认值：`0`
public enum EmptyUInt16: CodingDefaultValueProvider {
    public static let defaultValue: UInt16 = 0
}

/// UInt32 默认值：`0`
public enum EmptyUInt32: CodingDefaultValueProvider {
    public static let defaultValue: UInt32 = 0
}

/// UInt64 默认值：`0`
public enum EmptyUInt64: CodingDefaultValueProvider {
    public static let defaultValue: UInt64 = 0
}

// MARK: - 浮点型

/// Float 默认值：`0.0`
public enum EmptyFloat: CodingDefaultValueProvider {
    public static let defaultValue: Float = 0
}

/// Double 默认值：`0.0`
public enum EmptyDouble: CodingDefaultValueProvider {
    public static let defaultValue: Double = 0
}
