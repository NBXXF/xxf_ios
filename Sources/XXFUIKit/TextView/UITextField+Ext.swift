//
//  UITextField+Ext.swift
//  xxf_ios
//
//  Created by xxf on 25/7.
//
#if canImport(UIKit)
import UIKit

public extension UITextField {
    // 运行时关联键（类型级别，避免文件级命名污染）
    private static let maxLengthKey = "UITextField.Ext.maxLength"
    private static let isLengthObserverAddedKey = "UITextField.Ext.isLengthObserverAdded"

    // 最大长度（可随时重设，不会重复订阅）
    var maxLength: Int {
        get {
            getAssociatedObject(Self.maxLengthKey) ?? Int.max
        }
        set {
            let safeLength = max(0, newValue)
            setAssociatedObject(safeLength, forKey: Self.maxLengthKey)
            // 只在第一次设置时添加监听
            if !isLengthObserverAdded {
                addLengthObserver()
                isLengthObserverAdded = true
            }
            // 设置后立即收敛一次，避免已有文本超长
            checkLength()
        }
    }
    
    // 标记是否已添加监听（防止重复绑定）
    private var isLengthObserverAdded: Bool {
        get {
            getAssociatedObject(Self.isLengthObserverAddedKey) ?? false
        }
        set {
            setAssociatedObject(newValue, forKey: Self.isLengthObserverAddedKey)
        }
    }
    
    private func addLengthObserver() {
        // 只添加一次 EditingChanged 监听
        self.addTarget(self, action: #selector(checkLength), for: .editingChanged)
    }
    
    @objc private func checkLength() {
        guard let text = self.text, !text.isEmpty else { return }
        let maxLen = self.maxLength
        guard maxLen >= 0 else { return }
        
        // 中文输入时不打断拼音（markedTextRange 存在时不截取）
        if let markedRange = self.markedTextRange,
           self.position(from: markedRange.start, offset: 0) != nil
        {
            return
        }
        
        // 超过长度则截断，并修复光标位置
        if text.count > maxLen {
            let cursorOffset: Int
            if let selectedRange = self.selectedTextRange {
                cursorOffset = self.offset(from: self.beginningOfDocument, to: selectedRange.start)
            } else {
                cursorOffset = maxLen
            }
            self.text = String(text.prefix(maxLen))
            // 保持光标在合理位置
            if let newPosition = self.position(from: self.beginningOfDocument, offset: min(cursorOffset, maxLen)) {
                self.selectedTextRange = self.textRange(from: newPosition, to: newPosition)
            }
        }
    }
}
#endif
