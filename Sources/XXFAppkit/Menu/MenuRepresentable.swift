//
//  MenuRepresentable.swift
//  xxf_ios
//  菜单约束,更适合枚举,让业务逻辑更清晰
//  Created by xxf on 7/19.
//

import AppKit

public protocol MenuRepresentable: RawRepresentable, CaseIterable where RawValue == Int {
    /// 按钮的标题
    var title: String { get }

    /// 快捷键修饰符键
    /// .command
    /// .option
    /// .shift
    /// .control
    /// 没有就返回[]
    var keyEquivalentModifierMask: NSEvent.ModifierFlags { get }

    // String.empty 代表空,或者 双引号
    var keyEquivalent: String { get }
}
