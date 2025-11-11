//
//  JsonError.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

import Foundation

public enum JsonError: Error, LocalizedError, Sendable {
    case invalidJSONObject(originalObjectDescription: String)
    case failedToEncodeToUTF8(originalDataDescription: String)

    public var errorDescription: String? {
        switch self {
        case let .invalidJSONObject(desc):
            return "Invalid JSON object: \(desc)"
        case let .failedToEncodeToUTF8(desc):
            return "Failed to encode JSON to UTF-8 string. Original data: \(desc)"
        }
    }
}
