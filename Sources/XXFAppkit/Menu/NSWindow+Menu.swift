//
//  NSWindow+Menu.swift
//  xxf_ios
//  NSApplication.shared.mainMenu ,NSStatusBar.system.statusItem 等都是应用全局的,现在设计一套跟window相关的主菜单和托盘菜单
//  避免业务去管理复杂的不同窗口有不同菜单
//  处理的最佳时机便是 windowDidBecomeMain （在普通应用中，main window 通常也是 key window，但如果你有弹窗、HUD、面板窗口，它们成为 key window，但不是 main window。）
//  默认在NSWindowDelegateController中进行智能切换了
//  Created by xxf on 7/18.
//
import AppKit
import Foundation
import ObjectiveC.runtime

private nonisolated(unsafe) var keyMainMenu = 1
private nonisolated(unsafe) var keyStatusMenu = 2
public extension NSWindow {
    /// 主菜单（左上角）
    var mainMenu: NSMenu {
        get {
            if let menu = objc_getAssociatedObject(self, &keyMainMenu) as? NSMenu {
                return menu
            } else {
                let created = NSMenu()
                objc_setAssociatedObject(self, &keyMainMenu, created, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return created
            }
        }
        set {
            objc_setAssociatedObject(self, &keyMainMenu, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 刷新对应的window
            if self == NSApplication.shared.mainWindow {
                NSApplication.shared.mainMenu = newValue
                newValue.update()
            }
        }
    }

    /// 状态栏托盘菜单（右上角）
    var statusMenu: NSMenu {
        get {
            if let menu = objc_getAssociatedObject(self, &keyStatusMenu) as? NSMenu {
                return menu
            } else {
                let created = NSMenu()
                objc_setAssociatedObject(self, &keyStatusMenu, created, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return created
            }
        }
        set {
            objc_setAssociatedObject(self, &keyStatusMenu, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            /// 刷新对应的window
            /// 去掉设置，否则tray无法监听左右键
//            if self == NSApplication.shared.mainWindow {
//                NSApplication.shared.statusItem.menu = newValue
//                newValue.update()
//            }
        }
    }
}
