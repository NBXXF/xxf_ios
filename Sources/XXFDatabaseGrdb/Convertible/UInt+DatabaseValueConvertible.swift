//
//  UIntDatabaseValueConvertible.swift
//  xxf_ios
//  支持所有无符号整数数据库自动转换,建表的时候声明成.blob类型就可以了
//  blob类型比string/text 性能更好
//  Created by trl on 6/15.
//

import Foundation
import GRDB

private protocol _XXFDatabaseUIntCompatible: FixedWidthInteger, UnsignedInteger {}

extension UInt: _XXFDatabaseUIntCompatible {}
extension UInt8: _XXFDatabaseUIntCompatible {}
extension UInt16: _XXFDatabaseUIntCompatible {}
extension UInt32: _XXFDatabaseUIntCompatible {}
extension UInt64: _XXFDatabaseUIntCompatible {}

extension _XXFDatabaseUIntCompatible {
    public var databaseValue: DatabaseValue {
        var le = littleEndian
        let data = withUnsafeBytes(of: &le) { Data($0) }
        return data.databaseValue
    }

    public static func fromDatabaseValue(_ dbValue: DatabaseValue) -> Self? {
        switch dbValue.storage {
        case let .int64(intValue):
            guard intValue >= 0 else { return nil }
            return Self(exactly: UInt64(bitPattern: intValue))

        case let .blob(blob):
            guard blob.count == MemoryLayout<Self>.size else { return nil }
            return blob.withUnsafeBytes {
                $0.load(as: Self.self).littleEndian
            }

        default:
            return nil
        }
    }
}
