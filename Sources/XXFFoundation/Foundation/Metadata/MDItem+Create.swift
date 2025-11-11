//
//  MDItem+Create.swift
//  xxf_ios
//  增加创建拓展
// MDItemCreate 容易闪退
//  Created by xxf on 6/17.
//
#if os(macOS)
import CoreServices
import Foundation

public extension MDItem {
    static func create(fromPath path: String) -> MDItem? {
        guard !path.isEmpty else {
            return nil
        }
        // 不需要检查文件,提高速度
//        guard FileManager.default.fileExistsFast(atPath: path) else {
//            return nil
//        }
        return MDItemCreate(kCFAllocatorDefault, path as CFString)
    }

    static func create(fromURL url: URL) -> MDItem? {
        // 不需要检查文件,提高速度
//        guard FileManager.default.fileExistsFast(atPath: path) else {
//            return nil
//        }
        guard let cfURL = url as CFURL? else {
            return nil
        }
        return MDItemCreateWithURL(kCFAllocatorDefault, cfURL)
    }
}
#endif
