//
//  IllegalArgumentError.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

// 定义一个错误类型，类似 Java/Kotlin 的 IllegalArgumentException
public struct IllegalArgumentError: Error, CustomStringConvertible {
    public let message: String

    public var description: String {
        return "IllegalArgumentError: \(message)"
    }

    public init(_ message: String) {
        self.message = message
    }
}
