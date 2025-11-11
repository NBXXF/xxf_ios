//
//  DatabaseOperationError.swift
//  xxf_ios
//  准确记录异常,主要是数据库的service 方法命名相似性较高
//  Created by xxfon /6/4.
//

import Foundation

public struct DatabaseOperationError: LocalizedError {
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

    public init(
        underlyingError: Error,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        self.underlyingError = underlyingError
        self.file = (file as NSString).lastPathComponent
        self.function = function
        self.line = line
    }
}
