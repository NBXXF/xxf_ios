//
//  FileManager+Operation.swift
//  xxf_ios
//  文件操作
//  Created by xxf on /6/2.
//

import Foundation

public extension FileManager {
    /**
     如果 newURL 已存在，会抛出错误：
     Error Domain=NSCocoaErrorDomain Code=516 "The file “b.txt” couldn’t be moved because a file with the same name already exists."
     */
    /// 重命名文件，不跨目录
    func renameItem(at url: URL, newName: String) throws -> URL {
        let newURL = url.deletingLastPathComponent().appendingPathComponent(newName)
        try moveItem(at: url, to: newURL)
        return newURL
    }
}
