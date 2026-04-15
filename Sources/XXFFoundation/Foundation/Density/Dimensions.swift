//
//  Dimensions.swift
//  xxf_ios
//  屏幕适配
//  Created by xxf on 7/9.
//
import CoreGraphics
import Foundation

#if canImport(UIKit)
    @preconcurrency import UIKit
#elseif canImport(AppKit)
    @preconcurrency import AppKit
#endif

@inline(__always)
private func runOnMain(_ work: @MainActor () -> CGFloat) -> CGFloat {
    if Thread.isMainThread {
        return MainActor.assumeIsolated {
            work()
        }
    }

    var result: CGFloat = 1
    DispatchQueue.main.sync {
        result = MainActor.assumeIsolated {
            work()
        }
    }
    return result
}

private final class ScreenScaleCacheBox: @unchecked Sendable {
    static let shared = ScreenScaleCacheBox()

    private let lock = NSLock()
    private var cachedValue: CGFloat?

    func get() -> CGFloat? {
        lock.lock()
        defer { lock.unlock() }
        return cachedValue
    }

    func set(_ value: CGFloat) {
        lock.lock()
        cachedValue = value
        lock.unlock()
    }

    func clear() {
        lock.lock()
        cachedValue = nil
        lock.unlock()
    }
}

/// 屏幕分辨率缩放参数（线程安全）
public var screenScale: CGFloat {
    if let cached = ScreenScaleCacheBox.shared.get() {
        return cached
    }

    let value: CGFloat
    #if canImport(UIKit)
        value = runOnMain {
            UIScreen.main.scale
        }
    #elseif canImport(AppKit)
        value = runOnMain {
            NSScreen.main?.backingScaleFactor ?? 2
        }
    #else
        value = 1 // 其他平台
    #endif

    ScreenScaleCacheBox.shared.set(value)
    return value
}

/// 清空 `screenScale` 缓存（如外接屏变化后可调用）
public func invalidateScreenScaleCache() {
    ScreenScaleCacheBox.shared.clear()
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
