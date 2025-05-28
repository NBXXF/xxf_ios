//
//  NSApplication+Window.swift
//  xxf_ios
//  窗口管理
//  Created by xxf on 2025/5/28.
//

import AppKit

public extension NSApplication {
    /// 获取当前优先展示窗口（优先 keyWindow，其次 mainWindow，再次 first）
    var activeWindow: NSWindow? {
        return NSApp.keyWindow ?? NSApp.mainWindow ?? NSApp.windows.first
    }

    /// 获取当前最活跃的窗口的 contentViewController（优先 keyWindow，其次 mainWindow，其次其他窗口）
    var topWindowController: NSWindowController? {
        return keyWindow?.windowController
            ?? mainWindow?.windowController
            ?? windows.first(where: { $0.isVisible })?.windowController
    }

    /// 获取当前最活跃的窗口的 contentViewController（优先 keyWindow，其次 mainWindow，其次其他窗口）
    var topContentViewController: NSViewController? {
        return keyWindow?.contentViewController
            ?? mainWindow?.contentViewController
            ?? windows.first(where: { $0.isVisible })?.contentViewController
    }

    /// 弹出一个新的window
    func presentAsNewWindow(for vc: NSViewController, in windowController: NSWindowController) {
        windowController.contentViewController = vc
        windowController.showWindow(nil)

        /**
         windowController.window?.makeKeyAndOrderFront(nil) 的作用是：=
         makeKey：让这个窗口成为“关键窗口”（key window），即接收键盘事件和焦点的主窗口。
         orderFront：把窗口放到所有其它窗口的前面（显示出来，不被其他窗口遮挡）。
         简单来说，这句代码是“让该窗口弹出来并获得焦点”，用户可以直接操作这个窗口
         */
        windowController.window?.makeKeyAndOrderFront(nil)
        /// 确保应用激活到前台
        activate(ignoringOtherApps: true)
    }

    /// 弹出一个新的window
    func presentAsNewWindow(for vc: NSViewController, at window: NSWindow) {
        let windowController = NSWindowController(window: window)
        windowController.contentViewController = vc
        windowController.showWindow(nil)
        windowController.window?.makeKeyAndOrderFront(nil)
        /// 确保应用激活到前台
        activate(ignoringOtherApps: true)
    }

    /// 关闭应用 (进程完全消失)
    func closeApp() {
        NSApp.terminate(nil)
    }

    /**
     当关闭最后一个窗口时，是否退出 App？
     macOS 默认是 不退出，保持 App 存活。你可以通过实现 NSApplicationDelegate 的这个方法改变行为：
     func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
         return true // 返回true时，关闭最后一个窗口App也退出
     }
     */
    /// 关闭当前窗口
    func closeActiveWindow() {
        activeWindow?.close()
    }

    /// 关闭所有窗口,但应用还活着,但还要applicationShouldTerminateAfterLastWindowClosed 为false
    func closeAllWindows() {
        for window in windows {
            window.close()
        }
    }

    /// 获取所有窗口
    /// 其他参考 mainWindow, keyWindow
    @available(*, deprecated, message: "replace field windows")
    func getAllWindows() -> [NSWindow] {
        return windows
    }
}
