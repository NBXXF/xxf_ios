//
//  FileManager+Fast.swift
//  xxf_ios
//  文件存储位置
//  Created by xxf on 2026/6/2.
//

import Foundation

public extension FileManager {
    /// 更快的判断文件是否存在（基于 stat，性能优于 fileExists(atPath:)）
    /// - Parameter path: 文件路径
    /// - Returns: 文件是否存在
    func fileExistsFast(atPath path: String) -> Bool {
        guard !path.isEmpty else { return false }
        let decodedPath = URL(fileURLWithPath: path).decodedPath
        var info = stat()
        return decodedPath.withCString { stat($0, &info) == 0 }
    }

    /// 是否指向一个已存在的目录（使用 FileManager 的 fileExists）
    /// - Parameter url: 文件 URL
    /// - Returns: 是否为目录
    func isDirectory(at url: URL) -> Bool {
        var isDir: ObjCBool = false
        // 只做 exist + type 检查，不抛异常
        // 这里用 url.path 本身即可，因为 fileExists 是 Foundation 方法，不存在编码问题
        let exists = fileExists(atPath: url.path, isDirectory: &isDir)
        return exists && isDir.boolValue
    }

    /// 基于 stat() 的高性能判断：存在且为目录
    /// - Parameter path: 文件路径
    /// - Returns: 是否为存在的目录
    func isDirectoryFast(atPath path: String) -> Bool {
        guard !path.isEmpty else { return false }
        let decodedPath = URL(fileURLWithPath: path).decodedPath
        var info = stat()
        guard stat(decodedPath, &info) == 0 else {
            return false
        }
        // st_mode 的类型掩码为目录
        return (info.st_mode & S_IFMT) == S_IFDIR
    }

    /// URL 版本的 isDirectoryFast
    /// - Parameter url: 文件路径 URL
    /// - Returns: 是否为目录
    func isDirectoryFast(at url: URL) -> Bool {
        isDirectoryFast(atPath: url.decodedPath)
    }

    struct FileEntry {
        public let path: String
        public let ftsInfo: Int32
    }

    /// 使用 fts 快速递归统计指定路径下的文件数量，可选过滤
    /// - Parameters:
    ///   - path: 文件夹路径
    ///   - filter: 过滤闭包，返回 false 则跳过该文件，默认不过滤
    /// - Returns: 文件数量
    func countFilesFast(atPath path: String, filter: ((FileEntry) -> Bool)? = nil) -> Int {
        guard !path.isEmpty else { return 0 }
        var count = 0

        let decodedPath = URL(fileURLWithPath: path).decodedPath
        decodedPath.withCString { cPath in
            var cPaths: [UnsafeMutablePointer<Int8>?] = [strdup(cPath), nil]
            defer {
                if let ptr = cPaths[0] { free(ptr) }
            }

            guard let fts = fts_open(&cPaths, FTS_PHYSICAL | FTS_NOCHDIR, nil) else {
                print("Error: Failed to open path \(decodedPath)")
                return
            }
            defer { fts_close(fts) }

            while let entry = fts_read(fts) {
                let ftsInfo = Int32(entry.pointee.fts_info)
                let filePath = String(cString: entry.pointee.fts_accpath)

                let fileEntry = FileEntry(path: filePath, ftsInfo: ftsInfo)

                if let filter = filter, !filter(fileEntry) {
                    continue
                }

                switch ftsInfo {
                    case FTS_F:
                        count += 1
                    case FTS_DNR, FTS_ERR:
                        if entry.pointee.fts_errno != 0 {
                            let errorStr = String(cString: strerror(entry.pointee.fts_errno))
                            print("Warning: Failed to read directory: \(errorStr)")
                        }
                    default:
                        break
                }
            }
        }

        return count
    }

    /// 使用 fts 快速递归统计指定路径下的文件数量和文件大小总和，可选过滤
    /// - Parameters:
    ///   - path: 文件夹路径
    ///   - filter: 过滤闭包，返回 false 则跳过该文件，默认不过滤
    /// - Returns: (文件数量, 文件大小总和)
    func countFilesAndSizesFast(atPath path: String, filter: ((FileEntry) -> Bool)? = nil) -> (count: Int, totalSize: UInt64) {
        guard !path.isEmpty else { return (0, 0) }
        var count = 0
        var totalSize: UInt64 = 0

        let decodedPath = URL(fileURLWithPath: path).decodedPath
        decodedPath.withCString { cPath in
            var cPaths: [UnsafeMutablePointer<Int8>?] = [strdup(cPath), nil]
            defer {
                if let ptr = cPaths[0] { free(ptr) }
            }

            guard let fts = fts_open(&cPaths, FTS_PHYSICAL | FTS_NOCHDIR, nil) else {
                print("Error: Failed to open path \(decodedPath)")
                return
            }
            defer { fts_close(fts) }

            while let entry = fts_read(fts) {
                let ftsInfo = Int32(entry.pointee.fts_info)
                let filePath = String(cString: entry.pointee.fts_accpath)

                let fileEntry = FileEntry(path: filePath, ftsInfo: ftsInfo)

                if let filter = filter, !filter(fileEntry) {
                    continue
                }

                switch ftsInfo {
                    case FTS_F:
                        count += 1
                        var statbuf = stat()
                        if stat(entry.pointee.fts_accpath, &statbuf) == 0 {
                            totalSize += UInt64(statbuf.st_size)
                        }
                    case FTS_DNR, FTS_ERR:
                        if entry.pointee.fts_errno != 0 {
                            let errorStr = String(cString: strerror(entry.pointee.fts_errno))
                            print("Warning: Failed to read directory: \(errorStr)")
                        }
                    default:
                        break
                }
            }
        }

        return (count, totalSize)
    }

