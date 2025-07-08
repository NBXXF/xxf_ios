//
//  FileTimes.swift
//  xxf_ios
//  文件时间
//  Created by xxf on 7/8.
//

import Foundation

/// 四个文件时间戳模型
public struct FileTimes {
    /// 文件创建时间（birthtime）
    public let creationTime: Date?
    /// 文件内容最后修改时间（mtime）
    public let modificationTime: Date?
    /// 文件最后访问时间（atime）
    public let accessTime: Date?
    /// 文件状态变更时间（ctime）
    public let changeTime: Date?
}
