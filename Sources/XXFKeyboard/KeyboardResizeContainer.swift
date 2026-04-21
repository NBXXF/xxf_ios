//
//  KeyboardResizeContainer.swift
//  XXFKeyboard
//
//  Created on 2022-03-18.
//

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import SnapKit

/// KeyboardResizeContainer - 类似 Android 的 adjustPan 模式
/// 容器高度会自动减去键盘高度，子 view 可以动态适配键盘
///
/// 特性：
/// - 自动监听键盘显示/隐藏
/// - 同步键盘动画曲线和时长
/// - 支持作为 ViewController 的根视图
/// - 使用约束自动管理高度
///
/// 使用方式：
/// 1. 将 KeyboardResizeContainer 作为主容器 view
/// 2. 向 container 中添加子 view（contentView）
/// 3. 当键盘弹出时，container 高度会自动减少，contentView 会自动调整
///
/// 示例：
/// ```swift
/// let container = KeyboardResizeContainer()
/// view.addSubview(container)
/// container.snp.makeConstraints {
///     $0.edges.equalTo(view.safeAreaLayoutGuide)
/// }
///
/// let contentView = UIView()
/// container.addSubview(contentView)
/// container.bindContentView(contentView)
/// ```
open class KeyboardResizeContainer: UIView {

    // MARK: - Properties

    internal let disposeBag = DisposeBag()

    /// 键盘可见高度（Driver）
    public let keyboardVisibleHeight: Driver<CGFloat>

    /// 键盘 frame（Driver）
    public let keyboardFrame: Driver<CGRect>

    /// 当前键盘高度
    public private(set) var currentKeyboardHeight: CGFloat = 0

    /// 内容视图
    internal weak var contentView: UIView?

    /// 底部约束引用 - 使用 NSLayoutConstraint 而非 SnapKit Constraint
    private var bottomLayoutConstraint: NSLayoutConstraint?

    /// 键盘动画配置
    private var keyboardAnimationDuration: TimeInterval = 0.25
    private var keyboardAnimationOptions: UIView.AnimationOptions = .curveEaseInOut

    // MARK: - Initialization

    public override init(frame: CGRect) {
        self.keyboardVisibleHeight = RxKeyboard.instance.visibleHeight
        self.keyboardFrame = RxKeyboard.instance.frame
        super.init(frame: frame)
        setupKeyboardBindings()
    }

    public required init?(coder: NSCoder) {
        self.keyboardVisibleHeight = RxKeyboard.instance.visibleHeight
        self.keyboardFrame = RxKeyboard.instance.frame
        super.init(coder: coder)
        setupKeyboardBindings()
    }

    // MARK: - Setup

    private func setupKeyboardBindings() {
        // 监听键盘 frame 变化
        RxKeyboard.instance.frame
            .drive(onNext: { [weak self] frame in
                self?.handleKeyboardFrameChange(frame)
            })
            .disposed(by: disposeBag)

        // 监听键盘通知获取动画参数
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillChangeFrameNotification)
            .subscribe(onNext: { [weak self] notification in
                self?.extractAnimationParams(from: notification)
            })
            .disposed(by: disposeBag)

