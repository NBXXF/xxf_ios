//
//  FileManager+Bundle.swift
//  xxf_ios
//  检查是不是bundle文件
//  Created by xxf on 9/28.
//

import CoreServices
import Foundation
import UniformTypeIdentifiers

public extension FileManager {
    static let allBundleExtensions: Set<String> = [
        // 应用程序类（补充）
        "app", "prefpane", "saver", "qlgenerator", "service",
        "application", // 部分跨平台应用使用的扩展名
        "agent", // 后台代理程序包
        "daemon", // 系统守护进程包
        "tool", // 工具类程序包

        // 框架与代码类（补充）
        "framework", "bundle", "plugin", "kext", "xpc", "dylib", "mdimporter",
        "frameworkd", // 动态框架包
        "pluginkit", // PlugInKit 插件包
        "addon", // 扩展组件包
        "extension", // 系统扩展包（如 Safari 扩展）
        "sysextension", // 系统级扩展（macOS 10.15+）
        "bundleproxy", //  bundle 代理包

        // 资源与文档类（补充）
        "rtfd", "docset", "iconset", "xcassets", "graphics", "storyboardc", "xib",
        "assetcatalog", // 资产目录包
        "imagebundle", // 图像资源包
        "soundset", // 音效集合包
        "textbundle", // 文本资源包（带附件）
        "fontbundle", // 字体包
        "tiffbundle", // TIFF 图像包
        "preset", // 预设配置包
        "template", // 模板包
        "library", // 资源库包
        "cannedsearch", // 预置搜索包

        // 开发工具类（新增）
        "xctest", // Xcode 测试包
        "playground", // Swift Playground 包
        "playgroundbook", // 交互式教程包
        "xcworkspace", // Xcode 工作区包
        "xcodeproj", // Xcode 项目包
        "xcscheme", // Xcode 方案配置包
        "xcconfig", // 配置集合包（部分场景）

        // 系统服务类（补充）
        "filter", "component", "driver", "device", "packet", "theme", "style", "fontcollection",
        "printplugin", // 打印插件包
        "scanner", // 扫描仪配置包
        "camera", // 相机配置包
        "networkextension", // 网络扩展包
        "vpnplugin", // VPN 插件包
        "locationplugin", // 位置服务插件包
        "shareextension", // 分享扩展包
        "intentservice", // 意图服务包

        // 媒体与创意类（新增）
        "audiounit", // 音频单元插件包
        "vst", // VST 音频插件包
        "vst3", // VST3 音频插件包
        "auv3", // 音频单元扩展包
        "effect", // 效果器插件包
        "filtergraph", // 滤镜图形配置包
        "motion", // 动态效果包
        "compressor", // 压缩配置包

        // 其他特殊类型（新增）
        "diskimage", // 磁盘镜像包（部分类型）
        "archivebundle", // 归档包
        "backupbundle", // 备份包
        "cachebundle", // 缓存包
        "settingbundle", // 设置面板包
        "helpbook", // 帮助文档包
        "book", // 电子书包（特定格式）
        "mapset", // 地图数据集包
        "language", // 语言包
        "localization", // 本地化资源包
        "translation", // 翻译资源包
    ]

    /// 核心Bundle基础类型的UTI字符串（用于类型匹配，兼容各版本系统）
    private static let baseBundleUTIs: [String] = [
        "com.apple.disk-image", // 新增：.dmg 对应的 UTType
        "com.apple.bundle", // .bundle
        "com.apple.application", // .application
        "com.apple.framework", // .framework
        "com.apple.plugin", // .plugin
        "com.apple.dylib", // 动态库 (.dylib)
        "com.apple.xcode.project", // Xcode项目 (.xcodeproj)
        "com.apple.xcode.workspace", // Xcode工作区 (.xcworkspace)
        "com.apple.audiounit", // 音频单元
        "com.apple.system-extension", // 系统扩展
    ]

    /// 预缓存UTI到UTType的映射（提高性能并处理空值）
    private static let cachedUTTypes: [UTType] = baseBundleUTIs.compactMap { uti in
        UTType(uti)
    }

    func isBundleFile(atPath path: String) -> Bool {
        return isBundleFile(for: URL(filePath: path))
    }

    /// 检查URL是否指向Bundle类型文件
    /// - Parameter url: 要检查的文件URL
    /// - Returns: 是否为Bundle类型
    func isBundleFile(for url: URL) -> Bool {
        return runCatching {
            // 1. 快速检查扩展名是否在目标集合中（区分大小写处理）
            let fileExtension = url.pathExtension.lowercased()
            guard Self.allBundleExtensions.contains(fileExtension) else {
                return false
            }

            // 2. 通过扩展名创建UTType进行类型验证
            guard let fileType = UTType(filenameExtension: fileExtension) else {
                // 处理系统未识别的扩展名
                return handleUnrecognizedExtension(fileExtension)
            }

            // 3. 检查是否符合任何基础Bundle类型（使用预缓存的非空UTType）
            return Self.cachedUTTypes.contains { baseType in
                fileType.conforms(to: baseType)
            }
        }.getOrElse(false)
    }

    /// 处理系统未识别的扩展名
    /// - Parameter extension: 未识别的扩展名
    /// - Returns: 是否判定为Bundle类型
    private func handleUnrecognizedExtension(_ extension: String) -> Bool {
        // 对于系统无法识别的自定义扩展名，根据命名规则进行判断
        return `extension`.hasSuffix("bundle") ||
            `extension`.hasSuffix("plugin") ||
            `extension`.hasSuffix("extension") ||
            `extension`.hasSuffix("kext") ||
            `extension`.hasSuffix("framework")
    }
}
