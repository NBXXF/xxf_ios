//
//  NSMenu+Extension.swift
//  xxf_ios
//  菜单相关api
//  Created by xxf on 7/18.
//
import AppKit

public extension NSMenu {
    /// 取代系统自带的menu.item(withTitle title: String) 不能深度查询
    /// - Parameters:
    ///   - title: 标题
    ///   - deep: 是否深度递归
    /// - Returns: menu菜单项
    func findMenuItem(withTitle title: String, deep: Bool = true) -> NSMenuItem? {
        for item in items {
            if item.title == title {
                return item
            }
            if deep, let submenu = item.submenu,
               let found = submenu.findMenuItem(withTitle: title, deep: true)
            {
                return found
            }
        }
        return nil
    }

    /// 取代系统自带的menu.item(withTag tag: Int) 不能深度查询
    /// - Parameters:
    ///   - tag:     标签
    ///   - deep: 是否深度递归
    /// - Returns: menu菜单项
    func findMenuItem(withTag tag: Int, deep: Bool = true) -> NSMenuItem? {
        for item in items {
            if item.tag == tag {
                return item
            }
            if deep, let submenu = item.submenu,
               let found = submenu.findMenuItem(withTag: tag, deep: true)
            {
                return found
            }
        }
        return nil
    }

    /// 取代系统自带的menu.item(withTag tag: Int) 不能深度查询
    /// - Parameters:
    ///   - menu:     菜单枚举
    ///   - deep: 是否深度递归
    /// - Returns: menu菜单项
    func findMenuItem(_ menu: any MenuRepresentable, deep: Bool = true) -> NSMenuItem? {
        return findMenuItem(withTag: menu.rawValue, deep: deep)
    }

    /// 添加子菜单
    /// - Parameters:
    ///   - title: 菜单标题
    ///   - tag: 唯一标识,便于查找, 菜单名字可能重复,这里改成必须传递,比较好的习惯
    ///   - keyEquivalentModifierMask: 修饰键
    ///   - keyEquivalent: 快捷键
    ///   - enabled: 是否可用
    ///   - onClick: 点击事件
    /// - Returns: 菜单项
    @discardableResult
    func addItem(
        withTitle title: String,
        tag: Int,
        keyEquivalentModifierMask: NSEvent.ModifierFlags = [],
        keyEquivalent: String = "",
        enabled: Bool = true,
        onClick: @escaping (NSMenuItem) -> Void
    ) -> NSClickableMenuItem {
        let item = NSClickableMenuItem(title: title, action: nil, keyEquivalent: keyEquivalent)
        item.tag = tag
        item.keyEquivalentModifierMask = keyEquivalentModifierMask
        item.isEnabled = enabled
        item.onClick = onClick
        addItem(item)
        return item
    }

    /// 添加子菜单
    /// - Parameters:
    ///   - menu: 菜单
    ///   - enabled: 是否可用
    ///   - onClick: 点击事件
    /// - Returns: 菜单项
    @discardableResult
    func addItem(
        _ menu: any MenuRepresentable,
        enabled: Bool = true,
        onClick: @escaping (NSMenuItem) -> Void
    ) -> NSClickableMenuItem {
        let item = NSClickableMenuItem(title: menu.title, action: nil, keyEquivalent: menu.keyEquivalent)
        item.tag = menu.rawValue
        item.keyEquivalentModifierMask = menu.keyEquivalentModifierMask
        item.isEnabled = enabled
        item.onClick = onClick
        addItem(item)
        return item
    }

    /// 添加子菜单
    /// - Parameters:
    ///   - menu: 菜单
    ///   - enabled: 是否可用
    ///   - onClick: 点击事件
    /// - Returns: 菜单项
    @discardableResult
    func addItem(
        _ menu: any MenuRepresentable,
        enabled: Bool = true
    ) -> NSClickableMenuItem {
        let item = NSClickableMenuItem(title: menu.title, action: nil, keyEquivalent: menu.keyEquivalent)
        item.tag = menu.rawValue
        item.keyEquivalentModifierMask = menu.keyEquivalentModifierMask
        item.isEnabled = enabled
        addItem(item)
        return item
    }

    /// 批量添加菜单项目
    /// - Parameter newItems: 新菜单项
    func addItems(_ newItems: [NSMenuItem]) {
        for item in newItems {
            addItem(item)
        }
    }

    /// 重置整个菜单项
    /// - Parameter newItems: 新菜单项
    func resetItems(_ newItems: [NSMenuItem]) {
        removeAllItems()
        addItems(newItems)
    }

    /// 移除指定菜单项
    /// - Parameter condition: 是否应该移除
    func removeItems(where condition: (NSMenuItem) -> Bool) {
        for item in items.reversed() {
            if condition(item) {
                removeItem(item)
            }
        }
    }
}
