//
//  ModalPresentable.swift
//  xxf_ios
//  模态弹窗,实现有NSSheetModalViewController,NSPopoverModalViewController,NSModalViewController
//  Created by xxf on 7/21.
//
import AppKit
import Foundation

@MainActor
public protocol NSModalPresentable {
    // 点击外部是否消失
    var canceledOnTouchOutside: Bool { get set }

    // 让模态显示
    func show()

    // 让模态消失
    func dismiss()

    /// 添加一个回调，即将被关闭/消失时调用。
    /// - Parameter callback: 带窗口和 userInfo 参数的闭包。
    /// - Returns: UUID 标识符，用于后续取消订阅。
    @discardableResult
    func doOnModalWillDismiss(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID
}
