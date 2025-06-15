//
//  ThreadLocalXXH128.swift
//  xxf_ios
//
//  Created by xxf/6/15.
//
import Foundation
import xxHash

public enum ThreadLocalXXH128 {
    private static let key = "com.xxf.threadLocal.xxhash128"

    private static func getInstance() -> xxHash128 {
        let threadDict = Thread.current.threadDictionary
        if let instance = threadDict[key] as? xxHash128 {
            return instance
        } else {
            let instance = try! xxHash128()
            threadDict[key] = instance
            return instance
        }
    }

    public static func hash(_ data: Data) -> (low: UInt64, high: UInt64) {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: [UInt8]) -> (low: UInt64, high: UInt64) {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: String) -> (low: UInt64, high: UInt64) {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hashString(_ data: String) -> String {
        let (low, high) = hash(data)
        return String(format: "%016llx%016llx", high, low)
    }
}
