//
//  ThreadLocalXXH3.swift
//  xxf_ios
//
//  Created by xxf/6/15.
//

import Foundation

public enum ThreadLocalXXH3 {
    private static let key = "com.xxf.threadLocal.xxhash3"

    private static func getInstance() -> xxHash3 {
        let threadDict = Thread.current.threadDictionary
        if let instance = threadDict[key] as? xxHash3 {
            return instance
        } else {
            let instance = try! xxHash3()
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
