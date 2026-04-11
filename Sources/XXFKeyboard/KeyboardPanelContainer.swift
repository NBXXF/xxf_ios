//
//  KeyboardPanelContainer.swift
//  XXFKeyboard
//
//  Created on 2026-04-11.
//

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa
import RxKeyboard
import SnapKit

/// KeyboardPanelContainer - 键盘面板容器
///
/// 容器高度与键盘高度保持同步，适用于表情面板、功能面板、底部工具栏等场景。
///
/// ## 与 KeyboardResizeContainer 的区别
///
/// | 特性               | KeyboardResizeContainer | KeyboardPanelContainer |
/// |---------------- |-------------------------------|------------------------|
/// | 高度计算        | 父视图高度 - 键盘高度       | 等于键盘高度          |
/// | 用途               | 内容区域上移                     | 面板与键盘同高       |
/// | 键盘收起时    | 占满全屏                             | 高度为 0                  |
///
/// ## 显示模式
///
/// ### `.auto` - 自动适配（默认）
/// 键盘收起时高度为 0，弹出时等于键盘高度。
/// 适用于表情面板、功能面板等需要跟随键盘显示/隐藏的场景。
///
/// ```swift
/// let emojiPanel = KeyboardPanelContainer(mode: .auto)
/// // 键盘收起: height = 0
/// // 键盘弹出: height = 291pt (iPhone 14)
/// ```
///
/// ### `.always` - 总是显示
/// 始终占用键盘高度，即使键盘未弹出。
/// 首次显示时使用 `KeyboardHeightProvider` 缓存的高度或预估值。
/// 适用于需要在键盘区域预占位的场景。
///
/// ```swift
/// let toolbar = KeyboardPanelContainer(mode: .always)
/// // 首次显示: height = 预估值 291pt
/// // 键盘弹出后: height = 真实高度 291pt
/// ```
///
/// ### `.alwaysWithInitialHeight(CGFloat)` - 总是显示（指定初始高度）
/// 始终显示指定高度，不受键盘影响。
/// 适用于需要自定义固定高度的场景。
///
/// ```swift
/// let customPanel = KeyboardPanelContainer(mode: .alwaysWithInitialHeight(200))
/// // 始终显示 200pt 高度
/// ```
///
/// ## 使用方式
///
/// ### 基础用法
///
/// ```swift
/// import XXFKeyboard
/// import SnapKit
///
/// class ChatViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 创建表情面板（自动模式）
///         let emojiPanel = KeyboardPanelContainer(mode: .auto)
///         view.addSubview(emojiPanel)
///         emojiPanel.snp.makeConstraints {
///             $0.leading.trailing.bottom.equalToSuperview()
///         }
///
///         // 添加表情网格
///         let collectionView = UICollectionView(...)
///         emojiPanel.bindContentView(collectionView)
///     }
/// }
/// ```
///
/// ### 动态切换模式
///
/// ```swift
/// let panel = KeyboardPanelContainer(mode: .auto)
///
/// // 切换到总是显示模式（键盘收起后仍保持高度）
/// panel.mode = .always
///
/// // 切换回自动模式
/// panel.mode = .auto
/// ```
///
/// ### 监听高度变化
///
/// ```swift
/// let panel = KeyboardPanelContainer(mode: .always)
/// panel.onHeightChanged = { height in
///     print("面板高度变化: \(height)")
/// }
/// ```
///
/// ## 注意事项
///
/// 1. **首次显示高度**: `.always` 模式下首次显示使用预估高度，键盘弹出后自动修正
/// 2. **iPad 浮动键盘**: 支持 iPad 浮动键盘，但建议对 iPad 使用 `.auto` 模式
/// 3. **屏幕旋转**: 旋转屏幕后高度会自动更新
/// 4. **动态模式切换**: 切换 `mode` 会立即触发高度更新
///
/// ## 启动配置
///
/// 建议在 App 启动时开启全局键盘高度监听：
///
/// ```swift
/// // AppDelegate.swift
/// func application(_ application: UIApplication,
///                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///     KeyboardHeightProvider.shared.startMonitoring()
///     return true
/// }
/// ```
///
@MainActor
open class KeyboardPanelContainer: UIView {

