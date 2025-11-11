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
public var screenScale: CGFloat {
    #if canImport(UIKit)
        return UIScreen.main.scale
    #elseif canImport(AppKit)
        return NSScreen.main?.backingScaleFactor ?? 2
    #else
        return 1 // 兜底：其他平台（Linux、server side Swift 等）
    #endif
}

// 统一的适配系数，可以根据屏幕、设备动态设置
public enum SizeAdapter {
    public nonisolated(unsafe) static var scaleFactor: CGFloat = 1.0
}

public extension CGFloat {
    var pt: CGFloat {
        return self * SizeAdapter.scaleFactor
    }
}

public extension Double {
    var pt: CGFloat {
        return CGFloat(self).pt
    }
}

public extension Float {
    var pt: CGFloat {
        return CGFloat(self).pt
    }
}

public extension Int {
    var pt: CGFloat {
        return CGFloat(self).pt
    }
}
