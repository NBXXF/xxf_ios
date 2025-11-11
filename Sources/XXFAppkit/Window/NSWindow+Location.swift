//
//  NSWindow+Location.swift
//  xxf_ios
//  屏幕定位
//  Created by xxf on 5/28.
//

import AppKit
import Foundation

public extension NSWindow {
    /// 手动根据窗口当前关联屏幕的可见区域，居中窗口
    /// window.center()方法有时候不起作用
    func locationCenterUsingVisibleFrame() {
        guard let screenFrame = screen?.visibleFrame ?? NSScreen.main?.visibleFrame else {
            return
        }
        let windowSize = frame.size
        let x = screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2
        let y = screenFrame.origin.y + (screenFrame.height - windowSize.height) / 2

        setFrameOrigin(NSPoint(x: x, y: y))
    }

    /// 让当前窗口居中显示于指定窗口中心位置，默认居中在 keyWindow 或 mainWindow
    /// - Parameter window: 参照窗口，默认 keyWindow 或 mainWindow
    func locationCenter(of window: NSWindow? = NSApp.keyWindow ?? NSApp.mainWindow) {
        guard let window = window else {
            // 没有指定窗口也没 key/main 窗口，居中到屏幕中心
            locationCenterUsingVisibleFrame()
            return
        }

        let parentFrame = window.frame
        let selfSize = frame.size

        let originX = parentFrame.origin.x + (parentFrame.size.width - selfSize.width) / 2
        let originY = parentFrame.origin.y + (parentFrame.size.height - selfSize.height) / 2

        setFrameOrigin(NSPoint(x: originX, y: originY))
    }

    /// NSWindow.cascadeTopLeft(from:)    官方级联定位（简单),不会避开已有窗口或考虑屏幕边界
    /// 定位相对于指定窗口偏移后，目标窗口应该放置的位置（不会越出屏幕), 否则定位到屏幕左上角
    /// - Parameters:
    ///   - window: 参考窗口，一般是 keyWindow 或 topWindow
    ///   - offset: 偏移量（默认右下）
    func locationRelativeToWindow(relativeTo window: NSWindow? = NSApplication.shared.activeWindow,
                                  offset: NSPoint = NSPoint(x: 30, y: -30))
    {
        guard let window = window else {
            // fallback 到主屏幕 visibleFrame 居中
            locationCenterUsingVisibleFrame()
            return
        }

        guard let screen = window.screen else {
            // fallback 到主屏幕 visibleFrame 居中
            locationCenterUsingVisibleFrame()
            return
        }

        let screenVisibleFrame = screen.visibleFrame
        let referenceFrame = window.frame
        let newWindowSize = frame.size

        // 参考窗口偏移位置
        var newOrigin = NSPoint(
            x: referenceFrame.origin.x + offset.x,
            y: referenceFrame.origin.y + offset.y
        )

        // 判断是否越界
        let isOutside =
            newOrigin.x < screenVisibleFrame.minX ||
            newOrigin.x + newWindowSize.width > screenVisibleFrame.maxX ||
            newOrigin.y < screenVisibleFrame.minY ||
            newOrigin.y + newWindowSize.height > screenVisibleFrame.maxY

        if isOutside {
            // 先计算安全的宽高，防止窗口比屏幕还大
            let safeWidth = min(newWindowSize.width, screenVisibleFrame.width)
            let safeHeight = min(newWindowSize.height, screenVisibleFrame.height)

            // X 方向：尽量靠左上角，但不能越界
            let fallbackX = min(screenVisibleFrame.minX + abs(offset.x),
                                screenVisibleFrame.maxX - safeWidth)

            // Y 方向：从屏幕顶部偏移，不能低于底边界
            let fallbackY = max(screenVisibleFrame.maxY - abs(offset.y) - safeHeight,
                                screenVisibleFrame.minY)

            newOrigin = NSPoint(x: fallbackX, y: fallbackY)
        }

        setFrameOrigin(newOrigin)
    }
}
