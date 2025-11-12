//
//  DatabaseHelper.swift
//  xxf_ios
//
//  Created by xxf on 7/16.
//
import XXFSpeed

public enum PrimaryKeyFormat {
    case raw // 原始拼接字符串
    case hashed // 哈希后的字符串
}

/// 根据多个字段拼接后生成主键（SHA256 哈希）
/// - Parameters:
///   - format: 生成的格式
///   - fields: 参与生成主键的字段
/// - Returns:
public func generatePrimaryKey(from fields: [String], format: PrimaryKeyFormat = .hashed) -> String {
    let joined = fields.joined(separator: "_")
    switch format {
        case .raw: return joined
        case .hashed: return joined.toXXH3String()
    }
}
