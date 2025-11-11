//
//  Data+XXFExtension.swift
//  xxf_ios
//
//  Created by xxf on 8/5.
//

import Foundation

public extension Data {
    /// 将当前 Data 写入指定 URL，采用覆盖写入策略。
    ///
    /// - Parameters:
    ///   - url: 目标文件的 URL，支持本地文件路径。
    ///   - atomically: 是否使用原子写入（默认 true）。原子写入能确保写入完整性，避免文件损坏。
    /// - Throws: 写入失败会抛出错误，如权限问题、磁盘空间不足等。
    func writeOverwrite(to url: URL, atomically: Bool = true) throws {
        let options: Data.WritingOptions = atomically ? .atomic : []
        try write(to: url, options: options)
    }

    /// 将当前 Data 追加写入指定 URL。
    ///
    /// - 如果文件不存在，则创建新文件并写入；
    /// - 如果文件已存在，则追加到文件末尾；
    ///
    /// - Parameter url: 目标文件的 URL。
    /// - Throws: 写入失败会抛出错误。
    func writeAppend(to url: URL) throws {
        let fileManager = FileManager.default

        if !fileManager.fileExists(atPath: url.path) {
            try writeOverwrite(to: url)
        } else {
            let fileHandle = try FileHandle(forWritingTo: url)
            defer { try? fileHandle.close() }
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: self)
        }
    }
}
