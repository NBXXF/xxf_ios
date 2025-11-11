//
//  NSApplication+StatusBar.swift
//  xxf_ios
//
//  Created by xxf on 7/18.
//

import AppKit

public extension NSApplication {
    /// 单一实例
    var statusItem: NSStatusItem {
        return NSStatusBar.system.sharedStatusItem
    }
}
