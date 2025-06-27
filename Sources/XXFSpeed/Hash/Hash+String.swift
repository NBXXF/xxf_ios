//
//  Hash+String.swift
//  xxf_ios
//  快速hash算法
//  Created by xxf on 6/15.
//
import Foundation

/**
 Prodcut                Width           Bandwidth (GB/s)
 XXH3:                    64                 31.5 GB/s
 XXH128               128                 29.6 GB/s
 XXH64                  64                  19.4 GB/s
 HighwayHash64   64                  18.1 GB/s
 XXH32                  32                  9.7 GB/s    71.9
 */
public extension String {
    func toXXH3() -> UInt64 {
        return ThreadLocalXXH3.hash(self)
    }

    /// 返回字符串
    func toXXH3String() -> String {
        return String(ThreadLocalXXH3.hash(self))
    }

    func toXXH32() -> UInt32 {
        return ThreadLocalXXH32.hash(self)
    }

    func toXXH64() -> UInt64 {
        return ThreadLocalXXH64.hash(self)
    }

    func toXXH128() -> (low: UInt64, high: UInt64) {
        return ThreadLocalXXH128.hash(self)
    }

    func toXXH128String() -> String {
        return ThreadLocalXXH128.hashString(self)
    }

    func toHighwayHash64() -> UInt64 {
        return ThreadLocalHighwayHash.hash(self)
    }
}
