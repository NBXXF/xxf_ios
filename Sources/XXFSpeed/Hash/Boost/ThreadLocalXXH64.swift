//
//  ThreadLocalXXH64.swift
//  xxf_ios
//
//  Created by xxf/6/15.
//
import Foundation
import XXFXXHash

public enum ThreadLocalXXH64 {
    private static let key = "com.xxf.threadLocal.xxhash64"

    private static func getInstance() -> XXHash64 {
        let threadDict = Thread.current.threadDictionary
        if let instance = threadDict[key] as? XXHash64 {
            return instance
        } else {
            let instance = try! XXHash64()
            threadDict[key] = instance
            return instance
        }
    }

    public static func hash(_ data: Data) -> UInt64 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: [UInt8]) -> UInt64 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: String) -> UInt64 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }
}
