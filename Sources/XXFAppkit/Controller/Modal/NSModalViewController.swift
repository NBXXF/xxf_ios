//
//  NSModalViewController.swift
//  xxf_ios
//  模态弹窗的vc,类似DialogFragment
//  Created by xxf on 2026/7/21.
//

import AppKit

open class NSModalViewController: NSCompatViewController, NSViewControllerModalPresentable {
    private lazy var appLifecycleObserver = AppLifecycleObserver()

    // MARK: - Public

    public var canceledOnTouchOutside: Bool = true {
        didSet {
            windowController?.canceledOnTouchOutside = canceledOnTouchOutside
        }
    }

    public var isShowsModal: Bool {
        precondition(isWindowAttached, "window not attached")
        return attachedWindow === windowController?.window
    }

    // MARK: - Private

    // 必须加weak 不然会导致释放问题
    private weak var windowController: NSModalWindowController?

    // MARK: - 生命周期

    public init() {
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func initWindowController() {
        if windowController == nil {
            windowController = NSModalWindowController()
        }
        if windowController?.contentViewController != self {
            windowController?.contentViewController = self
            windowController?.canceledOnTouchOutside = canceledOnTouchOutside
            setupWindow(windowController!.window!)
        }
    }

    // MARK: - 窗口配置（可扩展）

    /// 创建后设置窗口相关行为，支持拖动、尺寸监听等
    open func setupWindow(_: NSWindow) {}

    public func show() {
        initWindowController()
        windowController?.show()
    }

    public func dismiss() {
        windowController?.dismiss()
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
