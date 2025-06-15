//
//  URL+File.swift
//  xxf_ios
//
//  Created by trl on /6/15.
//

import Foundation

public extension URL {
    /// 返回当前平台下尽可能唯一、稳定的文件 ID，适用于 macOS / iOS。
    ///
    /// 结构类似于：
    /// - macOS: "vol:06A2F1CE-XXXX-XXXX-XXXX-XXXXXXXXXXXX-ino:123456"
    /// - iOS: "dev:16777220-ino:123456"
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 唯一标识符字符串，或path.hash
    func getFileId(forPath path: String) -> String {
        let fileURL = URL(fileURLWithPath: path)
        var statbuf = stat()
        guard lstat(path, &statbuf) == 0 else {
            return "\(path.hashValue)"
        }

        let inodeID = "ino:\(statbuf.st_ino)"
        let deviceID = "dev:\(statbuf.st_dev)"
        var volumeID = deviceID

        // macOS 上尝试 volumeUUID（iOS 上这段通常会失败）
        #if os(macOS)
            if let values = try? fileURL.resourceValues(forKeys: [.volumeUUIDStringKey]),
               let uuid = values.volumeUUIDString
            {
                volumeID = "vol:\(uuid)"
            } else {
                // fallback: 使用父目录路径 hash（不稳定）
                let volumeRoot = fileURL.deletingLastPathComponent()
                volumeID = "vhash:\(volumeRoot.absoluteString.hashValue)"
            }
        #endif
        return "\(volumeID)-\(inodeID)"
    }
}
