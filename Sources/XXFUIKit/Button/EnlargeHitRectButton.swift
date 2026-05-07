//
//  EnlargeHitRectButton.swift
//  xxf_ios
//  扩大按钮的点选区域
//  Created by xxf on 5/7.
//

#if canImport(UIKit)
import UIKit

public typealias PlatformHitTestInsets = UIEdgeInsets
public typealias PlatformButton = UIButton
#elseif canImport(AppKit)
import AppKit

public typealias PlatformHitTestInsets = NSEdgeInsets
public typealias PlatformButton = NSButton
#endif

#if canImport(UIKit) || canImport(AppKit)
/**
 * 扩大按钮的点选区域
 */
open class EnlargeHitRectButton: PlatformButton {

    // MARK: - Properties

    /// 点击区域的扩展边距
    public var hitTestEdgeInsets: PlatformHitTestInsets = {
        #if canImport(UIKit)
        .zero
        #elseif canImport(AppKit)
        NSEdgeInsetsZero
        #endif
    }()

    /**
     返回当前按钮可以响应的热区大小

     - Returns: 如果按钮已经设置了热区，返回热区，没有设置则返回原值
     */
    public var enlargedRect: CGRect {
        #if canImport(UIKit)
        bounds.inset(by: PlatformHitTestInsets(
            top: -hitTestEdgeInsets.top,
            left: -hitTestEdgeInsets.left,
            bottom: -hitTestEdgeInsets.bottom,
            right: -hitTestEdgeInsets.right
        ))
        #elseif canImport(AppKit)
        CGRect(
            x: bounds.origin.x - hitTestEdgeInsets.left,
            y: bounds.origin.y - hitTestEdgeInsets.top,
            width: bounds.size.width + hitTestEdgeInsets.left + hitTestEdgeInsets.right,
            height: bounds.size.height + hitTestEdgeInsets.top + hitTestEdgeInsets.bottom
        )
        #endif
    }

    // MARK: - Override Methods

    #if canImport(UIKit)
    open override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        enlargedRect.contains(point)
    }
    #elseif canImport(AppKit)
    open override func hitTest(_ point: NSPoint) -> NSView? {
        guard enlargedRect.contains(point) else { return nil }
        return super.hitTest(point)
    }
    #endif
}
#endif
