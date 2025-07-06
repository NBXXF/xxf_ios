//
//  NSStatusBar+Extension.swift
//  xxf_ios
//  NSStatusBar 系统托盘/状态栏
//  Created by xxf on 5/28.
//
import AppKit
import ObjectiveC.runtime

private nonisolated(unsafe) var associatedStatusItemKey: UInt8 = 0
public extension NSStatusBar {
    /// 单一实例
    var sharedStatusItem: NSStatusItem {
        return getOrCreateStatusItem
    }

    /// 缓存单一实例
    var getOrCreateStatusItem: NSStatusItem {
        if let item = objc_getAssociatedObject(self, &associatedStatusItemKey) as? NSStatusItem {
            return item
        } else {
            let item = statusItem(withLength: NSStatusItem.variableLength)
            objc_setAssociatedObject(self, &associatedStatusItemKey, item, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return item
        }
    }
}
