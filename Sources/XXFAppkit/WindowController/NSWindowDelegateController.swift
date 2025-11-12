//
//  NSWindowDelegateController.swift
//  xxf_ios
//   管理NSWindowController
//  Created by xxf on 5/28.
//

import AppKit

open class NSWindowDelegateController: NSWindowController, NSWindowDelegate {
    /// 解决 window 必须强引用的问题
    /// Registry of active window controllers
    static var controllers: [NSWindowDelegateController] = []

    // MARK: - Lifecycle

    /// 代码创建时，init(window:) 会调用这里
    public override init(window: NSWindow?) {
        super.init(window: window ?? Self.createDefaultWindow())
        commonInit()
    }

    /// 默认的创建窗口,子类可以复写
    /// - Returns: 窗口
    open class func createDefaultWindow() -> NSWindow {
        let screenFrame = NSScreen.main?.visibleFrame ?? NSRect(x: 0, y: 0, width: 800, height: 600)

        // 使用屏幕的 60% 宽高
        let width = screenFrame.width * 0.6
        let height = screenFrame.height * 0.6

        // 计算居中位置
        let originX = screenFrame.origin.x + (screenFrame.width - width) / 2
        let originY = screenFrame.origin.y + (screenFrame.height - height) / 2

        let window = XXFWindow(
            contentRect: NSRect(x: originX, y: originY, width: width, height: height),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered,
            defer: false
        )
        window.locationCenterUsingVisibleFrame()
        return window
    }

    /// nib/storyboard 创建时调用
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    /// nib/storyboard 加载后调用
    open override func windowDidLoad() {
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

    // MARK: - Registry Management

    /// 从管理列表中移除自己
    private func removeFromRegistry() {
        Self.controllers.removeAll { $0 === self }
    }

    /// 获取所有活跃的窗口控制器
    public static var allControllers: [NSWindowDelegateController] {
        return controllers
    }

    /// 窗口即将关闭
    open func windowWillClose(_: Notification) {
        removeFromRegistry()
    }

    /// 窗口成为 key window（接收键盘输入）, 在普通应用中，main window 通常也是 key window，但如果你有弹窗、HUD、面板窗口，它们成为 key window，但不是 main window。
    open func windowDidBecomeKey(_: Notification) {}

    /// 窗口失去 key window 状态
    open func windowDidResignKey(_: Notification) {}

    /// 窗口成为主窗口（应用主交互窗口）
    open func windowDidBecomeMain(_: Notification) {
        NSApplication.shared.mainMenu = window?.mainMenu
//        NSApplication.shared.statusItem.menu = window?.statusMenu
    }

    /// 窗口失去主窗口状态
    open func windowDidResignMain(_: Notification) {}

    /// 窗口显示内容更新（用于刷新 UI）
    open func windowDidUpdate(_: Notification) {}

    /// 窗口状态将改变（最小化、最大化、全屏等）
    open func windowWillMiniaturize(_: Notification) {}

    /// 窗口已经最小化
    open func windowDidMiniaturize(_: Notification) {}

    /// 窗口已取消最小化
    open func windowDidDeminiaturize(_: Notification) {}

    /// 窗口是否应该关闭（return false 可阻止关闭）
    open func windowShouldClose(_: NSWindow) -> Bool {
        return true
    }

    /// 窗口是否可以变成 key window（默认 true）
    open func windowShouldBecomeKey(_: NSWindow) -> Bool {
        return true
    }

    /// 窗口是否可以变成 main window（默认 true）
    open func windowShouldBecomeMain(_: NSWindow) -> Bool {
        return true
    }

    /// 窗口大小改变前调用（返回新窗口尺寸）
    open func windowWillResize(_: NSWindow, to frameSize: NSSize) -> NSSize {
        return frameSize
    }

    /// 窗口移动时调用
    open func windowDidMove(_: Notification) {}

    /// 窗口大小改变后调用
    open func windowDidResize(_: Notification) {}

    /// 窗口开始 live resize（用户正在拖动）
    open func windowWillStartLiveResize(_: Notification) {}

    /// 窗口结束 live resize
    open func windowDidEndLiveResize(_: Notification) {}

    /// 窗口是否支持全屏（默认 true）
    open func window(_: NSWindow, willUseFullScreenPresentationOptions proposedOptions: NSApplication.PresentationOptions) -> NSApplication.PresentationOptions {
        return proposedOptions
    }

    /// 窗口进入全屏前
    open func windowWillEnterFullScreen(_: Notification) {}

    /// 窗口已进入全屏
    open func windowDidEnterFullScreen(_: Notification) {}

    /// 窗口即将退出全屏
    open func windowWillExitFullScreen(_: Notification) {}

    /// 窗口已退出全屏
    open func windowDidExitFullScreen(_: Notification) {}

    /// 窗口支持的最小尺寸（可选）
    open func windowWillUseStandardFrame(_: NSWindow, defaultFrame newFrame: NSRect) -> NSRect {
        return newFrame
    }

    /// 支持 tabbed 窗口切换（macOS 10.12+）
    open func window(_: NSWindow, shouldDragDocumentWith _: NSEvent, from _: NSPoint, with _: NSPasteboard) -> Bool {
        return true
    }
}
