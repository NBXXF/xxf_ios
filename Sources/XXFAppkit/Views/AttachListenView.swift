//
//  AttachListenView.swift
//  xxf_ios
//  监听view 是否attached
//  Created by xxf on 9/15.
//

import AppKit

public final class AttachListenView: NSView {
    /// 回调形式
    public var onAttachToWindow: ((NSView) -> Void)?
    public var onDetachFromWindow: ((NSView) -> Void)?

    public func attchToParent(on parentView: NSView) {
        // 如果 attachListenView 已存在并且已经是 parentView 的子视图，就直接返回
        if superview == parentView {
            return
        }
        // 如果 attachListenView 已存在但在旧的 view 上，先移除
        removeFromSuperview()

        isHidden = true
        parentView.addSubview(self)
    }

    override public func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        if let win = window {
            onAttachToWindow?(self)
        } else {
            onDetachFromWindow?(self)
        }
    }
}
