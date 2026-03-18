//
//  ScreenUtils.swift
//  xxf_ios
//  屏幕比例适配
//  Created by xxf.
//
import CoreGraphics

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

/// 屏幕 frame，一次性获取宽高
@MainActor
public var screenFrame: CGRect {
    #if canImport(UIKit)
        if #available(iOS 13.0, *) {
            return MainActor.assumeIsolated {
                UIScreen.main.bounds
            }
        } else {
            var frame: CGRect = .zero
            if Thread.isMainThread {
                frame = UIScreen.main.bounds
            } else {
                DispatchQueue.main.sync {
                    frame = UIScreen.main.bounds
                }
            }
            return frame
        }
    #elseif canImport(AppKit)
        if #available(macOS 10.15, *) {
            return MainActor.assumeIsolated {
                NSScreen.main?.frame ?? .zero
            }
        } else {
            var frame: CGRect = .zero
            if Thread.isMainThread {
                frame = NSScreen.main?.frame ?? .zero
            } else {
                DispatchQueue.main.sync {
                    frame = NSScreen.main?.frame ?? .zero
                }
            }
            return frame
        }
    #else
        return .zero
    #endif
}

/// 屏幕宽度
@MainActor
public var screenWidth: CGFloat { screenFrame.width }

/// 屏幕高度
@MainActor
public var screenHeight: CGFloat { screenFrame.height }

// MARK: - 屏幕宽度比例扩展 (sw)

@MainActor
public extension BinaryInteger {
    /// 基于屏幕宽度的比例值
    /// - Returns: 屏幕宽度 * 当前值
    /// - 示例：1.sw = 屏幕宽度，2.sw = 2 倍屏幕宽度
    var sw: CGFloat {
        CGFloat(self) * screenWidth
    }
}

@MainActor
public extension BinaryFloatingPoint {
    /// 基于屏幕宽度的比例值
    /// - Returns: 屏幕宽度 * 当前值
    /// - 示例：0.5.sw = 屏幕宽度的一半
    var sw: CGFloat {
        CGFloat(self) * screenWidth
    }
}

// MARK: - 屏幕高度比例扩展 (sh)

@MainActor
public extension BinaryInteger {
    /// 基于屏幕高度的比例值
    /// - Returns: 屏幕高度 * 当前值
    /// - 示例：1.sh = 屏幕高度，2.sh = 2 倍屏幕高度
    var sh: CGFloat {
        CGFloat(self) * screenHeight
    }
}

@MainActor
public extension BinaryFloatingPoint {
    /// 基于屏幕高度的比例值
    /// - Returns: 屏幕高度 * 当前值
    /// - 示例：0.5.sh = 屏幕高度的一半
    var sh: CGFloat {
        CGFloat(self) * screenHeight
    }
}
