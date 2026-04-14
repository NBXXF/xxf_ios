//
//  KeyboardPanelContainer.swift
//  XXFKeyboard
//
//  Created on 2022-04-11.
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
/// - **防跳动**: 从 always 切换到 auto 时，使用 `.skip(1)` 跳过 RxKeyboard 的过期首值
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
            applyModeChange(from: oldValue)
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

    // 布局状态
    private var isInitialLayoutDone = false
    private var lastKeyboardHeight: CGFloat = 0

    // Rx 订阅
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

    override open func didMoveToSuperview() {
        super.didMoveToSuperview()

        if superview != nil && heightConstraint == nil {
            self.snp.makeConstraints { make in
                heightConstraint = make.height.equalTo(0).constraint
            }
        }
    }

    override open func layoutSubviews() {
        super.layoutSubviews()

        if !isInitialLayoutDone {
            isInitialLayoutDone = true
            applyModeChange(from: mode)
        }
    }

    // MARK: - Setup

    private func setupKeyboardObserver() {
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

    private func applyModeChange(from oldMode: DisplayMode) {
        switch mode {
        case .auto:
            // 关键修复：如果从 always 切换到 auto，使用 skip(1) 跳过 RxKeyboard 的首个过期值
            // 因为此时 becomeFirstResponder() 可能已经触发，但 RxKeyboard 的 BehaviorRelay
            // 会立即同步发送 lastValue（可能是键盘收起状态的 0），导致跳动
            let fromAlways = (oldMode == .always)
            startAutoMode(skipFirstValue: fromAlways)
        case .always:
            keyboardDisposable?.dispose()
            keyboardDisposable = nil
            let height = KeyboardHeightProvider.shared.standardHeight
            updateHeight(height, animated: true)
        case .alwaysWithInitialHeight(let height):
            keyboardDisposable?.dispose()
            keyboardDisposable = nil
            updateHeight(height, animated: true)
        }
    }

    /// 启动 Auto 模式
    /// - Parameter skipFirstValue: 是否跳过第一个值（用于解决 always→auto 切换时的跳动问题）
    private func startAutoMode(skipFirstValue: Bool) {
        keyboardDisposable?.dispose()

        // 使用 Driver 保证在主线程且共享
        let driver = RxKeyboard.instance.visibleHeight

        // 如果需要跳过首值（从 always 切换），转换为 Observable 使用 skip(1) 再转回
        let finalDriver: Driver<CGFloat>
        if skipFirstValue {
            finalDriver = driver.asObservable()
                .skip(1)  // 跳过 BehaviorRelay 的 lastValue（过期值）
                .asDriver(onErrorJustReturn: 0)
        } else {
            finalDriver = driver
        }

        keyboardDisposable = finalDriver
            .throttle(.milliseconds(50), latest: true)
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

    deinit {
        keyboardDisposable?.dispose()
    }

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
