//
//  XXFKeyboard.swift
//  XXFKeyboard
//
//  Created on 2026-03-18.
//

#if os(iOS)
import Foundation
import RxKeyboard

/// XXFKeyboard 模块
/// 基于 RxKeyboard 提供的键盘适配组件
///
/// 主要功能：
/// - KeyboardResizeContainer: 类似 Android adjustPan 的容器，自动调整高度适配键盘
///
/// 使用示例：
/// ```swift
/// import XXFKeyboard
///
/// class ViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         let container = KeyboardResizeContainer()
///         view.addSubview(container)
///         container.snp.makeConstraints {
///             $0.edges.equalTo(view.safeAreaLayoutGuide)
///         }
///
///         let contentView = UIView()
///         container.bindContentView(contentView)
///     }
/// }
/// ```
public struct XXFKeyboard {

    /// 获取单例 RxKeyboard 实例
    /// 可以直接使用它来订阅键盘事件
    public static nonisolated(unsafe) let instance = RxKeyboard.instance

    private init() {}
}

// MARK: - Re-exports

// 重新暴露 RxKeyboard 的类型，方便使用者
public typealias KeyboardFrameObservable = RxKeyboard

#endif
