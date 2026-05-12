//
//  URL+Extension.swift
//  xxf_ios
//
//  Created by xxf on /6/15.
//
import Foundation
import UniformTypeIdentifiers
import XXFSpeed

public extension URL {
    /// 隐藏文件的名字的前缀
    static let hiddenFileNamePrefix = "."

    /// 记录前缀,可能是网络url, 用于排查问题
    private static let _urlPrefix = "url_"
    /// 记录前缀,文件找不到,用于排查问题
    private static let _fileMissingPrefix = "file_missing_"

    /// 空 URL，占位用，显示空白页
    static var emptyURL: URL {
        return URL(string: "about:blank")!
    }

    /// 判断 URL 是否是空白页（about:blank）
    var isEmptyURL: Bool {
        return absoluteString == "about:blank"
    }

    /// 是否为本地地址（loopback domain 或 IPv4 loopback）
    var isLocalhost: Bool {
        guard let host = self.host?.lowercased() else { return false }
        return host == LoopbackAddress.domain || host == LoopbackAddress.ipv4
    }

    /// 根据字符串自动判断并初始化 URL。
    /// 若字符串带 scheme，则作为 URL 解析；
    /// 否则按本地文件路径处理。
    init?(auto string: String) {
        guard let url = string.asURL else { return nil }
        self = url
    }

    #if os(macOS)
        /// 获取主目录所在卷的 st_dev 设备号（仅计算一次）
        private static let homeVolumeDeviceID: Int32 = {
            var statbuf = stat()
            let homePath = FileManager.default.homeDirectoryForCurrentUser.path
            _ = homePath.withCString { lstat($0, &statbuf) }
            return statbuf.st_dev
        }()

        /// 获取主目录所在卷的 UUID（仅计算一次）
        private static let homeVolumeUUID: String? = {
            let homeURL = FileManager.default.homeDirectoryForCurrentUser
            return (try? homeURL.resourceValues(forKeys: [.volumeUUIDStringKey]))?.volumeUUIDString
        }()
    #endif

    /// 返回当前平台下尽可能唯一、稳定的文件 ID，适用于 macOS / iOS。
    ///
    /// 结构类似于：
    /// - macOS: "vol:06A2F1CE-XXXX-XXXX-XXXX-XXXXXXXXXXXX-ino:123456"
    /// - iOS: "dev:16777220-ino:123456"
    ///
    /// - Parameter path: 文件路径
    /// - Returns: 唯一标识符字符串，或path.hash
    private func getFileId() -> String {
        // 只对文件 URL 生效
        guard isFileURL else {
            /// 非文件 URL：直接用完整字符串，避免 path 为空或 schema 冲突
            return "\(Self._urlPrefix)\(absoluteString.toXXH3())"
        }

        var statbuf = stat()
        let ok = withUnsafeFileSystemRepresentation { cPath -> Bool in
            guard let cPath = cPath else { return false }
            return lstat(cPath, &statbuf) == 0
        }

        guard ok else {
            // lstat 失败或路径非法，退化到对路径字符串做哈希
            return "\(Self._fileMissingPrefix)\(absoluteString.toXXH3())"
        }

        let inodeID = "ino:\(statbuf.st_ino)"
        let deviceID = "dev:\(statbuf.st_dev)"
        var volumeID = deviceID

        // macOS 上尝试 volumeUUID（iOS 上这段通常会失败）
        #if os(macOS)
            // 比较 st_dev 是否属于主卷
            if statbuf.st_dev == Self.homeVolumeDeviceID,
               let uuid = Self.homeVolumeUUID
            {
                volumeID = "vol:\(uuid)"
            } else if let values = try? resourceValues(forKeys: [.volumeUUIDStringKey]),
                      let uuid = values.volumeUUIDString
            {
                volumeID = "vol:\(uuid)"
            } else {
                volumeID = deviceID
            }
        #endif
        return String("\(volumeID)-\(inodeID)".toXXH3())
    }

    /// 文件id 字符串类型,场景sql不支持UInt64
    func getFileIdString() -> String {
        return getFileId()
    }

    // 是否是文件夹（仅本地文件 URL）
    func isDirectory() -> Bool {
        requireChildThread()
        guard isFileURL else { return false }
        return path.withCString { cstr in
            var statbuf = stat()
            if lstat(cstr, &statbuf) == 0 {
                return (statbuf.st_mode & S_IFMT) == S_IFDIR
            }
            return false
        }
    }

