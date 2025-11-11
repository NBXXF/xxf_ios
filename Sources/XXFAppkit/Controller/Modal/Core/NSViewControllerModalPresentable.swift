//
//  ModalPresentable.swift
//  xxf_ios
//  模态弹窗,实现有NSSheetModalViewController,NSPopoverModalViewController,NSModalViewController
//  Created by xxf on 7/21.
//
import AppKit
import Foundation

@MainActor
public protocol NSViewControllerModalPresentable: NSModalPresentable {
    /// 是否是以modal 的形式显示的,用常用vc内部既是普通vc 又是modalvc 来设置不同样式和不同逻辑分发
    var isShowsModal: Bool { get }
}
