//
//  NSWindowDelegateController.swift
//  xxf_ios
//   管理NSWindowController
//  Created by xxf on 2025/5/28.
//

import AppKit

open class NSWindowDelegateController: NSWindowController, NSWindowDelegate {
    /// 解决window 必须强引用的问题
    /// Registry of active window controllers
    private static var controllers: [NSWindowDelegateController] = []

    // MARK: - Lifecycle

    /// After window loads, set delegate and register self
    override public func windowDidLoad() {
        super.windowDidLoad()
        window?.delegate = self
        // 先移除再添加，保证数组中只有一个引用
        Self.controllers.removeAll { $0 === self }
        Self.controllers.append(self)
    }

    // MARK: - NSWindowDelegate

    /// Called when the window is about to close
    public func windowWillClose(_: Notification) {
        removeFromRegistry()
    }

    // MARK: - Registry Management

    /// Remove this controller from the static registry
    private func removeFromRegistry() {
        Self.controllers.removeAll { $0 === self }
    }

    /// Accessor for all active controllers
    public static var allControllers: [NSWindowDelegateController] {
        return controllers
    }
}
