//
//  DatabaseParamError.swift
//  xxf_ios
//  准确记录异常,主要是数据库的service 方法命名相似性较高
//  Created by xxfon /6/4.
//

import Foundation

public struct DatabaseParamError: LocalizedError {
    public let underlyingErrorMsg: String
    public let file: String
    public let function: String
    public let line: UInt

    public var errorDescription: String? {
        """
        Error at \(file):\(line) \(function)
        Underlying error: \(underlyingErrorMsg)
        """
    }

    public init(
        underlyingErrorMsg: String,
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        self.underlyingErrorMsg = underlyingErrorMsg
        self.file = (file as NSString).lastPathComponent
        self.function = function
        self.line = line
    }
}
