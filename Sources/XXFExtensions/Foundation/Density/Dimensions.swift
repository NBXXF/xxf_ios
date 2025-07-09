//
//  Dimensions.swift
//  xxf_ios
//  屏幕适配
//  Created by xxf on 7/9.
//
import CoreGraphics

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
