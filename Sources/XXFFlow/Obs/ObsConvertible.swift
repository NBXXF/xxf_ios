//
//  ObsConvertible.swift
//  xxf_ios
//  支持数据直接点语法创建可观察的对象,借鉴flutter getx.obs
//  多用于viewModel,建立响应式ui,相比于Combine,Rx 更成熟、结合业务数据逻辑生态更好
//  用法:
//   “1”.obs 或者 Obs(value: "hello") 或者obs("hello")
//    数组类型 [GridItem]().obs 或者obs([GridItem]())
//  Created by xxf on 5/26.
//

import AVFoundation
import CoreGraphics
import CoreLocation
import CoreMedia
import Foundation
import QuartzCore
import RxRelay
import XXFFoundation

/// 给 BehaviorRelay 取个别名叫 Obs
public typealias Obs<Element> = BehaviorRelay<Element>

public protocol ObsConvertible {}

public extension ObsConvertible {
    /// 可读写,线程自由控制,核心是一个粘性事件的观察者设计模式
    ///   “1”.obs 或者 Obs(value: "hello") 或者obs("hello")
    ///    数组类型 [GridItem]().obs 或者obs([GridItem]())
    var obs: BehaviorRelay<Self> {
        BehaviorRelay(value: self)
    }
}

///   “1”.obs 或者 Obs(value: "hello") 或者obs("hello")
///    数组类型 [GridItem]().obs 或者obs([GridItem]())
public func obs<T: ObsConvertible>(_ value: T) -> BehaviorRelay<T> {
    value.obs
}

public extension BehaviorRelay {
    /// 可写包装：读 = `value`，写 = `accept(_:)`
    var state: Element {
        get { value } // 直接读现有只读属性
        set { accept(newValue) } // 写时仍走 accept()，触发广播
    }

    /// 只读的, 将 BehaviorRelay 转为 Driver，用于 UI 绑定（只读、主线程、安全）
    var drived: Driver<Element> {
        asDriver()
    }

    /// drived, 将 BehaviorRelay 转为 Driver，用于 UI 绑定（只读、主线程、安全）
    func asDriver() -> Driver<Element> {
        // BehaviorRelay 本身不会 error，故此处直接空序列作为备选
        asDriver(onErrorDriveWith: .empty())
    }
}

// 基础类型
extension String: ObsConvertible {}
extension Int: ObsConvertible {}
extension Double: ObsConvertible {}
extension Float: ObsConvertible {}
extension Bool: ObsConvertible {}
extension Character: ObsConvertible {}

extension UInt: ObsConvertible {}
extension Int8: ObsConvertible {}
extension Int16: ObsConvertible {}
extension Int32: ObsConvertible {}
extension Int64: ObsConvertible {}

extension UInt8: ObsConvertible {}
extension UInt16: ObsConvertible {}
extension UInt32: ObsConvertible {}
extension UInt64: ObsConvertible {}

extension CGFloat: ObsConvertible {}

extension Decimal: ObsConvertible {}

// 容器
extension Array: ObsConvertible {}
extension Dictionary: ObsConvertible {}
extension Set: ObsConvertible {}

// NSObject及其所有子类统一扩展
extension NSObject: ObsConvertible {}

// Foundation 非 NSObject 子类
extension Date: ObsConvertible {}
extension URL: ObsConvertible {}
extension Data: ObsConvertible {}
extension IndexPath: ObsConvertible {}
extension UUID: ObsConvertible {}

// CoreGraphics 结构体
extension CGPoint: ObsConvertible {}
extension CGRect: ObsConvertible {}
extension CGSize: ObsConvertible {}
extension CGVector: ObsConvertible {}

// 泛型容器相关
extension Optional: ObsConvertible {}
extension Result: ObsConvertible {}

// Foundation 其他结构体或非 NSObject 类型
extension Locale: ObsConvertible {}

// CoreAnimation 结构体
extension CATransform3D: ObsConvertible {}

// CoreAnimation 类 (NSObject子类，不用单独扩展)
// CAAnimation、CALayer 已经包含在 NSObject 扩展中

// CoreMedia 结构体
extension CMTime: ObsConvertible {}
extension CMTimeRange: ObsConvertible {}
extension CMTimeMapping: ObsConvertible {}

// CoreLocation 结构体和类
extension CLLocationCoordinate2D: ObsConvertible {}
// CLLocation 是 NSObject 子类，已被 NSObject 扩展覆盖

extension IndexSet: ObsConvertible {}
extension Measurement: ObsConvertible {}

// 自己的模型
extension Pair: ObsConvertible {}
extension Triple: ObsConvertible {}
