//
//  NSView+ClickAction.swift
//  xxf_ios
//  任意view上面的点击事件,如图片(appkit 图片是不支持点击事件,除非加NSGestureRecognizer)
//  Created by xxf on 7/30.
//

/**
 setClickAction    设置单击（左键）动作
 setDoubleClickAction    设置双击（左键）动作
 setRightClickAction    设置右键单击动作
 removeClickAction    移除单击事件
 removeDoubleClickAction    移除双击事件
 removeRightClickAction    移除右键事件
 */
import AppKit

// 手势类型标识
private enum GestureType: Int {
    case click = 1
    case doubleClick = 2
    case rightClick = 3
}

// 包装器：绑定 gesture + handler
private class GestureWrapper {
    var gesture: NSGestureRecognizer
    var handler: () -> Void

    init(gesture: NSGestureRecognizer, handler: @escaping () -> Void) {
        self.gesture = gesture
        self.handler = handler
    }
}

// 存储所有 gesture 的 key
private nonisolated(unsafe) var gestureStoreKey: UInt8 = 0

public extension NSView {
    // MARK: - 公共接口

    /// 设置单击（左键）事件，重复设置会覆盖旧事件
    func setClickAction(_ handler: @escaping () -> Void) {
        setGesture(.click, clickCount: 1, buttonIndex: 0, handler: handler)
    }

    /// 设置双击（左键）事件
    func setDoubleClickAction(_ handler: @escaping () -> Void) {
        setGesture(.doubleClick, clickCount: 2, buttonIndex: 0, handler: handler)
    }

    /// 设置右键单击事件
    func setRightClickAction(_ handler: @escaping () -> Void) {
        setGesture(.rightClick, clickCount: 1, buttonIndex: 1, handler: handler)
    }

    /// 移除单击事件
    func removeClickAction() {
        removeGesture(.click)
    }

    /// 移除双击事件
    func removeDoubleClickAction() {
        removeGesture(.doubleClick)
    }

    /// 移除右键点击事件
    func removeRightClickAction() {
        removeGesture(.rightClick)
    }

    // MARK: - 私有实现

    private func setGesture(
        _ type: GestureType,
        clickCount: Int,
        buttonIndex: Int,
        handler: @escaping () -> Void
    ) {
        removeGesture(type)

        let gesture = NSClickGestureRecognizer(target: self, action: #selector(_handleClick(_:)))
        gesture.numberOfClicksRequired = clickCount
        gesture.buttonMask = 1 << buttonIndex

        addGestureRecognizer(gesture)

        var store = gestureStore
        store[type.rawValue] = GestureWrapper(gesture: gesture, handler: handler)
        gestureStore = store
    }

    private func removeGesture(_ type: GestureType) {
        var store = gestureStore
        if let wrapper = store[type.rawValue] {
            removeGestureRecognizer(wrapper.gesture)
            store[type.rawValue] = nil
        }
        gestureStore = store
    }

    @objc private func _handleClick(_ sender: NSClickGestureRecognizer) {
        for (_, wrapper) in gestureStore {
            if wrapper.gesture === sender {
                wrapper.handler()
                break
            }
        }
    }

    private var gestureStore: [Int: GestureWrapper] {
        get {
            objc_getAssociatedObject(self, &gestureStoreKey) as? [Int: GestureWrapper] ?? [:]
        }
        set {
            objc_setAssociatedObject(self, &gestureStoreKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
