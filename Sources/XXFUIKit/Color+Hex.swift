//
//  Color+Hex.swift
//  xxf_ios
//
//  Created by xxf on 2022/7/11.
//

#if canImport(UIKit)
import UIKit

public extension UIColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

#elseif canImport(AppKit)
import AppKit

public extension NSColor {
    convenience init(hex: UInt32) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255
        let g = CGFloat((hex >> 8) & 0xFF) / 255
        let b = CGFloat(hex & 0xFF) / 255
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}
#endif


#if canImport(UIKit)
import UIKit
public typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
#endif

extension PlatformColor {
    // 用16进制更快
    public convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let r = CGFloat((hex >> 16) & 0xFF) / 255.0
        let g = CGFloat((hex >> 8) & 0xFF) / 255.0
        let b = CGFloat(hex & 0xFF) / 255.0
        #if canImport(UIKit)
        self.init(red: r, green: g, blue: b, alpha: alpha)
        #elseif canImport(AppKit)
        self.init(red: r, green: g, blue: b, alpha: alpha)
        #endif
    }
}
