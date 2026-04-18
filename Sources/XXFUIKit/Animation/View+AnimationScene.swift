//
//  View+AnimationScene.swift
//  xxf_ios
//
//  Created by xxf
//
#if canImport(UIKit)
import UIKit

public extension UIView {

    /// 点赞回弹动画：先快速缩小，再弹簧回弹到原尺寸
    ///
    /// 适用于点赞、收藏按钮点击反馈等场景。
    ///
    /// - Parameters:
    ///   - scale: 缩小比例，默认 0.7
    ///   - shrinkDuration: 缩小阶段时长，默认 0.12s
    ///   - restoreDuration: 回弹阶段时长，默认 0.28s
    ///   - springDamping: 弹簧阻尼（0-1，越小越弹），默认 0.5
    ///   - initialVelocity: 弹簧初速度，默认 0.6
    ///   - completion: 动画完成回调
    func likeAnimation(
        scale: CGFloat = 0.7,
        shrinkDuration: TimeInterval = 0.12,
        restoreDuration: TimeInterval = 0.28,
        springDamping: CGFloat = 0.5,
        initialVelocity: CGFloat = 0.6,
        completion: ((Bool) -> Void)? = nil
    ) {
        layer.removeAllAnimations()
        transform = .identity
        UIView.animate(
            withDuration: shrinkDuration,
            delay: 0,
            options: [.curveEaseOut, .beginFromCurrentState],
            animations: {
                self.transform = CGAffineTransform(scaleX: scale, y: scale)
            },
            completion: { _ in
                UIView.animate(
                    withDuration: restoreDuration,
                    delay: 0,
                    usingSpringWithDamping: springDamping,
                    initialSpringVelocity: initialVelocity,
                    options: [.curveEaseOut, .beginFromCurrentState],
                    animations: {
                        self.transform = .identity
                    },
                    completion: completion
                )
            }
        )
    }
}
#endif