    // MARK: - Display Mode

    /// 显示模式
    public enum DisplayMode: Equatable {
        /// 自动适配：键盘收起时高度为 0，弹出时等于键盘高度
        ///
        /// 适用于表情面板、功能面板等跟随键盘显示/隐藏的场景。
        case auto

        /// 总是显示：始终占用键盘高度（使用缓存或预估高度）
        ///
        /// 首次显示时使用 `KeyboardHeightProvider.currentHeight`
        ///（缓存值或预估值），键盘弹出后自动更新为真实高度。
        case always

        /// 总是显示，使用指定初始高度
        ///
        /// - Parameter height: 固定的初始高度（pt）
        /// - Note: 指定高度后，键盘弹出不会更新容器高度
        case alwaysWithInitialHeight(CGFloat)

        /// 比较两个模式类型是否相同（忽略 associated value）
        public static func == (lhs: DisplayMode, rhs: DisplayMode) -> Bool {
            switch (lhs, rhs) {
            case (.auto, .auto),
                 (.always, .always),
                 (.alwaysWithInitialHeight, .alwaysWithInitialHeight):
                return true
            default:
                return false
            }
        }

        /// 是否为 always 类型（包括 `.always` 和 `.alwaysWithInitialHeight`）
        public var isAlwaysMode: Bool {
            switch self {
            case .always, .alwaysWithInitialHeight:
                return true
            default:
                return false
            }
        }
    }

    // MARK: - Properties

    /// 显示模式
    ///
    /// 支持动态修改，修改后会立即根据新模式调整高度。
    ///
    /// ```swift
    /// panel.mode = .always  // 立即切换到总是显示
    /// panel.mode = .auto    // 立即切换到自动适配
    /// ```
    public var mode: DisplayMode {
        didSet {
            guard mode != oldValue else { return }
            applyModeChange(from: oldValue, to: mode)
        }
    }

    /// 当前键盘高度
    ///
    /// 返回容器当前的显示高度，可能为 0（`.auto` 模式键盘收起时）。
    public private(set) var currentKeyboardHeight: CGFloat = 0

    /// 高度约束（SnapKit）
    private var heightConstraint: Constraint?

    /// 内容视图
    private weak var contentView: UIView?

    private let disposeBag = DisposeBag()

    /// 键盘动画配置
    private var keyboardAnimationDuration: TimeInterval = 0.25
    private var keyboardAnimationOptions: UIView.AnimationOptions = .curveEaseInOut

    /// 是否已完成初始布局
    private var isInitialLayoutDone = false

    /// 上次已知的键盘高度（用于跟踪键盘实际状态）
    /// - Note: 这个值反映键盘的实际显示高度，0 表示键盘收起
    private var lastKnownKeyboardHeight: CGFloat = 0

    // MARK: - Initialization

    /// 初始化
    ///
    /// - Parameter mode: 显示模式，默认 `.auto`
    ///
    /// ```swift
    /// // 自动模式
    /// let panel = KeyboardPanelContainer()
    ///
    /// // 总是显示模式
    /// let panel = KeyboardPanelContainer(mode: .always)
    ///
    /// // 指定固定高度
    /// let panel = KeyboardPanelContainer(mode: .alwaysWithInitialHeight(250))
    /// ```
    public init(mode: DisplayMode = .auto) {
        self.mode = mode
        super.init(frame: .zero)
        setupKeyboardBindings()
    }

    public required init?(coder: NSCoder) {
        self.mode = .auto
        super.init(coder: coder)
        setupKeyboardBindings()
    }

    // MARK: - Layout

