//
//  Dimensions.swift
//  xxf_ios
//  屏幕适配
//  Created by xxf on 7/9.
//
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

/// 屏幕分辨率缩放参数
@MainActor
public var screenScale: CGFloat {
    #if canImport(UIKit)
        if #available(iOS 13.0, *) {
            // Swift 5.9+ 主线程隔离安全访问
            return MainActor.assumeIsolated {
                UIScreen.main.scale
            }
        } else {
            // 旧系统版本 fallback：确保在主线程访问
            var scale: CGFloat = 2
            if Thread.isMainThread {
                scale = UIScreen.main.scale
            } else {
                DispatchQueue.main.sync {
                    scale = UIScreen.main.scale
                }
            }
            return scale
        }
    #elseif canImport(AppKit)
        if #available(macOS 10.15, *) {
            return MainActor.assumeIsolated {
                NSScreen.main?.backingScaleFactor ?? 2
            }
        } else {
            var scale: CGFloat = 2
            if Thread.isMainThread {
                scale = NSScreen.main?.backingScaleFactor ?? 2
            } else {
                DispatchQueue.main.sync {
                    scale = NSScreen.main?.backingScaleFactor ?? 2
                }
            }
            return scale
        }
    #else
        return 1 // 其他平台
    #endif
}

// MARK: 像素适配

// 统一的适配系数，可以根据屏幕、设备动态设置
public enum SizeAdapter {
    public nonisolated(unsafe) static var scaleFactor: CGFloat = 1.0
}

public extension BinaryInteger {
    // 像素适配
    var pt: CGFloat { CGFloat(self) * SizeAdapter.scaleFactor }
}

public extension BinaryFloatingPoint {
    // 像素适配
    var pt: CGFloat { CGFloat(self) * SizeAdapter.scaleFactor }
}

// MARK: 字体适配

// 统一的字体适配系数，可以根据屏幕、设备动态设置
public enum FontAdapter {
    public nonisolated(unsafe) static var scaleFactor: CGFloat = 1.0
}

public extension BinaryInteger {
    // 字体适配
    var ft: CGFloat { CGFloat(self) * FontAdapter.scaleFactor }
}

public extension BinaryFloatingPoint {
    // 字体适配
    var ft: CGFloat { CGFloat(self) * FontAdapter.scaleFactor }
}