    /// 是否是符号链接（仅本地文件 URL）
    func isSymbolicLink() -> Bool {
        requireChildThread()
        guard isFileURL else { return false }
        return path.withCString { cstr in
            var statbuf = stat()
            return lstat(cstr, &statbuf) == 0 && (statbuf.st_mode & S_IFMT) == S_IFLNK
        }
    }

    /// 是否是 Finder 替身（Alias 文件）（仅本地文件 URL）
    func isAliasFileOptimized() -> Bool {
        guard isFileURL else { return false }
        // 先用扩展名快速过滤，避免大量调用 resourceValues
        guard pathExtension.lowercased() == "alias" else { return false }
        return (try? resourceValues(forKeys: [.isAliasFileKey]))?.isAliasFile == true
    }

    /// 文件深度
    func calculateFileDepth() -> Int {
        let components = standardizedFileURL.pathComponents
        // 根目录 '/' 的 depth 设为 0，其它路径层数为 components 数减1
        return max(0, components.count - 1)
    }

    /// 是否在同一层级
    func isInSameDirectory(_ url: URL) -> Bool {
        // 获取父目录路径（去掉最后一个路径组件）
        let parent1 = url.deletingLastPathComponent().standardizedFileURL.path
        let parent2 = deletingLastPathComponent().standardizedFileURL.path
        return parent1 == parent2
    }

    /// 父路径
    var parentDirectory: URL {
        return deletingLastPathComponent()
    }

    /// 判断当前路径是否是 `other` 的祖先（父路径或更上层）
    func isAncestor(of other: URL) -> Bool {
        let selfComponents = standardized.pathComponents
        let otherComponents = other.standardized.pathComponents
        return otherComponents.starts(with: selfComponents) && selfComponents.count < otherComponents.count
    }

    /// 判断当前路径是否是 `other` 的直接父路径
    func isDirectParent(of other: URL) -> Bool {
        let selfComponents = standardized.pathComponents
        let otherComponents = other.standardized.pathComponents
        return otherComponents.count == selfComponents.count + 1 && otherComponents.starts(with: selfComponents)
    }

    /// 判断当前路径是否是 `other` 的子路径或子子路径
    func isDescendant(of other: URL) -> Bool {
        return other.isAncestor(of: self)
    }

    /// 判断当前路径是否是 `other` 的直接子路径
    func isDirectChild(of other: URL) -> Bool {
        return other.isDirectParent(of: self)
    }

    /// 获取所有祖先路径
    /// 例如 `/a/b/c` → ["/", "/a", "/a/b"]
    /// 不包含自身 `/a/b/c`
    var ancestorPaths: [String] {
        return ancestorPaths(includeSelf: false)
    }

    /// 返回祖先路径数组，`includeSelf` 控制是否包含当前路径自身
    /// 例如 `/a/b/c` → ["/", "/a", "/a/b"]  或者 ["/", "/a", "/a/b","/a/b/c"]
    func ancestorPaths(includeSelf: Bool) -> [String] {
        let components = standardized.pathComponents
        guard !components.isEmpty else { return [] }

        let count = includeSelf ? components.count : components.count - 1
        guard count > 0 else { return [] }

        return (0 ..< count).map { index in
            NSString.path(withComponents: Array(components.prefix(index + 1)))
        }
    }

    /// 返回一个新的 URL，确保其文件名以 `.` 开头，不行是隐藏文件
    func asHiddenFile() -> URL {
        let name = lastPathComponent
        guard !name.hasPrefix(Self.hiddenFileNamePrefix) else { return self }
        let hiddenName = Self.hiddenFileNamePrefix + name
        return deletingLastPathComponent().appendingPathComponent(hiddenName, isDirectory: false)
    }

    /// 判断当前文件是否是隐藏文件（以 `.` 开头的文件名）
    var isHiddenFile: Bool {
        if lastPathComponent.hasPrefix(Self.hiddenFileNamePrefix) {
            return true
        }

        requireChildThread()

        // 2) 官方 API: isHiddenKey
        if let isHidden = try? resourceValues(forKeys: [.isHiddenKey]).isHidden, isHidden {
            return true
        }

        // 3) 低层检查：UF_HIDDEN
        #if os(macOS)
            if hasUFHiddenFlag {
                return true
            }
        #endif

        return false
    }

