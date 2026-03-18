//
//  KeyboardResizeContainer+ScrollView.swift
//  XXFKeyboard
//
//  Created on 2026-03-18.
//

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import SnapKit

/// 支持 UIScrollView 的 KeyboardResizeContainer 扩展
/// 当键盘弹出时，自动调整 scrollView 的 contentInset 和 contentOffset
public extension KeyboardResizeContainer {

    /// 绑定 UIScrollView，自动处理键盘遮挡
    /// - Parameter scrollView: 要绑定的 scrollView
    func bindScrollView(_ scrollView: UIScrollView) {
        // 监听键盘高度，调整 contentInset
        keyboardVisibleHeight
            .drive(onNext: { [weak scrollView] height in
                scrollView?.contentInset.bottom = height
                scrollView?.verticalScrollIndicatorInsets.bottom = height
            })
            .disposed(by: disposeBag)

        // 监听键盘即将显示，调整 contentOffset 确保输入框可见
        RxKeyboard.instance.willShowVisibleHeight
            .drive(onNext: { [weak self, weak scrollView] keyboardHeight in
                guard let scrollView = scrollView else { return }

                // 找到当前第一响应者
                guard let textField = scrollView.findFirstResponder() else { return }

                // 计算 textField 在 scrollView 坐标系中的 frame
                let textFieldFrame = textField.convert(scrollView.bounds, from: scrollView)

                // 计算 textField 底部到键盘顶部的距离
                let keyboardTopY = UIScreen.main.bounds.height - keyboardHeight
                let textFieldBottomY = textFieldFrame.maxY

                // 如果 textField 被键盘遮挡，调整 offset
                if textFieldBottomY > keyboardTopY {
                    let offset = textFieldBottomY - keyboardTopY
                    let newOffsetY = scrollView.contentOffset.y + offset
                    scrollView.setContentOffset(CGPoint(x: 0, y: min(newOffsetY, scrollView.contentSize.height - scrollView.bounds.height)), animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITextField/UITextView Extension

public extension KeyboardResizeContainer {

    /// 绑定 UITextField，自动处理键盘遮挡和点击空白处收起键盘
    /// - Parameter textField: 要绑定的 textField
    func bindTextField(_ textField: UITextField) {
        // 确保 textField 在被遮挡时可见
        textField.rx.controlEvent(.editingDidBegin)
            .subscribe(onNext: { [weak self] _ in
                self?.scrollToTextField(textField)
            })
            .disposed(by: disposeBag)
    }

    /// 绑定 UITextView，自动处理键盘遮挡
    /// - Parameter textView: 要绑定的 textView
    func bindTextView(_ textView: UITextView) {
        textView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] _ in
                self?.scrollToTextView(textView)
            })
            .disposed(by: disposeBag)
    }

    /// 点击空白处收起键盘
    func addTapToDismiss() {
        let tapGesture = UITapGestureRecognizer()
        tapGesture.rx.event
            .subscribe(onNext: { [weak self] _ in
                self?.endEditing(true)
            })
            .disposed(by: disposeBag)
        addGestureRecognizer(tapGesture)
    }

    // MARK: - Private Helpers

    private func scrollToTextField(_ textField: UITextField) {
        guard let scrollView = contentView as? UIScrollView else { return }
        scrollToView(textField, in: scrollView)
    }

    private func scrollToTextView(_ textView: UITextView) {
        guard let scrollView = contentView as? UIScrollView else { return }
        scrollToView(textView, in: scrollView)
    }

    private func scrollToView(_ view: UIView, in scrollView: UIScrollView) {
        // 将 view 的 frame 转换到 scrollView 坐标系
        let viewFrameInScrollView = scrollView.convert(view.frame, from: view.superview)

        // 计算可见区域（减去键盘高度）
        let visibleHeight = scrollView.bounds.height - currentKeyboardHeight

        // 如果 view 在可见区域下方，滚动到 view
        if viewFrameInScrollView.maxY > visibleHeight {
            let offsetY = viewFrameInScrollView.minY - 20 // 留出 20pt 间距
            scrollView.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: true)
        }
    }
}

// MARK: - UIView Extension

private extension UIView {
    /// 递归查找第一响应者
    func findFirstResponder() -> UIView? {
        if self.isFirstResponder {
            return self
        }
        for subview in subviews {
            if let firstResponder = subview.findFirstResponder() {
                return firstResponder
            }
        }
        return nil
    }
}

#endif
