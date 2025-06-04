//
//  DatabaseOperationError.swift
//  xxf_ios
//  准确记录异常,主要是数据库的service 方法命名相似性较高
//  Created by xxfon 2025/6/4.
//

import Foundation

public struct DatabaseOperationError: Error, LocalizedError {
    public let underlyingError: Error
    public let file: String
    public let function: String
    public let line: UInt

    public var errorDescription: String? {
        """
        Error at \(file):\(line) \(function)
        Underlying error: \(underlyingError.localizedDescription)
        """
    }
}
