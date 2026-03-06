//
//  NSMenu+Snapshot.swift
//  xxf_ios
//
//  Created by xxf on 2026/10/15.
//

import AppKit
import XXFFoundation

public extension NSMenuItem {
    private static let keySnapshotEnableValue = "snapshotEnableValue"
    internal var snapshotEnableValue: Bool? {
        get { getAssociatedObject(Self.keySnapshotEnableValue) }
        set { setAssociatedObject(newValue, forKey: Self.keySnapshotEnableValue) }
    }

    /// 递归遍历自身及所有子菜单项
    fileprivate func traverseAll(action: (NSMenuItem) -> Void) {
        action(self)
        submenu?.items.forEach { $0.traverseAll(action: action) }
    }
}

public extension NSMenu {
    /// 保存整个菜单状态
    func startSnapshot() {
        for item in items {
            item.traverseAll { $0.snapshotEnableValue = $0.snapshotEnableValue ?? $0.isEnabled }
        }
    }

    /// 禁用整个菜单
    func disableMenu() {
        items.forEach { $0.traverseAll { $0.isEnabled = false } }
    }

    /// 恢复整个菜单状态,如果没有快照不会恢复
    func revertSnapshot() {
        for item in items {
            item.traverseAll {
                if let value = $0.snapshotEnableValue {
                    $0.isEnabled = value
                    /// 清除快照
                    $0.snapshotEnableValue = nil
                }
            }
        }
    }
}
