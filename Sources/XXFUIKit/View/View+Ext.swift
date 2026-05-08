//
//  View+Ext.swift
//  xxf_ios
//
//  Created by xxf 5/8.
//

#if canImport(UIKit)
import UIKit

public typealias PlatformView = UIView
public typealias PlatformImage = UIImage

#elseif canImport(AppKit)
import AppKit

public typealias PlatformView = NSView
public typealias PlatformImage = NSImage
#endif

#if canImport(UIKit) || canImport(AppKit)

/// `UIView` / `NSView` 的截图相关跨平台扩展。
///
/// 提供把视图层级（含其子视图）渲染成位图的统一入口，iOS / tvOS / Mac Catalyst 与 macOS 共享同一组 API 形态。
public extension PlatformView {

    /// 把当前 view 及其子视图层级渲染成一张图（iOS / tvOS：`UIImage`；macOS：`NSImage`）。
    ///
    /// **功能**：在当前 `bounds` 范围内截取一帧位图。
    /// - iOS / tvOS / Mac Catalyst：基于 `UIGraphicsImageRenderer + drawHierarchy(afterScreenUpdates:)`
    /// - macOS：基于 `NSBitmapImageRep + cacheDisplay(in:to:)`
    ///
    /// **线程**：必须在主线程调用（`UIView` / `NSView` 均仅主线程安全）。
    ///
    /// **使用限制 / 前置条件**：
    /// - 视图应已完成至少一次布局（`bounds.size` 非零），否则返回 `nil`
    /// - iOS：`afterScreenUpdates: true` 时，调用栈不应处于 layout / draw 流程内（如 `layoutSubviews`、`draw(_:)`），
    ///   否则可能引发递归刷新或得到不一致结果
    /// - macOS：建议视图为 layer-backed（`wantsLayer = true`）；非 layer-backed 视图的 `cacheDisplay` 可能产出空白
    ///
    /// **边界**：`bounds` 任意一边 ≤ 0 时返回 `nil`，避免产出无意义空图；位图分配失败时同样返回 `nil`。
    ///
    /// **副作用**：iOS 触发一次屏幕更新；macOS 仅同步绘制当前 layer 层级，不修改外部状态。
    ///
    /// **性能**：开销与视图层级复杂度成正比；`scale` 减半内存约减为 1/4，缩略图场景建议传 `1`。
    ///
    /// - Parameters:
    ///   - scale: 输出位图 scale，单位倍率。`0`（默认）沿用当前所在窗口 / 主屏 scale；`> 0` 按指定值生成；负数视作 `0`。
    ///   - isOpaque: 视图是否完全不透明。`true` 丢弃 alpha 通道、约节省 25% 内存；视图含透明区域时务必保持 `false`。默认 `false`。
    /// - Returns: 渲染完成的图片；`bounds` 为空或资源分配失败时返回 `nil`。
    func snapshot(scale: CGFloat = 0, isOpaque: Bool = false) -> PlatformImage? {
        let captureBounds = bounds
        guard captureBounds.width > 0, captureBounds.height > 0 else {
            assertionFailure("snapshot() called on view with empty bounds: \(captureBounds)")
            return nil
        }

        #if canImport(UIKit)
        let format = UIGraphicsImageRendererFormat.preferred()
        if scale > 0 {
            format.scale = scale
        }
        format.opaque = isOpaque

        let renderer = UIGraphicsImageRenderer(bounds: captureBounds, format: format)
        return renderer.image { _ in
            drawHierarchy(in: captureBounds, afterScreenUpdates: true)
        }
        #elseif canImport(AppKit)
        let pointSize = captureBounds.size
        let pixelScale: CGFloat = scale > 0
            ? scale
            : (window?.backingScaleFactor ?? NSScreen.main?.backingScaleFactor ?? 2)

        let pixelsWide = Int((pointSize.width * pixelScale).rounded())
        let pixelsHigh = Int((pointSize.height * pixelScale).rounded())
        guard pixelsWide > 0, pixelsHigh > 0,
              let rep = NSBitmapImageRep(
                  bitmapDataPlanes: nil,
                  pixelsWide: pixelsWide,
                  pixelsHigh: pixelsHigh,
                  bitsPerSample: 8,
                  samplesPerPixel: isOpaque ? 3 : 4,
                  hasAlpha: !isOpaque,
                  isPlanar: false,
                  colorSpaceName: .deviceRGB,
                  bytesPerRow: 0,
                  bitsPerPixel: 0
              )
        else {
            return nil
        }
        rep.size = pointSize
        cacheDisplay(in: captureBounds, to: rep)

        let image = NSImage(size: pointSize)
        image.addRepresentation(rep)
        return image
        #else
        return nil
        #endif
    }

    /// 等价于 `snapshot(scale:isOpaque:)`，命名别名。
    ///
    /// - SeeAlso: ``snapshot(scale:isOpaque:)``
    /// - Parameters:
    ///   - scale: 输出位图 scale，单位倍率。`0`（默认）沿用当前所在窗口 / 主屏 scale；`> 0` 按指定值生成；负数视作 `0`。
    ///   - isOpaque: 视图是否完全不透明。`true` 丢弃 alpha 通道、约节省 25% 内存。默认 `false`。
    /// - Returns: 渲染完成的图片；`bounds` 为空时返回 `nil`。
    func toImage(scale: CGFloat = 0, isOpaque: Bool = false) -> PlatformImage? {
        snapshot(scale: scale, isOpaque: isOpaque)
    }
}

#endif
