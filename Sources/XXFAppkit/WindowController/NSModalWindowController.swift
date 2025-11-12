//
//  NSModalWindowController.swift
//  xxf_ios
//
//  一个轻量级的模态弹窗控制器，适用于展示自定义 NSViewController
//  支持点击窗口外部关闭、圆角、透明、浮动、淡入淡出动画
//
//  Created by xxf on 7/21.
//

import AppKit

open class NSModalWindowController: NSWindowDelegateController, NSModalPresentable {
    private lazy var appLifecycleObserver = AppLifecycleObserver()

    public var canceledOnTouchOutside: Bool = true

    /// 点击外部事件监听器
    private var outsideClickMonitor: Any?

    // MARK: - 重写 contentViewController 设置逻辑

    open override var contentViewController: NSViewController? {
        didSet {
            if let window = window {
                setupWindow(window)
            }
        }
    }

    // MARK: - 初始化

    public override init(window: NSWindow?) {
        super.init(window: window ?? Self.createDefaultWindow())
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    /// 创建默认窗口，子类可重写
    open class override func createDefaultWindow() -> NSWindow {
        let size = CGSize.zero // 先给0，后续显示时调整大小
        let panel = XXFPannel(
            contentRect: NSRect(origin: .zero, size: size),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        panel.isFloatingPanel = true
        panel.level = .floating
        panel.hasShadow = true
        panel.backgroundColor = .clear
        panel.isOpaque = false
        panel.collectionBehavior = [.transient, .ignoresCycle]
        panel.contentViewController = nil // 初始不绑定，show时设置

        // 这个时机无用,请在setupWindow 中设置圆角什么的
        // panel.contentView = RoundedContainerView(cornerRadius: 12)
        panel.locationCenter()
        return panel
    }

    /// 窗口初始化后配置（监听内容视图大小变化）
    open func setupWindow(_ window: NSWindow) {
        guard let view = window.contentViewController?.view else { return }

        // 设置圆角为系统默认的10.0
        window.contentView?.wantsLayer = true
        window.contentView?.layer?.cornerRadius = 10.0
        window.contentView?.layer?.masksToBounds = true

        // 1. 先 ensure contentVC.view 完成 Auto Layout
        view.layoutSubtreeIfNeeded()

        // 再获取视图大小，更新窗口大小和位置
        if let view = window.contentViewController?.view {
            let fitting = view.fittingSize
            let size = (fitting.width > 0 && fitting.height > 0)
                ? fitting
                : view.frame.size
            var frame = window.frame
            frame.size = size
            window.setFrame(frame, display: true)
            window.locationCenter()
        }

        view.postsFrameChangedNotifications = true
        // 先移除旧监听，防止重复
        NotificationCenter.default.removeObserver(self,
                                                  name: NSView.frameDidChangeNotification,
                                                  object: view)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(viewFrameDidChange),
                                               name: NSView.frameDidChangeNotification,
                                               object: view)
    }

    // MARK: - 显示关闭

    open func show() {
        guard let panel = window else { return }

        panel.alphaValue = 0
        if canceledOnTouchOutside {
            // 非模态显示，带点击外部关闭
            panel.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)

            startOutsideClickMonitor()

            NSAnimationContext.runAnimationGroup { ctx in
                ctx.duration = 0.25
                panel.animator().alphaValue = 1
            }
        } else {
            // 模态显示，阻塞线程，用户必须先关闭窗口
            panel.alphaValue = 1
            NSApp.activate(ignoringOtherApps: true)
            NSApp.runModal(for: panel)
        }
    }

    open func dismiss() {
        guard let panel = window else { return }

        stopOutsideClickMonitor()

        // 如果是模态窗口，退出模态循环
        if !canceledOnTouchOutside {
            NSApp.stopModal()
            panel.close()
            return
        }
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.25
            panel.animator().alphaValue = 0
        }) {
            Task { @MainActor in
                panel.close()
            }
        }
    }

    public func doOnModalWillDismiss(_ callback: @escaping (NSWindow, [AnyHashable: Any]?) -> Void) -> UUID {
        return appLifecycleObserver.doOnWindowWillClose { [weak self] window, extra in
            guard let self else {
                return
            }
            if self.window === window {
                callback(window, extra)
            }
        }
    }

    // MARK: - 大小自适应处理

    @objc private func viewFrameDidChange() {
        guard
            let panel = window,
            let view = panel.contentViewController?.view
        else { return }
        let newSize = view.fittingSize
        var frame = panel.frame
        let oldSize = frame.size
        frame.size = newSize
        // 保持窗口中心点不变
        frame.origin.x -= (newSize.width - oldSize.width) / 2
        frame.origin.y -= (newSize.height - oldSize.height) / 2
        panel.setFrame(frame, display: true, animate: true)
    }

    open override func windowWillClose(_ notification: Notification) {
        super.windowWillClose(notification)
        NotificationCenter.default.removeObserver(self)
        stopOutsideClickMonitor()

        // 如果是模态窗口，退出模态循环,业务可能直接调用window.close
        if !canceledOnTouchOutside {
            NSApp.stopModal()
        }
    }

    open override func windowDidBecomeMain(_ notification: Notification) {
        super.windowDidBecomeMain(notification)
        startOutsideClickMonitor()
    }

    open override func windowDidResignMain(_ notification: Notification) {
        super.windowDidResignMain(notification)
        stopOutsideClickMonitor()
    }

    // MARK: - 点击外部关闭支持

    private func startOutsideClickMonitor() {
        guard canceledOnTouchOutside, outsideClickMonitor == nil else { return }
        outsideClickMonitor = NSEvent.addLocalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let panel = self.window else { return event }
            let mouseLocation = NSEvent.mouseLocation
            if !panel.frame.contains(mouseLocation) {
                DispatchQueue.main.async {
                    self.dismiss()
                }
                return nil
            }
            return event
        }
    }

    private func stopOutsideClickMonitor() {
        if let monitor = outsideClickMonitor {
            NSEvent.removeMonitor(monitor)
            outsideClickMonitor = nil
        }
    }
}
