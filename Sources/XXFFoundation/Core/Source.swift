//
//  Source.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

/// 生成在源码的唯一位置id
/// - Parameters:
///   - file: 文件
///   - function: 方法
///   - line: 代码行数
/// - Returns: 在源码中的唯一位置
@inlinable
public func sourceCodeLocationID(
    file: String = #fileID,
    function: String = #function,
    line: Int = #line,
    separator: String = ":"
) -> String {
    return "\(file)\(separator)\(function)\(separator)\(line)"
}
