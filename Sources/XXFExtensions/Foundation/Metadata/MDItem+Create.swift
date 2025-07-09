//
//  MDItem+Create.swift
//  xxf_ios
//  增加创建拓展
// MDItemCreate 容易闪退
//  Created by xxf on 6/17.
//
import CoreServices
import Foundation

public extension MDItem {
    static func create(fromPath path: String) -> MDItem? {
        guard !path.isEmpty else {
            return nil
        }
        guard FileManager.default.fileExistsFast(atPath: path) else {
            return nil
        }
        return MDItemCreate(kCFAllocatorDefault, path as CFString)
    }

    static func create(fromURL url: URL) -> MDItem? {
        let path = url.path
        guard !path.isEmpty else {
            return nil
        }
        guard FileManager.default.fileExistsFast(atPath: path) else {
            return nil
        }
        guard let cfURL = url as CFURL? else {
            return nil
        }
        return MDItemCreateWithURL(kCFAllocatorDefault, cfURL)
    }
}
