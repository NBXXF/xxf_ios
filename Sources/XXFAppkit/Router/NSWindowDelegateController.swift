//
//  NSWindowDelegateController.swift
//  xxf_ios
//   管理NSWindowController
//  Created by xxf on 2025/5/28.
//

import AppKit

open class NSWindowDelegateController: NSWindowController, NSWindowDelegate {
    /// 解决 window 必须强引用的问题
    /// Registry of active window controllers
    static var controllers: [NSWindowDelegateController] = []

    // MARK: - Lifecycle

    /// 代码创建时，init(window:) 会调用这里
    override public init(window: NSWindow?) {
        super.init(window: window)
        commonInit()
    }

    /// nib/storyboard 创建时调用
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    /// nib/storyboard 加载后调用
    override open func windowDidLoad() {
        super.windowDidLoad()
        // nib加载时这里也会调用
        // 再次确保代理和管理（避免遗漏）
        commonInit()
    }

    /// 初始化公共逻辑，设置代理和注册
    private func commonInit() {
        // 设置代理
        window?.delegate = self

        // 保证数组中只有一个自己的引用
        Self.controllers.removeAll { $0 === self }
        Self.controllers.append(self)
    }

    // MARK: - NSWindowDelegate

    /// 窗口关闭时移除自己
    open func windowWillClose(_: Notification) {
        removeFromRegistry()
    }

    // MARK: - Registry Management

    /// 从管理列表中移除自己
    private func removeFromRegistry() {
        Self.controllers.removeAll { $0 === self }
    }

    /// 获取所有活跃的窗口控制器
    public static var allControllers: [NSWindowDelegateController] {
        return controllers
    }
}
