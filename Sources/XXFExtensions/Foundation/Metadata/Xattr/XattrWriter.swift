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
        let data: Data

        switch value {
        case let str as String:
            guard let d = str.data(using: .utf8) else { throw XattrError.encodingFailed }
            data = d

        case let int as Int:
            var bigEndian = int.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let int8 as Int8:
            data = withUnsafeBytes(of: int8) { Data($0) }

        case let int16 as Int16:
            var bigEndian = int16.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let int32 as Int32:
            var bigEndian = int32.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let int64 as Int64:
            var bigEndian = int64.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let uint as UInt:
            var bigEndian = uint.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let uint8 as UInt8:
            data = withUnsafeBytes(of: uint8) { Data($0) }

        case let uint16 as UInt16:
            var bigEndian = uint16.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let uint32 as UInt32:
            var bigEndian = uint32.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let uint64 as UInt64:
            var bigEndian = uint64.bigEndian
            data = withUnsafeBytes(of: &bigEndian) { Data($0) }

        case let float as Float:
            var bitPattern = float.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        case let double as Double:
            var bitPattern = double.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        case let cgFloat as CGFloat:
            #if arch(x86_64) || arch(arm64)
                // CGFloat 实际是 Double
                var bitPattern = Double(cgFloat).bitPattern.bigEndian
                data = withUnsafeBytes(of: &bitPattern) { Data($0) }
            #else
                // 32位架构，CGFloat 是 Float
                var bitPattern = Float(cgFloat).bitPattern.bigEndian
                data = withUnsafeBytes(of: &bitPattern) { Data($0) }
            #endif

        case let bool as Bool:
            data = Data([bool ? 1 : 0])

        case let date as Date:
            var bitPattern = date.timeIntervalSince1970.bitPattern.bigEndian
            data = withUnsafeBytes(of: &bitPattern) { Data($0) }

        case let array as [String]:
            // 用 plist（二进制格式）编码
            data = try PropertyListSerialization.data(fromPropertyList: array, format: .binary, options: 0)

        case let dict as [String: Any]:
            guard PropertyListSerialization.propertyList(dict, isValidFor: .binary) else {
                throw XattrError.encodingFailed
            }
            data = try PropertyListSerialization.data(fromPropertyList: dict, format: .binary, options: 0)

        case let d as Data:
            data = d

        default:
            // 其他泛型Encodable使用JSON编码
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
