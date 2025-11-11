//
//  XattrWriter.swift
//  xxf_ios
//  支持任意类型
//  macos验证命令 xattr /path/to/file
//  Created by xxf 6/2.
//

import CoreGraphics // CGFloat
import Foundation

public final class XattrWriter {
    /// 写入扩展属性，支持基础类型及 Encodable 泛型
    public func write<T: Encodable>(
        path: String,
        key: String,
        value: T,
        flags: Int32 = 0,
        encoder: JSONEncoder = JSONEncoder()
    ) throws {
        requireChildThread()

        let data: Data

        /// 用if 来匹配更兼容范型
        if let str = value as? String {
            guard let d = str.data(using: .utf8) else {
                throw XattrError.encodingFailed
            }
            data = d

        } else if let int = value as? Int {
            var bigEndian = int.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let int8 = value as? Int8 {
            data = withUnsafeBytes(of: int8) { Data($0) }

        } else if let int16 = value as? Int16 {
            var bigEndian = int16.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let int32 = value as? Int32 {
            var bigEndian = int32.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let int64 = value as? Int64 {
            var bigEndian = int64.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let uint = value as? UInt {
            var bigEndian = uint.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let uint8 = value as? UInt8 {
            data = withUnsafeBytes(of: uint8) { Data($0) }

        } else if let uint16 = value as? UInt16 {
            var bigEndian = uint16.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let uint32 = value as? UInt32 {
            var bigEndian = uint32.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let uint64 = value as? UInt64 {
            var bigEndian = uint64.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        } else if let float = value as? Float {
            var bitPattern = float.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        } else if let double = value as? Double {
            var bitPattern = double.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        } else if let cgFloat = value as? CGFloat {
            #if arch(x86_64) || arch(arm64)
                var bitPattern = Double(cgFloat).bitPattern.bigEndian
            #else
                var bitPattern = Float(cgFloat).bitPattern.bigEndian
            #endif
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        } else if let bool = value as? Bool {
            data = Data([bool ? 1 : 0])

        } else if let date = value as? Date {
            var bitPattern = date.timeIntervalSince1970.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        } else if let array = value as? [String] {
            data = try PropertyListSerialization.data(fromPropertyList: array, format: .binary, options: 0)

        } else if let dict = value as? [String: Any] {
            guard PropertyListSerialization.propertyList(dict, isValidFor: .binary) else {
                throw XattrError.encodingFailed
            }
            data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)

        } else if let nsArray = value as? NSArray {
            guard PropertyListSerialization.propertyList(nsArray, isValidFor: .binary) else {
                throw XattrError.encodingFailed
            }
            data = try PropertyListSerialization.data(fromPropertyList: nsArray, format: .binary, options: 0)

        } else if let nsDict = value as? NSDictionary {
            guard PropertyListSerialization.propertyList(nsDict, isValidFor: .binary) else {
                throw XattrError.encodingFailed
            }
            data = try PropertyListSerialization.data(fromPropertyList: nsDict, format: .binary, options: 0)

        } else if let nsSet = value as? NSSet {
            let array = nsSet.allObjects as NSArray
            guard PropertyListSerialization.propertyList(array, isValidFor: .binary) else {
                throw XattrError.encodingFailed
            }
            data = try PropertyListSerialization.data(fromPropertyList: array, format: .binary, options: 0)

        } else if let d = value as? Data {
            data = d

        } else {
            // fallback: JSON encode any other Encodable
            data = try encoder.encode(value)
        }

        try write(path: path, key: key, data: data, flags: flags)
    }

    /// 低层写入 Data 到 xattr
    private func write(
        path: String,
        key: String,
        data: Data,
        flags: Int32
    ) throws {
        let result = path.withCString { cPath in
            key.withCString { cKey in
                data.withUnsafeBytes { buffer in
                    setxattr(cPath, cKey, buffer.baseAddress, buffer.count, 0, flags)
                }
            }
        }

        if result != 0 {
            let err = errno
            throw XattrError.setxattrFailed(errno: err)
        }
    }
}
