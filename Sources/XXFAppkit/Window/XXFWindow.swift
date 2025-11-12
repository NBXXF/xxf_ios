//
//  Untitled.swift
//  xxf_ios
//  解决window 没有标题的时候的时候会出现输入框无法输入
//  Created by xxf on 7/21.
//
import AppKit
import Foundation

open class XXFWindow: NSWindow {
    public var keyPolicy: KeyPolicy = .automatic

    open override var canBecomeKey: Bool {
        // 不能单纯判断是否有标题栏,如果是无边框弹窗（如 .borderless 或 .fullSizeContentView)
        // 没有标题栏的窗口可能无法正确响应键盘事件，需特别处理
        switch keyPolicy {
            case .alwaysAllow: return true
            case .neverAllow: return false
            case .automatic: return contentView?.descendantHasTextInput() ?? false
        }
    }

    open override var canBecomeMain: Bool {
        return canBecomeKey
    }
}

extension NSView {
    func descendantHasTextInput() -> Bool {
        if let textField = self as? NSTextField {
            return textField.isEditable
        }
        if let textField = self as? NSTextView {
            return textField.isEditable
        }
        for subview in subviews {
            if subview.descendantHasTextInput() {
                return true
            }
        }
        return false
    }
}
