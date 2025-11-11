//
//  NSContext.swift
//  xxf_ios
//  上下文  三种实现(vc,view,window) 相对于NSResponder 都有window的概念
//  Created by xxf on 7/19.
//
import AppKit

public protocol NSContext: AnyObject {
    /// 弹窗依附的窗口
    var attachedWindow: NSWindow? { get }
}
