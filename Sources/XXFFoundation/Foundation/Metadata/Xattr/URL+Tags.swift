//
//  URL+Tags.swift
//  xxf_ios
//  文件tag操作api
//  Created by xxf on 6/12.
//

import Foundation

/**
 名称                                                            类型                                                      可读写                                     层级                                   用途                   推荐操作方式
 tagNamesKey                                              Swift 枚举常量（URLResourceKey）    ✅                                          高层（Foundation）        获取/设置标签    ✅ 推荐,没有颜色索引
 com.apple.metadata:_kMDItemUserTags    xattr key                                                 ✅    底层（文件元数据）     真正存储标签                   🟡 脚本使用       有颜色索引
 kMDItemUserTags                                          Spotlight 查询字段                                ❌ 只读                                 元数据索引（Spotlight）  查询搜索文件    ✅ 查询用
 */
public extension URL {
    /// 官方内置key,不能变
    private static let xattrTagKey = "com.apple.metadata:_kMDItemUserTags"

    /// 获取 Finder 标签（本地化字符串）
    func getFileTags() -> [String] {
        do {
            return try getXattr(key: URL.xattrTagKey)
        } catch {
            return runCatching {
                try (resourceValues(forKeys: [.tagNamesKey]).tagNames) ?? []
            }.getOrElse([])
        }
    }

    /// 设置 Finder 标签（将覆盖原有标签，自动去重）
    func setFileTags(_ tags: [String]) {
        // 显式去重，保持标签顺序（保留第一个出现的顺序）
        var seen = Set<String>()
        let distinctTags = tags.filter { seen.insert($0).inserted }

        do {
            try setXattr(key: URL.xattrTagKey, value: distinctTags)
        } catch {
            runCatching {
                let nsURL = self as NSURL
                try? nsURL.setResourceValue(distinctTags, forKey: .tagNamesKey)
            }.getOrNull()
        }
    }

    /// 增加标签，内部去重（同名标签不会重复添加）
    func addFileTagsOrIgnore(_ tags: [String]) {
        guard !tags.isEmpty else { return }

        let existingTags = getFileTags()
        var seen = Set<String>()
        let combined = (existingTags + tags).filter { seen.insert($0).inserted }

        if combined != existingTags {
            setFileTags(combined)
        }
    }

    /// 删除文件指定 tags（如果存在的话）
    /// - Parameter tags: 要删除的标签（完整匹配）
    func removeFileTags(_ tags: [String]) {
        guard !tags.isEmpty else { return }

        let existingTags = getFileTags()
        let remainingTags = existingTags.filter { !tags.contains($0) }

        if remainingTags != existingTags {
            setFileTags(remainingTags)
        }
    }
}