    override open func layoutSubviews() {
        super.layoutSubviews()

        // 首次布局时应用初始高度
        // 延迟到 layoutSubviews 确保已有 window 和父视图
        if !isInitialLayoutDone {
            isInitialLayoutDone = true
            setupInitialHeight()
        }
    }

    // MARK: - Setup

    /// 设置初始高度
    ///
    /// 根据当前 `mode` 计算并应用初始高度：
    /// - `.auto`: 0
    /// - `.always`: `KeyboardHeightProvider.currentHeight`
    /// - `.alwaysWithInitialHeight`: 指定值
    private func setupInitialHeight() {
        let initialHeight: CGFloat

        switch mode {
        case .auto:
            initialHeight = 0
        case .always:
            initialHeight = KeyboardHeightProvider.shared.currentHeight
        case .alwaysWithInitialHeight(let height):
            initialHeight = height
        }

        currentKeyboardHeight = initialHeight

        // 添加高度约束（如果还没有）
        if heightConstraint == nil {
            self.snp.makeConstraints { make in
                self.heightConstraint = make.height.equalTo(initialHeight).constraint
            }
        } else {
            heightConstraint?.update(offset: initialHeight)
        }

        setNeedsLayout()
        layoutIfNeeded()
    }

    /// 应用模式切换
    ///
    /// 当 `mode` 属性被修改时调用，立即根据新模式调整高度。
    /// 考虑键盘实际状态，确保切换后高度与预期一致。
    private func applyModeChange(from oldMode: DisplayMode, to newMode: DisplayMode) {
        switch newMode {
        case .auto:
            // 切换到自动模式：根据键盘实际状态设置高度
            // 如果键盘当前显示（lastKnownKeyboardHeight > 0），使用实际高度
            // 如果键盘当前收起（lastKnownKeyboardHeight = 0），高度为 0
            let targetHeight = lastKnownKeyboardHeight
            updateHeight(targetHeight, animated: true)

        case .always:
            // 切换到总是显示：使用 Provider 的高度（内存 → 持久化 → 预估）
            // 如果键盘当前显示，优先使用实际高度；否则使用缓存/预估高度
            let targetHeight = lastKnownKeyboardHeight > 0
                ? lastKnownKeyboardHeight
                : KeyboardHeightProvider.shared.currentHeight
            updateHeight(targetHeight, animated: true)

        case .alwaysWithInitialHeight(let height):
            // 切换到指定高度：直接使用指定值
            updateHeight(height, animated: true)
        }
    }

