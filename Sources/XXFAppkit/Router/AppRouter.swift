//
//  AppRouter.swift
//  xxf_ios
//  路由管理
//  Created by xxf on 2025/5/28.
//
import AppKit

@MainActor
public final class AppRouter {
    public static let shared = AppRouter()
    private init() {} // 防止外部构造
    /// 替换当前主窗口的 contentViewController
    public func presentAsReplaceWindow(for vc: NSViewController) {
        guard let mainWindow = NSApplication.shared.mainWindow ?? NSApplication.shared.windows.first else {
            print("⚠️ 无主窗口，无法展示内容")
            return
        }
        mainWindow.presentAsReplaceWindow(for: vc)
    }

    /// 在当前界面上以模态形式弹出新控制器
    public func presentAsModalWindow(for vc: NSViewController) {
        /// 优先用焦点窗口
        guard let activeWindow = NSApplication.shared.activeWindow else {
            print("⚠️ 无焦点主窗口，无法展示内容")
            return
        }
        activeWindow.presentAsModalWindow(for: vc)
    }

    /// 从窗口底部弹出一个“滑动面板”
    public func presentAsSheetWindow(for vc: NSViewController) {
        /// 优先用焦点窗口
        guard let activeWindow = NSApplication.shared.activeWindow else {
            print("⚠️ 无焦点主窗口，无法展示内容")
            return
        }
        activeWindow.presentAsSheetWindow(for: vc)
    }

    /// 打开一个新的窗口，展示传入的控制器（使用已有 windowController）
    public func presentAsNewWindow(for vc: NSViewController, in windowController: NSWindowDelegateController) {
        NSApplication.shared.presentAsNewWindow(for: vc, in: windowController)
    }
}
