//
//  FileManager+Thread.swift
//  xxf_ios
//  文件操作线程限制
//  Created by xxf on 8/14.
//

import Foundation

public extension FileManager {
    private static let swizzleDefault: Void = {
        let originalSelector = #selector(getter: FileManager.default)
        let swizzledSelector = #selector(FileManager.mainThreadLimt)

        guard
            let originalMethod = class_getClassMethod(FileManager.self, originalSelector),
            let swizzledMethod = class_getClassMethod(FileManager.self, swizzledSelector)
        else { return }

        method_exchangeImplementations(originalMethod, swizzledMethod)
    }()

    @objc class func mainThreadLimt() -> FileManager {
        // 检查线程
        requireChildThread()
        // 调用原始 mainThreadLimt（因为方法已交换，实际上是 original 实现）
        return mainThreadLimt()
    }

    /// 线程检查
    static func enableThreadCheck() {
        if Environment.isDebug {
            _ = swizzleDefault
        }
    }
}