    /// 设置键盘监听
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
    }

    /// 从键盘通知提取动画参数
    private func extractAnimationParams(from notification: Notification) {
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0.25
        let rawCurve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
        keyboardAnimationDuration = duration
        keyboardAnimationOptions = UIView.AnimationOptions(rawValue: rawCurve << 16)
    }

    /// 处理键盘 frame 变化
    private func handleKeyboardFrameChange(_ frame: CGRect) {
        let keyboardHeight = calculateKeyboardHeight(from: frame)

        // 记录实际键盘高度（用于模式切换时判断键盘状态）
        lastKnownKeyboardHeight = keyboardHeight

        switch mode {
        case .auto:
            // 自动模式：总是跟随键盘高度
            // 键盘显示时 height = 键盘高度，键盘收起时 height = 0
            updateHeight(keyboardHeight, animated: true)

        case .always, .alwaysWithInitialHeight:
            // 总是显示模式：只在键盘弹出时更新（避免收起时变为 0）
            if keyboardHeight > 0 {
                updateHeight(keyboardHeight, animated: true)
            }
        }
    }

    /// 计算键盘高度（兼容 iPad 浮动键盘和分屏）
    ///
    /// - Parameter frame: 键盘 frame
    /// - Returns: 计算后的键盘高度
    private func calculateKeyboardHeight(from frame: CGRect) -> CGFloat {
        guard let window = self.window ?? UIApplication.shared.keyWindow else {
            let screenHeight = UIScreen.main.bounds.height
            return max(0, screenHeight - frame.origin.y)
        }

        let windowHeight = window.bounds.height
        let keyboardOriginY = frame.origin.y
        let keyboardHeight = max(0, windowHeight - keyboardOriginY)

        return keyboardHeight
    }

    /// 更新容器高度
    ///
    /// - Parameters:
    ///   - height: 新高度
    ///   - animated: 是否带动画
    private func updateHeight(_ height: CGFloat, animated: Bool) {
        // 忽略微小变化（< 0.5pt），避免不必要的布局
        guard abs(currentKeyboardHeight - height) > 0.5 else { return }

        currentKeyboardHeight = height
        heightConstraint?.update(offset: height)

        if animated {
            UIView.animate(
                withDuration: keyboardAnimationDuration,
                delay: 0,
                options: [.beginFromCurrentState, keyboardAnimationOptions],
                animations: { [weak self] in
                    self?.superview?.layoutIfNeeded()
                    self?.layoutIfNeeded()
                },
                completion: nil
            )
        } else {
            self.superview?.layoutIfNeeded()
            self.layoutIfNeeded()
        }

        // 触发回调
        onHeightChanged?(height)
    }

    // MARK: - Content View

    /// 绑定内容视图
    ///
    /// 内容视图将填满整个容器，自动跟随容器高度变化。
    /// 绑定新视图会自动移除旧视图。
    ///
    /// - Parameter view: 内容视图
    public func bindContentView(_ view: UIView) {
        contentView?.removeFromSuperview()
        contentView = view

        addSubview(view)
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    /// 高度变化回调
    ///
    /// 容器高度发生变化时触发，可用于同步更新其他 UI。
    ///
    /// ```swift
    /// panel.onHeightChanged = { height in
    ///     print("面板高度: \(height)")
    /// }
    /// ```
    public var onHeightChanged: ((CGFloat) -> Void)?

    // MARK: - Public Methods

    /// 手动更新高度
    ///
    /// 用于自定义场景下强制设置容器高度，不受 `mode` 限制。
    ///
    /// - Parameters:
    ///   - height: 新高度
    ///   - animated: 是否带动画
    public func setHeight(_ height: CGFloat, animated: Bool = true) {
        updateHeight(height, animated: animated)
    }

    /// 获取当前显示高度
    ///
    /// - Returns: 当前容器高度（pt）
    public var displayedHeight: CGFloat {
        return currentKeyboardHeight
    }

    /// 同步当前键盘高度
    ///
    /// 从 `KeyboardHeightProvider` 刷新为最新缓存高度。
    /// 适用于 `.always` 模式下想要立即更新为最新高度。
    ///
    /// - Parameter animated: 是否带动画
    public func syncKeyboardHeight(animated: Bool = true) {
        let height = KeyboardHeightProvider.shared.currentHeight
        updateHeight(height, animated: animated)
    }
}

// MARK: - Factory Methods

extension KeyboardPanelContainer {

    /// 便捷创建方法
    ///
    /// 快速创建并添加到父视图，自动设置约束。
    ///
    /// - Parameters:
    ///   - parent: 父视图
    ///   - mode: 显示模式，默认 `.auto`
    ///   - contentView: 内容视图（可选）
    /// - Returns: 创建的 `KeyboardPanelContainer` 实例
    ///
    /// ```swift
    /// let panel = KeyboardPanelContainer.create(
    ///     in: view,
    ///     mode: .always,
    ///     contentView: emojiGrid
    /// )
    /// ```
    @discardableResult
    static func create(
        in parent: UIView,
        mode: DisplayMode = .auto,
        contentView: UIView? = nil
    ) -> KeyboardPanelContainer {
        let container = KeyboardPanelContainer(mode: mode)
        parent.addSubview(container)

        container.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        if let contentView = contentView {
            container.bindContentView(contentView)
        }

        return container
    }
}

#endif
