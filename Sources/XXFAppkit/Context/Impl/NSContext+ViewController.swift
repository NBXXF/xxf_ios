//
//  NSContext+ViewController.swift
//  xxf_ios
//  上下文
//  Created by xxf on 7/19.
//
import AppKit

extension NSViewController: @preconcurrency NSContext {
    /// 弹窗依附的窗口
    public var attachedWindow: NSWindow? {
        if #available(macOS 14.0, *) {
            return self.viewIfLoaded?.window
        } else if isViewLoaded {
            return view.window
        } else {
            return nil
        }
    }
}
