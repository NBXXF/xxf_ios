//
//  XattrWriter.swift
//  xxf_ios
//  支持任意类型
//  Created by xxf 6/2.
//
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

        // 针对基础类型特殊处理，避免无谓 JSON 编码
        switch value {
        case let str as String:
            guard let d = str.data(using: .utf8) else { throw XattrError.encodingFailed }
            data = d

        case let int as Int:
            data = withUnsafeBytes(of: int.bigEndian) { Data($0) }

        case let int64 as Int64:
            data = withUnsafeBytes(of: int64.bigEndian) { Data($0) }

        case let float as Float:
            data = withUnsafeBytes(of: float.bitPattern.bigEndian) { Data($0) }

        case let double as Double:
            data = withUnsafeBytes(of: double.bitPattern.bigEndian) { Data($0) }

        case let bool as Bool:
            data = Data([bool ? 1 : 0])

        case let date as Date:
            let timestamp = date.timeIntervalSince1970
            data = withUnsafeBytes(of: timestamp.bitPattern.bigEndian) { Data($0) }

        case let array as [String]:
            data = try encoder.encode(array)

        case let dict as [String: Any]:
            guard JSONSerialization.isValidJSONObject(dict) else {
                throw XattrError.encodingFailed
            }
            data = try JSONSerialization.data(withJSONObject: dict, options: [])

        case let d as Data:
            data = d

        default:
            // 泛型 Encodable fallback 到 JSON
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
