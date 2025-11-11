//
//  BusEvent.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

import Foundation

/// 由于swift是多基类的问题
public protocol BusEvent {}
public extension BusEvent {
    func postEvent() {
        RxBus.shared.post(self)
    }

    func postEventSticky() {
        RxBus.shared.postSticky(self)
    }

    static func observeEvent() -> Observable<Self> {
        RxBus.shared.observe(Self.self)
    }

    static func observeEventSticky() -> Observable<Self> {
        RxBus.shared.observeSticky(Self.self)
    }
}

// 基础数值类型
extension Int: BusEvent {}
extension Int64: BusEvent {}
extension Float: BusEvent {}
extension Double: BusEvent {}
extension Bool: BusEvent {}

// 标识符
extension String: BusEvent {}
extension UUID: BusEvent {}

// 时间相关
extension Date: BusEvent {}
extension DateComponents: BusEvent {}

// Foundation / 系统类
extension NSObject: BusEvent {}
extension URL: BusEvent {}
extension IndexPath: BusEvent {}

// UI 布局类型（来自 CoreGraphics）
extension CGPoint: BusEvent {}
extension CGSize: BusEvent {}
extension CGRect: BusEvent {}

extension ActionTypeEvent: BusEvent where T: Sendable {}
