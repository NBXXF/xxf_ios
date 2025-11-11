//
//  XXFPannel.swift
//  xxf_ios
//  解决window 没有标题的时候的时候会出现输入框无法输入
//  Created by xxf on 7/21.
//
import AppKit
import Foundation

open class XXFPannel: NSPanel {
    public var keyPolicy: KeyPolicy = .automatic

    override open var canBecomeKey: Bool {
        // 不能单纯判断是否有标题栏,如果是无边框弹窗（如 .borderless 或 .fullSizeContentView)
        // 没有标题栏的窗口可能无法正确响应键盘事件，需特别处理
        switch keyPolicy {
        case .alwaysAllow: return true
        case .neverAllow: return false
        case .automatic: return contentView?.descendantHasTextInput() ?? false
        }
    }

    override open var canBecomeMain: Bool {
        return canBecomeKey
    }
}
