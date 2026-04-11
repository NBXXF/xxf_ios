//
//  KeyboardPanelContainer.swift
//  XXFKeyboard
//
//  Created on 2026-04-11.
//

#if os(iOS)
import RxCocoa
import RxKeyboard
import RxSwift
import SnapKit
import UIKit

/// KeyboardPanelContainer - 键盘面板容器
///
/// 容器高度与键盘实时高度保持同步，适用于表情面板、功能面板等场景。
///
/// ## 核心设计
///
/// - **实时跟随**: 使用 `RxKeyboard.instance.visibleHeight` 实时获取键盘高度
/// - **防抖布局**: 使用 `throttle` 限制布局频率（避免 iPad 拖动时性能问题）
/// - **模式切换**: 支持 `.auto` / `.always` / `.alwaysWithInitialHeight` 三种模式
///
/// ## 显示模式
///
/// ### `.auto` - 自动适配（默认）
/// 键盘收起时高度为 0，弹出时等于键盘实时高度。
///
/// ```swift
/// let emojiPanel = KeyboardPanelContainer(mode: .auto)
/// // 键盘收起: height = 0
/// // 键盘弹出: height = 291pt (跟随键盘)
/// ```
///
/// ### `.always` - 总是显示
/// 始终显示键盘标准高度（使用 `KeyboardHeightProvider.standardHeight`）。
/// 键盘收起后仍保持高度，适用于需要预占位的场景。
///
/// ```swift
/// let toolbar = KeyboardPanelContainer(mode: .always)
/// // 高度 = Provider.standardHeight（缓存值或预估值）
/// ```
///
/// ### `.alwaysWithInitialHeight(CGFloat)` - 固定高度
/// 始终显示指定高度，不受键盘影响。
///
/// ## 性能优化
///
/// - 布局更新使用 `throttle(0.05)`，限制为每秒最多 20 次
/// - 高度变化小于 0.5pt 时忽略，避免微小抖动
@MainActor
open class KeyboardPanelContainer: UIView {
    // MARK: - Display Mode

    public enum DisplayMode: Equatable {
        /// 自动适配：跟随键盘实时高度
        case auto

        /// 总是显示：使用键盘标准高度（Provider 缓存值）
        case always

        /// 总是显示指定高度
        case alwaysWithInitialHeight(CGFloat)

        public static func == (lhs: DisplayMode, rhs: DisplayMode) -> Bool {
            switch (lhs, rhs) {
            case (.auto, .auto), (.always, .always): return true
            case (.alwaysWithInitialHeight(let a), .alwaysWithInitialHeight(let b)): return a == b
            default: return false
            }
        }
    }

    // MARK: - Properties

    /// 显示模式
    public var mode: DisplayMode {
        didSet {
            guard mode != oldValue else { return }
            applyModeChange()
        }
    }

    /// 当前显示高度
    public private(set) var currentHeight: CGFloat = 0

    private var heightConstraint: Constraint?
    private weak var contentView: UIView?
    private let disposeBag = DisposeBag()

    // 动画参数
    private var animationDuration: TimeInterval = 0.25
    private var animationOptions: UIView.AnimationOptions = .curveEaseInOut

    // 状态标记
    private var isInitialLayoutDone = false
    private var lastKeyboardHeight: CGFloat = 0

    private var keyboardDisposable: Disposable?

    // MARK: - Initialization

    public init(mode: DisplayMode = .auto) {
        self.mode = mode
        super.init(frame: .zero)
        setupKeyboardObserver()
    }

    public required init?(coder: NSCoder) {
        self.mode = .auto
        super.init(coder: coder)
        setupKeyboardObserver()
    }

    // MARK: - Layout

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !isInitialLayoutDone {
            isInitialLayoutDone = true
            applyModeChange() // 首次布局时应用当前模式
        }
    }

    // MARK: - Setup

    private func setupKeyboardObserver() {
        // 获取键盘动画参数
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.extractAnimationParams(from: notification)
            })
            .disposed(by: disposeBag)
    }

    private func extractAnimationParams(from notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 7
        animationDuration = duration
        animationOptions = UIView.AnimationOptions(rawValue: curve << 16)
    }

    // MARK: - Mode Handling

    private func applyModeChange() {
        switch mode {
        case .auto:
            startAutoMode()
        case .always:
            // 使用 Provider 的标准高度（缓存或预估）
            let height = KeyboardHeightProvider.shared.standardHeight
            updateHeight(height, animated: true)
        case .alwaysWithInitialHeight(let height):
            updateHeight(height, animated: true)
        }
    }

    private func startAutoMode() {
        // 清理之前的订阅（除了通知监听）
        // 重新订阅 RxKeyboard,每次订阅会发送以前最后一次的
        keyboardDisposable?.dispose()
        keyboardDisposable = RxKeyboard.instance.visibleHeight
            .throttle(.milliseconds(50), latest: true, scheduler: MainScheduler.instance) // 限制更新频率
            .drive(onNext: { [weak self] height in
                guard let self = self else { return }
                self.lastKeyboardHeight = height
                self.updateHeight(height, animated: true)
            })
    }

    // MARK: - Height Update

    private func updateHeight(_ height: CGFloat, animated: Bool) {
        guard abs(currentHeight - height) > 0.5 else { return }

        currentHeight = height
        heightConstraint?.update(offset: height)

        if animated {
            UIView.animate(
                withDuration: animationDuration,
                delay: 0,
                options: [.beginFromCurrentState, animationOptions],
                animations: { [weak self] in
                    self?.superview?.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            superview?.layoutIfNeeded()
        }

        onHeightChanged?(height)
    }

    // MARK: - Content View

    public func bindContentView(_ view: UIView) {
        contentView?.removeFromSuperview()
        contentView = view
        addSubview(view)
        view.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    public var onHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Factory

    @discardableResult
    static func create(
        in parent: UIView,
        mode: DisplayMode = .auto,
        contentView: UIView? = nil
    ) -> KeyboardPanelContainer {
        let container = KeyboardPanelContainer(mode: mode)
        parent.addSubview(container)
        container.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
        }
        if let contentView = contentView {
            container.bindContentView(contentView)
        }
        return container
    }
}

#endif
