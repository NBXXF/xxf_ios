//
//  NSMenuItem+Extension.swift
//  xxf_ios
//  让isEnabled 自动发生效,以及增加自定义回调式的点击事件
//  Created by xxf on 7/18.
//
import AppKit

/// 解决onclick 写成拓展挂载在关联对象上无法copy的问题,用继承类来实现
open class NSClickableMenuItem: NSMenuItem, NSMenuItemValidation {
    public enum Requirement {
        case none
        case requiresMainWindow
        case requiresKeyWindow
    }

    open var onClick: ((NSMenuItem) -> Void)?

    override public init(title string: String, action selector: Selector?, keyEquivalent charCode: String) {
        super.init(title: string, action: selector, keyEquivalent: charCode)
        commonInit()
    }

    public required init(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        target = self
        action = #selector(_menuCallbackAction(_:))
    }

    @objc private func _menuCallbackAction(_ sender: NSMenuItem) {
        onClick?(sender)
    }

    // 重写copy，保证复制时onClick被复制
    override open func copy(with zone: NSZone? = nil) -> Any {
        let copyItem = super.copy(with: zone) as! NSClickableMenuItem
        copyItem.commonInit() // 关键补充：重新设置 target 和 action
        copyItem.onClick = onClick
        if let submenu = submenu {
            copyItem.submenu = copyMenu(submenu)
        }
        return copyItem
    }

    private func copyMenu(_ menu: NSMenu) -> NSMenu {
        let newMenu = NSMenu(title: menu.title)
        for item in menu.items {
            let copiedItem: NSMenuItem
            if let callbackItem = item as? NSClickableMenuItem {
                let copy = callbackItem.copy()
                copiedItem = copy as? NSClickableMenuItem ?? copy as! NSMenuItem
            } else {
                copiedItem = item.copy() as! NSMenuItem
            }

            if let submenu = item.submenu {
                copiedItem.submenu = copyMenu(submenu)
            }

            newMenu.addItem(copiedItem)
        }
        return newMenu
    }

    public func validateMenuItem(_: NSMenuItem) -> Bool {
        return isEnabled
    }
}
