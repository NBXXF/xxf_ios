//
//  SwiftFormatConfig.swift
//  xxf_ios
//
//  Created by xxf on 2025/11/12.
//

// xxf_ios/XXFSwiftFormat/SwiftFormatConfig.swift
import Foundation

public struct SwiftFormatConfig {
    /// 返回当前包版本下的 .swiftformat 文件路径
    public static var path: String {
        // #filePath 会返回当前 Swift 文件的绝对路径
        let fileURL = URL(fileURLWithPath: #filePath)
        // 替换文件名，指向 .swiftformat
        return fileURL
            .deletingLastPathComponent()
            .appendingPathComponent(".swiftformat")
            .path
    }
}
