//
//  NSCompatViewController.swift
//  xxf_ios
//  处理兼容性问题
//  Created by xxf on 9/10.
//

import AppKit
import XXFFlow

open class NSCompatViewController: NSViewController, @preconcurrency NSWindowListenable {
    open override var view: NSView {
        get {
            return super.view
        }
        set {
            super.view = newValue
            /// 添加一个隐藏的view 进行监听
            innerAttachListenView.attchToParent(on: newValue)
        }
    }

    private lazy var innerAttachListenView: AttachListenView = AttachListenView(frame: .zero).apply { view in
        /// 监听
        view.onAttachToWindow = { [weak self] _ in
            self?.viewDidAttachToWindow()
        }
        view.onDetachFromWindow = { [weak self] _ in
            self?.viewDidDetachFromWindow()
        }
    }

    open override func loadView() {
        // 不能调用父类的 macos 13会闪退
        // super.loadView()
        // 初始化默认 view 避免崩溃
        view = NSView()
    }

    // MARK: 附加到window上面

    open func viewDidAttachToWindow() {}

    // MARK: 从window上面移除

    open func viewDidDetachFromWindow() {}
}
