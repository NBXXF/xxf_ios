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

/// 屏幕宽度
@MainActor
public var screenWidth: CGFloat {
    #if canImport(UIKit)
        return UIScreen.main.bounds.width
    #elseif canImport(AppKit)
        return NSScreen.main?.frame.width ?? 0
    #else
        return 0
    #endif
}

/// 屏幕高度
@MainActor
public var screenHeight: CGFloat {
    #if canImport(UIKit)
        return UIScreen.main.bounds.height
    #elseif canImport(AppKit)
        return NSScreen.main?.frame.height ?? 0
    #else
        return 0
    #endif
}

/// 屏幕 frame
@MainActor
public var screenFrame: CGRect {
    #if canImport(UIKit)
        return UIScreen.main.bounds
    #elseif canImport(AppKit)
        return NSScreen.main?.frame ?? .zero
    #else
        return .zero
    #endif
}

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
