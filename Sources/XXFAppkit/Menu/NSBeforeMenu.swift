//
//  NSBeforeMenu.swift
//  xxf_ios
//  将自定义的菜单移动到前面,是按tag来的,系统的tag 都是0
//  Created by xxf on 2023/8/25.
//
import AppKit

/// 支持回调自定义排序或提前的菜单
public class NSBeforeMenu: NSMenu, NSMenuDelegate {
    /// 回调：返回 true 的菜单项会被移动到最前面
    public var shouldMoveToFront: (NSMenuItem) -> Bool

    public init(title: String, shouldMoveToFront: @escaping ((NSMenuItem) -> Bool)) {
        self.shouldMoveToFront = shouldMoveToFront
        super.init(title: title)
        delegate = self
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) { fatalError() }

    public func menuWillOpen(_: NSMenu) {
        // 找出需要提前的菜单项
        let frontItems = items.filter { shouldMoveToFront($0) }

        // 移除这些菜单项
        frontItems.forEach { removeItem($0) }

        // 插入到最前面，保持原来的顺序
        for (index, item) in frontItems.enumerated() {
            insertItem(item, at: index)
        }
    }
}
