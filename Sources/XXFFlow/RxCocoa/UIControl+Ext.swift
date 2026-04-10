//
//  UIControll.swift
//  xxf_ios
//  让UIControl 也有点击事件
//  Created by xxf on 2022/4/10.
//

#if os(iOS) || os(visionOS)

import RxSwift
import UIKit
import RxCocoa

public extension Reactive where Base: UIControl {
    /// Reactive wrapper for `TouchUpInside` control event.
    var tap: ControlEvent<Void> {
        controlEvent(.touchUpInside)
    }
}

#endif
