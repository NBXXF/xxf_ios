//
//  NSContext+View.swift
//  xxf_ios
//  上下文
//  Created by xxf on 7/19.
//
import AppKit

extension NSView: @preconcurrency NSContext {
    /// 弹窗依附的窗口
    public var attachedWindow: NSWindow? {
        return window
    }
}
