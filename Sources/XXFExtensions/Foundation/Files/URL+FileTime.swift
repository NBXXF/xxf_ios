//
//  URL+FileTime.swift
//  xxf_ios
//  文件的时间
//  Created by xxf on 7/8.
//

import Foundation

public extension URL {
    ///  一次性通过 `stat()` 获取并返回文件的所有时间戳
    ///
    /// - Returns: 一个 `FileTimes` 实例，包含：
    ///   - `creationTime`：文件创建时间（birthtime）
    ///   - `modificationTime`：文件内容最后修改时间（mtime）
    ///   - `accessTime`：文件最后访问时间（atime）
    ///   - `changeTime`：文件状态变更时间（ctime）
    ///
    /// **注意对比：**
    /// - Spotlight/MDItem (`kMDItemFSCreationDate`、`kMDItemFSContentChangeDate`、`kMDItemLastUsedDate`)
    ///   与本方法的 `creationTime`、`modificationTime`、`accessTime` 一致（Spotlight 更新有延迟）。
    /// - Spotlight/MDItem 无法获取 `ctime`，只能通过底层 `stat()` 系统调用获得。
    func stFileTimes() -> FileTimes {
        // 调用 stat
        var info = stat()
        let success = stat(path, &info) == 0

        func date(from ts: timespec) -> Date {
            Date(timeIntervalSince1970: TimeInterval(ts.tv_sec)
                + TimeInterval(ts.tv_nsec) / 1_000_000_000)
        }

        // birthtime
        #if os(macOS)
            let birth = success ? date(from: info.st_birthtimespec) : nil
        #else
            let birth = success ? date(from: info.st_ctimespec) : nil
        #endif

        let modify = success ? date(from: info.st_mtimespec) : nil
        let access = success ? date(from: info.st_atimespec) : nil
        let change = success ? date(from: info.st_ctimespec) : nil

        return FileTimes(
            creationTime: birth,
            modificationTime: modify,
            accessTime: access,
            changeTime: change
        )
    }
}
