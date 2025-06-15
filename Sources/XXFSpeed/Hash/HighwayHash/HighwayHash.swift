//
//  HighwayHash.swift
//  xxf_ios
//
//  Created by trl on 6/15.
//
import XXFSpeedC
import Foundation

public struct HighwayHash {
    // 默认固定32字节key（这里用全0，也可以换成你想要的任意32字节）
    private static let defaultKey: [UInt8] = Array(repeating: 0, count: 32)

    /// 计算64位hash，默认用固定key
    public static func hash64(data: Data, key: [UInt8]? = nil) -> UInt64 {
        let key = key ?? defaultKey
        precondition(key.count == 32, "Key must be 32 bytes")
        return key.withUnsafeBufferPointer { keyPtr in
            data.withUnsafeBytes { dataPtr in
                HH_hash64(keyPtr.baseAddress!, dataPtr.baseAddress!.assumingMemoryBound(to: UInt8.self), data.count)
            }
        }
    }

    /// 计算128位hash，默认用固定key
    public static func hash128(data: Data, key: [UInt8]? = nil) -> (low: UInt64, high: UInt64) {
        let key = key ?? defaultKey
        precondition(key.count == 32, "Key must be 32 bytes")
        var out = [UInt64](repeating: 0, count: 2)
        key.withUnsafeBufferPointer { keyPtr in
            data.withUnsafeBytes { dataPtr in
                HH_hash128(keyPtr.baseAddress!, dataPtr.baseAddress!.assumingMemoryBound(to: UInt8.self), data.count, &out)
            }
        }
        return (low: out[0], high: out[1])
    }
    
    ///计算128位hash，默认用固定key,结果是唯一的字符串
    public static func hash128String(data: Data, key: [UInt8]? = nil) -> String {
        let (low, high) = hash128(data: data, key: key)
        // 拼接成32位16进制字符串（16个字符 + 16个字符）
        return String(format: "%016llx%016llx", high, low)
    }
}
