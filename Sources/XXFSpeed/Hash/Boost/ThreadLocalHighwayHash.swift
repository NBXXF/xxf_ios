//
//  ThreadLocalHighwayHash.swift
//  xxf_ios
//
//  Created by xxf/6/15.
//
import Foundation
import HighwayHash

public enum ThreadLocalHighwayHash {
    private static let key = "com.xxf.threadLocal.highwayhash"

    private static func getInstance() -> HighwayHash {
        let threadDict = Thread.current.threadDictionary
        if let instance = threadDict[key] as? HighwayHash {
            return instance
        } else {
            let instance = HighwayHash(seed: Seed.defaultConstant)
            threadDict[key] = instance
            return instance
        }
    }

    public static func hash(_ data: Data) -> UInt64 {
        return getInstance().hash(data: data)
    }

    public static func hash(_ data: String) -> UInt64 {
        return getInstance().hash(data: data.data(using: .utf8)!)
    }
}
