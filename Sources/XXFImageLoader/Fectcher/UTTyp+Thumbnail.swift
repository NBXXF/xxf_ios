//
//  UTTyp+Thumbnail.swift
//  xxf_ios
//
//  Created by xxf on 9/14.
//

import UniformTypeIdentifiers

extension UTType {
    /// 是否是图片类型
    var isImageUTType: Bool {
        return conforms(to: .image)
    }

    /// 是否是视频类型
    var isVideoUTType: Bool {
        // 1. 系统视频类型
        if conforms(to: .video) { return true }

        // 2. 常见视频扩展名
        let videoExtensions = ["mp4", "mov", "m4v", "avi", "mkv", "flv", "wmv", "webm"]
        if let ext = preferredFilenameExtension?.lowercased(), videoExtensions.contains(ext) {
            return true
        }

        // 3. 可选：根据 MIME / 自定义 UTType 再兜底
        return false
    }
}

// MARK: - 辅助方法

private extension UTType {
    /// 根据 identifier 数组返回已注册的 UTType 数组
    static func types(from identifiers: [String]) -> [UTType] {
        identifiers.compactMap { UTType($0) }
    }

    /// 判断当前 UTType 是否在数组中
    func contained(in types: [UTType]) -> Bool {
        types.contains(where: { self.conforms(to: $0) })
    }
}
