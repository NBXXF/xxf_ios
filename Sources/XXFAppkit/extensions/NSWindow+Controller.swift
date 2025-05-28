//
//  NSWindow+Controller.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/28.
//

import AppKit

extension NSWindow {
    /// 替换当前页面
    func presentAsReplaceWindow(for vc: NSViewController) {
        contentViewController = vc
    }

    /// 在当前页面上弹出modal
    func presentAsModalWindow(for vc: NSViewController) {
        let presentingVC = contentViewController
        presentingVC?.presentAsModalWindow(vc)
    }
}
