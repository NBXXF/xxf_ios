//
//  IllegalArgumentError.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

// 定义一个错误类型，类似 Java/Kotlin 的 IllegalArgumentException
open class IllegalArgumentError: AppError, @unchecked Sendable {
    override public var description: String {
        return "IllegalArgumentError: \(message)"
    }

    public init(_ message: String) {
        super.init(message)
    }
}
