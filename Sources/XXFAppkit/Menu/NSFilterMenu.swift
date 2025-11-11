//
//  NSFilterMenu.swift
//  xxf_ios
//  支持屏蔽的menu（有时候系统会莫名其妙自动加一些）
//  Created by xxf on 2025/7/29.
//
import AppKit

open class NSFilterMenu: NSMenu {
    private let filter: ((NSMenuItem) -> Bool)?

    public init(title: String = "", filter: ((NSMenuItem) -> Bool)? = nil) {
        self.filter = filter
        super.init(title: title)
    }

    public required init(coder: NSCoder) {
        filter = nil
        super.init(coder: coder)
    }

    private func shouldAddItem(_ item: NSMenuItem) -> Bool {
        // 如果有过滤规则就用，没有就不过滤
        return filter?(item) ?? true
    }

    override open func insertItem(_ newItem: NSMenuItem, at index: Int) {
        if shouldAddItem(newItem) {
            super.insertItem(newItem, at: index)
        }
    }

    override open func addItem(_ newItem: NSMenuItem) {
        if shouldAddItem(newItem) {
            super.addItem(newItem)
        }
    }

    override open func insertItem(withTitle title: String, action selector: Selector?, keyEquivalent key: String, at index: Int) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
        if shouldAddItem(item) {
            super.insertItem(item, at: index)
        }
        return item
    }

    override open func addItem(withTitle title: String, action selector: Selector?, keyEquivalent key: String) -> NSMenuItem {
        let item = NSMenuItem(title: title, action: selector, keyEquivalent: key)
        if shouldAddItem(item) {
            super.addItem(item)
        }
        return item
    }
}
