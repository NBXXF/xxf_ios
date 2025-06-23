//
//  MDItem+Create.swift
//  xxf_ios
//  增加创建拓展
//  Created by xxf on 6/17.
//
import CoreServices
import Foundation

public extension MDItem {
    static func create(fromPath path: String) -> MDItem? {
        return MDItemCreate(kCFAllocatorDefault, path as CFString)
    }

    static func create(fromURL url: URL) -> MDItem? {
        guard let cfURL = url as CFURL? else {
            return nil
        }
        return MDItemCreateWithURL(kCFAllocatorDefault, cfURL)
    }
}
