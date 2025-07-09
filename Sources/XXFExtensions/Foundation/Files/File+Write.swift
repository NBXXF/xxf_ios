//
//  File+Write.swift
//  xxf_ios
//  文件写入
//  Created by xxf on 7/9.
//

import Foundation

public extension Data {
    /// 写入到指定 URL，如果 `appending == true` 则追加写入，否则覆盖
    func write(to url: URL, appending: Bool) throws {
        if appending, FileManager.default.fileExists(atPath: url.path) {
            let fileHandle = try FileHandle(forWritingTo: url)
            try fileHandle.seekToEnd()
            try fileHandle.write(contentsOf: self)
            try fileHandle.close()
        } else {
            try write(to: url)
        }
    }
}

public extension String {
    /// 写入到指定 URL，如果 `appending == true` 则追加写入，否则覆盖
    func write(to url: URL, appending: Bool, encoding: String.Encoding = .utf8) throws {
        let data = self.data(using: encoding) ?? Data()
        try data.write(to: url, appending: appending)
    }
}
