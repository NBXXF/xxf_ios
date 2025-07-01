//
//  XattrReader.swift
//  xxf_ios
//  支持任意类型
//  Created by xxf 6/2.
//

import Foundation

public final class XattrReader {
    /// 读取扩展属性，自动反序列化为对应类型
    public func read<T: Decodable>(
        path: String,
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        let data = try getData(path: path, key: key)

        switch type {
        case is String.Type:
            guard let str = String(data: data, encoding: .utf8) else {
                throw XattrError.encodingFailed
            }
            return str as! T

        case is Int.Type:
            guard data.count == MemoryLayout<Int>.size else {
                throw XattrError.encodingFailed
            }
            let value = data.withUnsafeBytes { $0.load(as: Int.self).bigEndian }
            return value as! T

        case is Int64.Type:
            guard data.count == MemoryLayout<Int64>.size else {
                throw XattrError.encodingFailed
            }
            let value = data.withUnsafeBytes { $0.load(as: Int64.self).bigEndian }
            return value as! T

        case is Float.Type:
            guard data.count == MemoryLayout<UInt32>.size else {
                throw XattrError.encodingFailed
            }
            let bitPattern = data.withUnsafeBytes { $0.load(as: UInt32.self).bigEndian }
            return Float(bitPattern: bitPattern) as! T

        case is Double.Type:
            guard data.count == MemoryLayout<UInt64>.size else {
                throw XattrError.encodingFailed
            }
            let bitPattern = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
            return Double(bitPattern: bitPattern) as! T

        case is Bool.Type:
            guard data.count == 1 else {
                throw XattrError.encodingFailed
            }
            return (data[0] != 0) as! T

        case is Date.Type:
            guard data.count == MemoryLayout<UInt64>.size else {
                throw XattrError.encodingFailed
            }
            let bitPattern = data.withUnsafeBytes { $0.load(as: UInt64.self).bigEndian }
            let timestamp = TimeInterval(bitPattern: bitPattern)
            return Date(timeIntervalSince1970: timestamp) as! T

        case is Data.Type:
            return data as! T

        default:
            return try decoder.decode(T.self, from: data)
        }
    }

    /// 低层读取原始 Data
    func getData(path: String, key: String) throws -> Data {
        let length = getxattr(path, key, nil, 0, 0, 0)
        if length < 0 {
            let err = errno
            throw XattrError.setxattrFailed(errno: err)
        }
        var data = Data(count: length)
        let readLen = data.withUnsafeMutableBytes {
            getxattr(path, key, $0.baseAddress, length, 0, 0)
        }
        if readLen < 0 {
            let err = errno
            throw XattrError.setxattrFailed(errno: err)
        }
        return data
    }
}