        // 同步更新 keyboardVisibleHeight
        keyboardVisibleHeight
            .drive(onNext: { [weak self] height in
                self?.currentKeyboardHeight = height
            })
            .disposed(by: disposeBag)
    }

    private func extractAnimationParams(from notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let rawCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        keyboardAnimationDuration = duration
        keyboardAnimationOptions = UIView.AnimationOptions(rawValue: rawCurve << 16)
    }

    private func handleKeyboardFrameChange(_ frame: CGRect) {
        guard let window = self.window else { return }

        // 计算键盘高度
        let keyboardHeight = max(0, window.bounds.height - frame.origin.y)
        currentKeyboardHeight = keyboardHeight

        // 兜底:首个键盘事件到达时若约束尚未追踪到(runloop 时序),现场补一次
        if bottomLayoutConstraint == nil {
            findAndTrackBottomConstraint()
        }

        // 更新底部约束
        updateBottomConstraint(keyboardHeight: keyboardHeight)
    }

    private func updateBottomConstraint(keyboardHeight: CGFloat) {
        // 更新底部约束的 constant
        bottomLayoutConstraint?.constant = -keyboardHeight

        // 使用键盘动画执行布局更新
        UIView.animate(
            withDuration: keyboardAnimationDuration,
            delay: 0,
            options: [.beginFromCurrentState, keyboardAnimationOptions],
            animations: { [weak self] in
                self?.superview?.layoutIfNeeded()
            },
            completion: nil
        )
    }

    // MARK: - Content View Binding

    /// 绑定内容视图，内容视图将填满整个容器
    /// - Parameter view: 要绑定的内容视图
    public func bindContentView(_ view: UIView) {
        contentView = view
        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 绑定内容视图并指定约束
    /// - Parameters:
    ///   - view: 内容视图
    ///   - constraints: 约束闭包
    public func bindContentView(_ view: UIView, constraints: (ConstraintMaker) -> Void) {
        contentView = view
        addSubview(view)
        view.snp.makeConstraints(constraints)
    }

    // MARK: - Constraint Tracking

    /// 监听约束变化，自动追踪底部约束
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        // 脱离父视图时清空追踪,避免持有旧 constraint 引用
        guard superview != nil else {
            bottomLayoutConstraint = nil
            return
        }
        // 下一 runloop 扫描:保证调用方 `makeConstraints` 已执行完毕
        // (didMoveToSuperview 是在 addSubview 同步触发,此时 SnapKit 约束还没写入)
        DispatchQueue.main.async { [weak self] in
            self?.findAndTrackBottomConstraint()
        }
    }

    private func findAndTrackBottomConstraint() {
        // 遍历父视图的所有约束，找到连接 self.bottom 的约束
        guard let superview = self.superview else { return }

        for constraint in superview.constraints {
            if isBottomConstraint(constraint) {
                bottomLayoutConstraint = constraint
                return
            }
        }
    }

    private func isBottomConstraint(_ constraint: NSLayoutConstraint) -> Bool {
        // 检查是否是底部约束
        let hasSelfAsFirstItem = (constraint.firstItem as? NSObject) === self
        let hasBottomAttribute = constraint.firstAttribute == .bottom

        // 检查 secondItem 不是 self（避免自引用）
        let secondItemIsSuperview = (constraint.secondItem as? NSObject) === self.superview
        let secondItemIsParent = constraint.secondAttribute == .bottom

        return hasSelfAsFirstItem && hasBottomAttribute && (secondItemIsSuperview || secondItemIsParent)
    }
}

// MARK: - Helper Extension

public extension KeyboardResizeContainer {

    /// 便捷方法：创建并配置容器
    /// - Parameters:
    ///   - parent: 父视图
    ///   - contentView: 内容视图
    ///   - edges: 边缘约束（默认安全区域）
    /// - Returns: 创建的 KeyboardResizeContainer 实例
    static func create(
        in parent: UIView,
        contentView: UIView,
        edges: NSDirectionalEdgeInsets = .zero
    ) -> KeyboardResizeContainer {
        let container = KeyboardResizeContainer()
        parent.addSubview(container)

        container.snp.makeConstraints { make in
            make.top.equalTo(parent.safeAreaLayoutGuide.snp.top).offset(edges.top)
            make.leading.equalTo(parent.safeAreaLayoutGuide.snp.leading).offset(edges.leading)
            make.trailing.equalTo(parent.safeAreaLayoutGuide.snp.trailing).offset(-edges.trailing)
            make.bottom.equalTo(parent.safeAreaLayoutGuide.snp.bottom).offset(-edges.bottom)
        }

        container.bindContentView(contentView)

        return container
    }
}

#endif
