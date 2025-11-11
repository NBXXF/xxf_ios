//
//  XattrReader.swift
//  xxf_ios
//  支持任意类型
//  macos验证命令 xattr /path/to/file
//  Created by xxf 6/2.
//

import CoreGraphics // CGFloat
import Foundation

public final class XattrReader {
    /// 读取扩展属性，自动反序列化为对应类型
    /// - 兼容 plist (XML/Binary) 和 JSON 格式数据，先用 plist 解析，失败后用 JSONDecoder 解码
    public func read<T: Decodable>(
        path: String,
        key: String,
        as type: T.Type,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        /// requireChildThread()，读取现在有业务必须在主线程,读取比写入快

        let data = try getData(path: path, key: key)

        switch type {
        case is String.Type:
            guard let str = String(data: data, encoding: .utf8) else {
                throw XattrError.encodingFailed
            }
            return str as! T

        case is [String].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [String]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is Int.Type:
            guard data.count == MemoryLayout<Int>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: Int.self) }
            let value = Int(bigEndian: raw)
            return value as! T

        case is [Int].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [Int]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is Int8.Type:
            guard data.count == MemoryLayout<Int8>.size else { throw XattrError.encodingFailed }
            let value = data.withUnsafeBytes { $0.load(as: Int8.self) }
            return value as! T

        case is Int16.Type:
            guard data.count == MemoryLayout<Int16>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: Int16.self) }
            let value = Int16(bigEndian: raw)
            return value as! T

        case is Int32.Type:
            guard data.count == MemoryLayout<Int32>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: Int32.self) }
            let value = Int32(bigEndian: raw)
            return value as! T

        case is Int64.Type:
            guard data.count == MemoryLayout<Int64>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: Int64.self) }
            let value = Int64(bigEndian: raw)
            return value as! T

        case is [Int64].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [Int64]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is UInt.Type:
            guard data.count == MemoryLayout<UInt>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt.self) }
            let value = UInt(bigEndian: raw)
            return value as! T

        case is UInt8.Type:
            guard data.count == MemoryLayout<UInt8>.size else { throw XattrError.encodingFailed }
            let value = data.withUnsafeBytes { $0.load(as: UInt8.self) }
            return value as! T

        case is UInt16.Type:
            guard data.count == MemoryLayout<UInt16>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt16.self) }
            let value = UInt16(bigEndian: raw)
            return value as! T

        case is UInt32.Type:
            guard data.count == MemoryLayout<UInt32>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            let value = UInt32(bigEndian: raw)
            return value as! T

        case is UInt64.Type:
            guard data.count == MemoryLayout<UInt64>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt64.self) }
            let value = UInt64(bigEndian: raw)
            return value as! T

        case is [UInt64].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [UInt64]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is Float.Type:
            guard data.count == MemoryLayout<UInt32>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
            let bitPattern = UInt32(bigEndian: raw)
            return Float(bitPattern: bitPattern) as! T

        case is [Float].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [Float]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is Double.Type:
            guard data.count == MemoryLayout<UInt64>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt64.self) }
            let bitPattern = UInt64(bigEndian: raw)
            return Double(bitPattern: bitPattern) as! T

        case is [Double].Type:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil),
               let array = plistObject as? [Double]
            {
                return array as! T
            }
            throw XattrError.encodingFailed

        case is CGFloat.Type:
            #if arch(x86_64) || arch(arm64)
                guard data.count == MemoryLayout<UInt64>.size else { throw XattrError.encodingFailed }
                let raw = data.withUnsafeBytes { $0.load(as: UInt64.self) }
                let bitPattern = UInt64(bigEndian: raw)
                return CGFloat(Double(bitPattern: bitPattern)) as! T
            #else
                guard data.count == MemoryLayout<UInt32>.size else { throw XattrError.encodingFailed }
                let raw = data.withUnsafeBytes { $0.load(as: UInt32.self) }
                let bitPattern = UInt32(bigEndian: raw)
                return CGFloat(Float(bitPattern: bitPattern)) as! T
            #endif

        case is Bool.Type:
            guard data.count == 1 else { throw XattrError.encodingFailed }
            return (data[0] != 0) as! T

        case is Date.Type:
            guard data.count == MemoryLayout<UInt64>.size else { throw XattrError.encodingFailed }
            let raw = data.withUnsafeBytes { $0.load(as: UInt64.self) }
            let bitPattern = UInt64(bigEndian: raw)
            let timestamp = TimeInterval(bitPattern: bitPattern)
            return Date(timeIntervalSince1970: timestamp) as! T

        case is Data.Type:
            return data as! T

        default:
            if let plistObject = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) {
                if JSONSerialization.isValidJSONObject(plistObject),
                   let jsonData = try? JSONSerialization.data(withJSONObject: plistObject, options: [])
                {
                    return try decoder.decode(T.self, from: jsonData)
                }
                do {
                    let decoderPlist = PropertyListDecoder()
                    return try decoderPlist.decode(T.self, from: data)
                } catch {
                    throw error
                }
            }

            do {
                return try decoder.decode(T.self, from: data)
            } catch {
                if let str = String(data: data, encoding: .utf8),
                   let casted = str as? T
                {
                    return casted
                }
                throw error
            }
        }
    }

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
