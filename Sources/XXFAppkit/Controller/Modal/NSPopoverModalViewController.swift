//  NSPopoverModalViewController.swift
//  xxf_ios
//  设置小面板、格式选择、日历选择器,特点是附着控件
//  Created by xxf on 2026/7/21.
//

import AppKit

/**
 三者对比表
 Behavior                            跟主窗口关系                                            切换 app 时                         用途举例
 .applicationDefined           独立存在，不依赖其他窗口                        不自动隐藏                         普通窗口 (文档、主窗口)
 .transient                           严格依附主窗口，父窗口消失它也消失      可能在切换时消失              工具条、小浮窗
 .semitransient                   依附主窗口，但更“独立”一些                      切到别的 app 时隐藏         字体面板、颜色面板
 */
open class NSPopoverModalViewController: NSCompatViewController, NSViewControllerModalPresentable {
    private lazy var appLifecycleObserver = AppLifecycleObserver()

    public var canceledOnTouchOutside: Bool = false {
        didSet {
            popover.behavior = canceledOnTouchOutside ? .transient : .semitransient
        }
    }

    public var isShowsModal: Bool {
        precondition(isWindowAttached, "window not attached")
        /// 注意: .applicationDefined 意味着 系统不会自动管理 popover 的显示和隐藏。
        return popover.isShown
    }

    private lazy var popover: NSPopover = NSPopover().apply { pop in
        // 设置显示大小
        /// pop.contentSize = NSSize(width: 300.pt, height: 218.pt)
        /// 优先级 contentSize > vc.preferredContentSize > vc.view frame or 约束
        pop.contentViewController = self
        pop.behavior = canceledOnTouchOutside ? .transient : .semitransient
        pop.animates = true
    }

    // MARK: - 生命周期

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - 显示 / 隐藏

    /// 默认显示方法：依附到 key window 居中显示
    open func show() {
        guard let keyWindow = NSApp.activeWindow,
              let contentView = keyWindow.contentView,
              !popover.isShown else { return }

        // 将 popover 附着到 contentView 中心
        let centerRect = NSRect(x: contentView.bounds.midX, y: contentView.bounds.midY, width: 1, height: 1)
        popover.show(relativeTo: centerRect, of: contentView, preferredEdge: .maxY)
    }

    /// 显示到指定 view
    open func show(relativeToView view: NSView, preferredEdge: NSRectEdge = .maxY) {
        guard !popover.isShown else { return }
        popover.show(relativeTo: view.bounds, of: view, preferredEdge: preferredEdge)
    }

    /// 显示到指定位置
    open func show(relativeTo positioningRect: NSRect, of positioningView: NSView, preferredEdge: NSRectEdge = .maxY) {
        guard !popover.isShown else { return }
        popover.show(relativeTo: positioningRect, of: positioningView, preferredEdge: preferredEdge)
    }

    /// 隐藏 popover
    open func dismiss() {
        popover.close()
    }

    public func doOnModalWillDismiss(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        return appLifecycleObserver.doOnWindowWillClose { [weak self] window, extra in
            guard let self else {
                return
            }
            if self.isWindowAttached && self.attachedWindow === window {
                callback(window, extra)
            }
        }
    }
}
