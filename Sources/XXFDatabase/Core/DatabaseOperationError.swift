//
//  DatabaseOperationError.swift
//  xxf_ios
//
//  Created by trl on 2025/6/4.
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
