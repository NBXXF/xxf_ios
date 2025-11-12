//
//  IllegalStateError.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

// 定义一个错误类型，类似 Java/Kotlin 的 IllegalArgumentException
open class IllegalStateError: AppError, @unchecked Sendable {
    public override var description: String {
        return "IllegalStateError: \(message)"
    }

    public init(_ message: String) {
        super.init(message)
    }
}