    /// 极致性能 FTS 遍历器，模仿 FileManager.enumerator 风格，按每个文件回调 block
    /// - Parameters:
    ///   - path: 根目录路径
    ///   - visit: 每个子路径都会调用。返回 `true` 继续，返回 `false` 可提前终止。
    func enumeratorFast(
        atPath path: String,
        visit: (_ filePath: String) -> Bool = { _ in true }
    ) {
        let decodedPath = URL(fileURLWithPath: path).decodedPath
        guard decodedPath.hasPrefix("/") else { return }

        guard let cRootPath = strdup(decodedPath) else {
            return
        }
        defer { free(cRootPath) }

        var paths = [UnsafeMutablePointer<Int8>?](repeating: nil, count: 2)
        paths[0] = cRootPath
        paths[1] = nil

        guard let tree = fts_open(&paths, FTS_NOCHDIR | FTS_PHYSICAL, nil) else {
            return
        }
        defer { fts_close(tree) }

        while let node = fts_read(tree) {
            guard let cPath = node.pointee.fts_path else { continue }

            // 跳过根目录本身（与 FileManager.enumerator 一致）
            if node.pointee.fts_level == 0 { continue }

            switch node.pointee.fts_info {
                // 1. 处理目录（FTS_D）：Bundle 只可能是目录，需判断并决定是否跳过内部
                case UInt16(FTS_D):
                    let filePath = String(cString: cPath)
                    // 仅对目录判断是否为 Bundle（符合 Bundle 本质）
                    if isBundleFile(atPath: filePath) {
                        // 若是 Bundle，跳过内部内容（避免遍历 .app/.framework 内部的 Contents 等子目录）
                        fts_set(tree, node, FTS_SKIP)
                    }
                    // 执行目录的访问逻辑
                    let shouldContinue = visit(filePath)
                    if !shouldContinue {
                        return
                    }

                // 2. 处理普通文件（FTS_F）：不可能是 Bundle，无需判断，直接处理
                case UInt16(FTS_F):
                    let filePath = String(cString: cPath)
                    // 冗余优化：普通文件不是 Bundle，直接跳过 isBundleFile 判断
                    let shouldContinue = visit(filePath)
                    if !shouldContinue {
                        return
                    }

                // 3. 其他类型（如符号链接 FTS_L、已遍历目录 FTS_DP 等）：跳过
                default:
                    continue
            }
        }
    }

    /// 极致性能 FTS 遍历器，模仿 FileManager.enumerator 风格，按每个文件回调 block
    /// - Parameters:
    ///   - path: 根目录路径
    ///   - visit: 每个子路径都会调用。返回 `true` 继续，返回 `false` 可提前终止。
    /// - Returns: (文件路径集合)
    func enumeratorFastPaths(atPath path: String, visit: (_ filePath: String) -> Bool = { _ in true }) -> [String] {
        var result = [String]()
        // 提前分配容量，减少扩容开销，建议默认使用 2_000，需要更高性能时再根据实际目录结构优化。
        result.reserveCapacity(2000)
        enumeratorFast(atPath: path) { filePath in
            if visit(filePath) {
                result.append(filePath)
                return true
            }
            return false
        }
        return result
    }

    /// 快速获取文件大小
    /// - Parameter path: 文件路径
    /// - Parameter recursive: 是否深度递归,默认true
    @available(macOS 10.8, *)
    func fileSizeFast(atPath path: String, recursive: Bool = true) -> UInt64 {
        if recursive {
            return countFilesAndSizesFast(atPath: path).totalSize
        } else {
            // 用url 来读取,效率较高,但是低于stat,stat实现较多代码,
            // stat > resourceValues> attributesOfItem(atPath: path)[.size]
            let url = URL(fileURLWithPath: path)
            guard let fileSize = try? url.resourceValues(forKeys: [.fileSizeKey]).fileSize else {
                return 0
            }
            return UInt64(fileSize >= 0 ? fileSize : 0)
        }
    }
}
