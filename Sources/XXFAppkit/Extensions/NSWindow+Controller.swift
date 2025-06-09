//
//  NSWindow+Controller.swift
//  xxf_ios
//
//  Created by xxf on /5/28.
//

import AppKit

public extension NSWindow {
    /// 替换当前页面
    func presentAsReplaceWindow(for vc: NSViewController) {
        contentViewController = vc
    }

    /// 在当前页面上弹出modal
    func presentAsModalWindow(for vc: NSViewController) {
        let presentingVC = contentViewController
        presentingVC?.presentAsModalWindow(vc)
    }

    /// 从窗口底部弹出一个“滑动面板”
    func presentAsSheetWindow(for vc: NSViewController) {
        let presentingVC = contentViewController
        presentingVC?.presentAsSheet(vc)
    }
}
