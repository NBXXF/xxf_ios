//  NSSheetModalViewController.swift
//  xxf_ios
//  阻塞当前窗口（附着在标题栏下方）,不同于独立window,有依附关系
//  Created by xxf on 2026/7/21.
//

import AppKit

/// 切记 一定要设置大小
open class NSSheetModalViewController: NSCompatViewController, NSViewControllerModalPresentable {
    private lazy var appLifecycleObserver = AppLifecycleObserver()

    public var canceledOnTouchOutside: Bool = false // 官方现在没有api

    public var isShowsModal: Bool {
        precondition(isWindowAttached, "window not attached")
        return attachedWindow?.sheetParent != nil
    }

    // MARK: - 生命周期

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    open override func loadView() {
        // 使用 frame 初始化，设置默认大小
        let rootView = NSView(frame: NSRect(x: 0, y: 0, width: 300.pt, height: 218.pt))

        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.windowBackgroundColor.cgColor

        view = rootView
    }

    open override func viewWillAppear() {
        super.viewWillAppear()
        validationSheetParentMenu(validationEnabled: false)
    }

    open override func viewWillDisappear() {
        super.viewWillDisappear()
        validationSheetParentMenu(validationEnabled: true)
    }

    /// 处理主窗口的菜单是否可以点击,这个一般规律是弹窗出来主菜单不可点击
    /// - Parameter validationEnabled: 是否可以点击
    open func validationSheetParentMenu(validationEnabled: Bool) {
        if let window = attachedWindow?.sheetParent {
            window.mainMenu.let { menu in
                if !validationEnabled {
                    menu.startSnapshot()
                    menu.disableMenu()
                } else {
                    menu.revertSnapshot()
                }
            }
        }
    }

    open func show() {
        guard let activeWindow = NSApplication.shared.activeWindow else {
            assertionFailure("⚠️ The window has no focus and cannot display content.")
            return
        }
        show(on: activeWindow)
    }

    /// 在指定窗口上弹出弹层
    /// - Parameter context: 上下文对象
    open func show(on context: NSContext) {
        if context === self {
            assertionFailure("not self show self")
            return
        }
        guard let overWindow = context.attachedWindow else {
            assertionFailure("⚠️ The window has no focus and cannot display content.")
            return
        }
        overWindow.presentAsSheetWindow(for: self)
    }

    open func dismiss() {
        dismiss(nil)
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
