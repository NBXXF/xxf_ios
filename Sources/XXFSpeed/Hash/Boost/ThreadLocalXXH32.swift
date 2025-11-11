//
//  ThreadLocalXXH64.swift
//  xxf_ios
//
//  Created by xxf/6/15.
//
import Foundation
import XXFXXHash

public enum ThreadLocalXXH32 {
    private static let key = "com.xxf.threadLocal.xxhash32"

    private static func getInstance() -> XXHash32 {
        let threadDict = Thread.current.threadDictionary
        if let instance = threadDict[key] as? XXHash32 {
            return instance
        } else {
            let instance = try! XXHash32()
            threadDict[key] = instance
            return instance
        }
    }

    public static func hash(_ data: Data) -> UInt32 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: [UInt8]) -> UInt32 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }

    public static func hash(_ data: String) -> UInt32 {
        var hasher = getInstance()
        try? hasher.reset()
        try? hasher.update(data)
        return hasher.digest()
    }
}
