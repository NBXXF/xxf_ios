//
//  WindowScopable.swift
//  xxf_ios
//  限定作用域为 window,常用于mac事件通信（rxbus）
//  Created by xxf on 7/29.
//

import AppKit
import Foundation

/// 表示事件与某个 window 相关（可选绑定）
public protocol WindowScopable {
    /// 为空就不跟窗口绑定
    var windowIdentifier: String? { get }
}

@MainActor
public extension WindowScopable {
    /// 转为 NSUserInterfaceItemIdentifier，方便与 AppKit 交互，nil 表示无绑定
    var windowInterfaceItemIdentifier: NSUserInterfaceItemIdentifier? {
        guard let windowIdentifier else { return nil }
        return NSUserInterfaceItemIdentifier(windowIdentifier)
    }

    /// 判断是否绑定到指定的 window 标识符
    func belongs(to interfaceItemIdentifier: NSUserInterfaceItemIdentifier?) -> Bool {
        return windowInterfaceItemIdentifier == interfaceItemIdentifier
    }

    /// 判断是否绑定到指定的 NSWindow，需要主线程调用
    @MainActor
    func belongs(to window: NSWindow?) -> Bool {
        return windowInterfaceItemIdentifier == window?.identifier
    }
}
