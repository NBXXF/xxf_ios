//
//  KeyPolicy.swift
//  xxf_ios
//
//  Created by xxf on 7/21.
//

/// 控制窗口是否可以成为 key/main window 的策略
public enum KeyPolicy {
    /// 自动判断：当内容视图中包含可编辑控件（如 NSTextField、NSTextView）时，允许成为 key/main window
    case automatic

    /// 总是允许成为 key/main window，无论内容视图是否有输入控件
    case alwaysAllow

    /// 永不允许成为 key/main window，即使内容视图中有输入控件
    case neverAllow
}