    #if os(macOS)
        var hasUFHiddenFlag: Bool {
            let fsrep = (self as NSURL).fileSystemRepresentation
            var sb = stat()
            if lstat(fsrep, &sb) == 0 {
                return (sb.st_flags & UInt32(UF_HIDDEN)) != 0
            }
            return false
        }
    #endif

    /// 类型
    var mimeType: String? {
        if let utType = UTType(filenameExtension: self.pathExtension),
           let mime = utType.preferredMIMEType
        {
            return mime
        }
        return nil
    }

    /// 文件名（包含扩展名）
    var fileName: String {
        let name = lastPathComponent
        return name == System.fileSeparator ? String.empty : name
    }

    /// 文件名（不包含扩展名）
    var fileNameWithoutExtension: String {
        let name = deletingPathExtension().lastPathComponent
        return name == System.fileSeparator ? String.empty : name
    }

    /// 非隐藏文件名（不包含扩展名，且去除开头的点）
    var nonHiddenFileNameWithoutExtension: String {
        let baseName = fileNameWithoutExtension
        guard !baseName.isEmpty else { return baseName }

        // 只去掉开头的单个 `.`
        if baseName.hasPrefix(Self.hiddenFileNamePrefix) && baseName.count > 1 {
            let secondChar = baseName[baseName.index(baseName.startIndex, offsetBy: 1)]
            if secondChar != "." { // 排除 `..` 等系统目录名
                return String(baseName.dropFirst())
            }
        }

        return baseName
    }

    /// 解码后的文件系统路径，可直接用于 SQLite、FileManager、fopen 等系统 API
    /// "/Users/xxf/%E6%96%87%E6%A1%A3/db.sqlite" -> "/Users/xxf/文档/db.sqlite"
    var decodedPath: String {
        if #available(iOS 16, macOS 13, *) {
            return self.path(percentEncoded: false)
        } else {
            return path.removingPercentEncoding ?? path
        }
    }

    /// 获取文件标准路径
    /// - Parameter percentEncoded: 是否进行特殊编码,一般网络请求才需要
    /// - Returns: 路径
    func standardizedFilePath(percentEncoded: Bool = false) -> String {
        if #available(iOS 16, *) {
            return standardizedFileURL.path(percentEncoded: percentEncoded)
        } else {
            // fallback: iOS 16 以下只能使用 path（未编码）
            return standardizedFileURL.path
        }
    }

    enum HierarchyRelation: Equatable {
        case samePath // self == other
        case sameDirectory // parent(self) == parent(other)
        case descendant(levels: Int) // other 在 self 下面，levels = level difference (>0)
        case ancestor(levels: Int) // other 是 self 的祖先，levels > 0 (返回为 ancestor(levels))
        case unrelated
    }

    /// 比较当前 URL 与另一个 URL 的层级关系。
    /// - Parameter resolvingSymlinks: 是否先解析符号链接（默认 false）。
    func hierarchyRelation(to other: URL, resolvingSymlinks: Bool = false) -> HierarchyRelation {
        let aURL = resolvingSymlinks ? resolvingSymlinksInPath().standardizedFileURL
            : standardizedFileURL
        let bURL = resolvingSymlinks ? other.resolvingSymlinksInPath().standardizedFileURL
            : other.standardizedFileURL

        let aPath = aURL.path
        let bPath = bURL.path

        // 1. 完全相同路径
        if aPath == bPath {
            return .samePath
        }

        // 辅助：为路径添加尾部斜杠以避免前缀误判 (/foo 与 /foobar)
        func withTrailingSlash(_ p: String) -> String {
            return p.hasSuffix("/") ? p : p + "/"
        }

        // 2. 同一目录判断（父目录相同）
        let parentA = aURL.deletingLastPathComponent().path
        let parentB = bURL.deletingLastPathComponent().path
        if parentA == parentB {
            return .sameDirectory
        }

        let aTrailing = withTrailingSlash(aPath)
        let bTrailing = withTrailingSlash(bPath)

        // 3. other 在 self 的子路径下
        if bTrailing.hasPrefix(aTrailing) {
            let levelA = aURL.pathComponents.count
            let levelB = bURL.pathComponents.count
            return .descendant(levels: levelB - levelA)
        }

        // 4. other 是 self 的祖先（self 在 other 的子路径下）
        if aTrailing.hasPrefix(bTrailing) {
            let levelA = aURL.pathComponents.count
            let levelB = bURL.pathComponents.count
            return .ancestor(levels: levelA - levelB)
        }

        // 5. 不相关
        return .unrelated
    }
}
