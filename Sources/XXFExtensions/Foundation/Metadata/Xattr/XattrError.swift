//  XattrError.swift
//
//  Created by xxf 6/2.
//
import Foundation

public enum XattrError: Error, LocalizedError {
    case unsupportedType
    case encodingFailed
    case setxattrFailed(errno: Int32)

    public var errorDescription: String? {
        switch self {
        case .unsupportedType:
            return "Unsupported attribute type"
        case .encodingFailed:
            return "Failed to encode as UTF-8 or JSON"
        case let .setxattrFailed(err):
            return "Failed to set extended attribute: \(String(cString: strerror(err)))"
        }
    }
}
