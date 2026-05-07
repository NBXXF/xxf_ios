//
//  UIControlButton.swift
//  xxf_ios
//
//  基于 UIControl 实现的高性能自定义按钮
//  特性：
//  - 完整支持 UIControl State 状态管理（Normal/Highlighted/Disabled/Selected/Focused）
//  - 支持图片在文字上/下/左/右四个位置（参考 Android Button）
//  - 支持水平/垂直方向的内容对齐
//  - 支持 AttributedString、背景图片
//  - 内置加载指示器
//  - 完整的 Target-Action 事件支持
//  - Interface Builder 实时预览支持
//
//  Created by xxf on 4/9.
//
#if canImport(UIKit)
import UIKit

// MARK: - UIControlButton

/// 继承自 UIControl 的自定义按钮，API 设计参考 UIButton
///
/// ## 核心特性
/// - 状态驱动：title、image、backgroundImage、titleColor 均支持按 UIControl.State 设置
/// - 灵活布局：图片可在文字上下左右四个位置，支持间距调整
/// - 对齐方式：支持水平和垂直方向的内容对齐
/// - 加载状态：内置 activityIndicator，显示时自动隐藏内容
/// - 完整事件：支持 UIControl 的所有事件（touchUpInside、touchDown 等）
///
/// ## 使用示例
/// ```swift
/// let button = UIControlButton()
/// button.setTitle("点击", for: .normal)
/// button.setTitle("高亮", for: .highlighted)
/// button.setImage(UIImage(named: "icon"), for: .normal)
/// button.imagePlacement = .leading
/// button.imagePadding = 8
/// button.contentInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
/// button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
/// ```
@IBDesignable
open class UIControlButton: UIControl {

    // MARK: - 子视图

    /// 标题标签，可直接访问进行高级自定义
    /// - Warning: 修改 text 或 attributedText 会被 setTitle/setAttributedTitle 覆盖
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    /// 图片视图，可直接访问进行高级自定义
    /// - Warning: 修改 image 会被 setImage 覆盖
    public let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// 背景图片视图（置于最底层）
    public let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()

    /// 内容容器，包含 titleLabel 和 imageView
    /// - Note: 使用 UIStackView 简化图文布局
    public let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 8
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    /// 内容包装器，用于处理 contentInsets
    private let contentWrapperView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// 加载指示器
    public let activityIndicator: UIActivityIndicatorView = {
        let indicator: UIActivityIndicatorView
        if #available(iOS 13.0, *) {
            indicator = UIActivityIndicatorView(style: .medium)
        } else {
            indicator = UIActivityIndicatorView(style: .gray)
        }
        indicator.hidesWhenStopped = true
        indicator.isUserInteractionEnabled = false
        indicator.translatesAutoresizingMaskIntoConstraints = false
        return indicator
    }()

    // MARK: - 外观属性（@IBInspectable）

    /// 图片位置，默认为 leading（左侧，RTL 环境为右侧）
    /// - Note: 修改此属性会立即更新布局
    public var imagePlacement: NSDirectionalRectEdge = .leading {
        didSet {
            guard imagePlacement != oldValue else { return }
            updateLayoutForImagePlacement()
        }
    }

    /// 水平方向内容对齐方式，默认为居中
    /// - Note: 复写 UIControl.contentHorizontalAlignment，自定义布局行为
    override open var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment {
        get { super.contentHorizontalAlignment }
        set {
            guard contentHorizontalAlignment != newValue else { return }
            super.contentHorizontalAlignment = newValue
            updateContentAlignment()
        }
    }

    /// 垂直方向内容对齐方式，默认为居中
    /// - Note: 复写 UIControl.contentVerticalAlignment，自定义布局行为
    override open var contentVerticalAlignment: UIControl.ContentVerticalAlignment {
        get { super.contentVerticalAlignment }
        set {
            guard contentVerticalAlignment != newValue else { return }
            super.contentVerticalAlignment = newValue
            updateContentAlignment()
        }
    }

    /// 图片和文字之间的间距，默认为 8
    @IBInspectable
    public var imagePadding: CGFloat = 8 {
        didSet {
            guard imagePadding != oldValue else { return }
            contentStackView.spacing = imagePadding
        }
    }

    /// 是否显示加载指示器
    /// - Note: 对齐官方 UIButton.Configuration.showsActivityIndicator 行为：
    ///   - indicator 替换 imageView 位置，跟随 imagePlacement（leading/trailing/top/bottom）
    ///   - titleLabel 保持可见
    ///   - 不会自动修改 isUserInteractionEnabled，是否可点由调用方通过 isEnabled 控制
    @IBInspectable
    public var showsActivityIndicator: Bool = false {
        didSet {
            guard showsActivityIndicator != oldValue else { return }
            updateActivityIndicatorState()
        }
    }

    /// 加载指示器颜色
    public var activityIndicatorColor: UIColor? {
        didSet {
            activityIndicator.color = activityIndicatorColor
        }
    }

    /// 内容边距，默认为 (8, 16, 8, 16)
    /// - Note: 控制内容与按钮边界的距离
    public var contentInsets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16) {
        didSet {
            guard !contentInsetsEqual(contentInsets, oldValue) else { return }
            updateContentInsets()
        }
    }

    /// 图片尺寸限制，nil 表示使用图片原始尺寸
    /// - Note: 设置后会同时约束 width 和 height
    public var imageSize: CGSize? {
        didSet {
            guard imageSize != oldValue else { return }
            updateImageSizeConstraints()
        }
    }

    /// 高亮时的缩放比例，默认为 0.97
    /// - Note: 设置为 1.0 可禁用缩放动画
    public var highlightScale: CGFloat = 0.97

    /// 高亮时的透明度，默认为 0.8
    /// - Note: 设置为 1.0 可禁用透明度变化
    public var highlightAlpha: CGFloat = 0.8

    /// 禁用时的透明度，默认为 0.5
    public var disabledAlpha: CGFloat = 0.5

    /// 动画持续时间，默认为 0.1 秒
    public var animationDuration: TimeInterval = 0.1

    /// 触控热区向外扩展的 insets，默认 .zero
    /// - Note: 只影响命中测试，不改变视觉布局与 `contentInsets`
    ///   - 正值 = 向外扩展（热区比视觉大）
    ///   - 典型用途：小图标按钮（视觉 <44pt）扩到 HIG 推荐的最小触控尺寸
    public var hitTestEdgeInsets: UIEdgeInsets = .zero

    // MARK: - 私有属性

    /// 各状态对应的标题存储
    private var titleStorage: [UInt: String] = [:]

    /// 各状态对应的富文本标题存储
    private var attributedTitleStorage: [UInt: NSAttributedString] = [:]

    /// 各状态对应的图片存储
    private var imageStorage: [UInt: UIImage] = [:]

    /// 各状态对应的背景图片存储
    private var backgroundImageStorage: [UInt: UIImage] = [:]

    /// 各状态对应的标题颜色存储
    private var titleColorStorage: [UInt: UIColor] = [:]

    /// 图片尺寸约束
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageHeightConstraint: NSLayoutConstraint?

    /// 内容包装器约束
    private var wrapperLeadingConstraint: NSLayoutConstraint?
    private var wrapperTrailingConstraint: NSLayoutConstraint?
    private var wrapperTopConstraint: NSLayoutConstraint?
    private var wrapperBottomConstraint: NSLayoutConstraint?
    private var wrapperCenterXConstraint: NSLayoutConstraint?
    private var wrapperCenterYConstraint: NSLayoutConstraint?

    /// 标志位：是否已初始化
    private var isInitialized: Bool = false

    // MARK: - 初始化

    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        // 避免重复初始化
        guard !isInitialized else { return }
        isInitialized = true

        setupViewHierarchy()
        setupConstraints()
        setupDefaultValues()
        updateLayoutForImagePlacement()
        updateContentAlignment()
    }

    // MARK: - 视图层级设置

    private func setupViewHierarchy() {
        // 添加背景图片视图（最底层）
        insertSubview(backgroundImageView, at: 0)

        // 添加内容包装器
        addSubview(contentWrapperView)
        contentWrapperView.addSubview(contentStackView)

        // activityIndicator 按需插入 contentStackView 中（对齐官方行为：替换 imageView 位置）
    }

    private func setupConstraints() {
        // 背景图片约束（填满整个按钮）
        NSLayoutConstraint.activate([
            backgroundImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        // 内容包装器约束（初始状态，会被 updateContentAlignment 更新）
        wrapperCenterXConstraint = contentWrapperView.centerXAnchor.constraint(equalTo: centerXAnchor)
        wrapperCenterYConstraint = contentWrapperView.centerYAnchor.constraint(equalTo: centerYAnchor)

        wrapperLeadingConstraint = contentWrapperView.leadingAnchor.constraint(
            greaterThanOrEqualTo: leadingAnchor, constant: contentInsets.left)
        wrapperTrailingConstraint = contentWrapperView.trailingAnchor.constraint(
            lessThanOrEqualTo: trailingAnchor, constant: -contentInsets.right)
        wrapperTopConstraint = contentWrapperView.topAnchor.constraint(
            greaterThanOrEqualTo: topAnchor, constant: contentInsets.top)
        wrapperBottomConstraint = contentWrapperView.bottomAnchor.constraint(
            lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom)

        NSLayoutConstraint.activate([
            wrapperCenterXConstraint!,
            wrapperCenterYConstraint!,
            wrapperLeadingConstraint!,
            wrapperTrailingConstraint!,
            wrapperTopConstraint!,
            wrapperBottomConstraint!
        ])

        // 内容 StackView 在包装器内居中
        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: contentWrapperView.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: contentWrapperView.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: contentWrapperView.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: contentWrapperView.bottomAnchor)
        ])
    }

    private func setupDefaultValues() {
        // 默认标题样式（与 UIButton 一致，透明背景）
        titleLabel.textColor = .systemBlue
        titleLabel.font = .systemFont(ofSize: 16)

        // 默认状态
        updateCurrentState()
    }

    // MARK: - 状态管理 API

    /// 设置指定状态的标题
    /// - Parameters:
    ///   - title: 标题文本，nil 表示清除
    ///   - state: 目标状态
    /// - Note: 支持组合状态，但为简化使用，存储时会归一化为单一状态（按优先级取最高位）
    open func setTitle(_ title: String?, for state: UIControl.State) {
        // 归一化状态：如果是组合状态，按优先级取一个（disabled > selected > highlighted > focused > normal）
        let normalizedState = Self.normalizeState(state)
        titleStorage[normalizedState.rawValue] = title

        // 如果当前状态包含该状态，立即更新
        if self.state.contains(normalizedState) || normalizedState == .normal {
            updateCurrentState()
        }
    }

    /// 获取指定状态的标题
    /// - Note: 支持组合状态回退，优先级：精确匹配 > disabled > selected > highlighted > focused > normal
    open func title(for state: UIControl.State) -> String? {
        // 1. 优先精确匹配
        if let title = titleStorage[state.rawValue] {
            return title
        }

        // 2. 按优先级尝试各个状态位
        let priorityStates: [UIControl.State] = [.disabled, .selected, .highlighted, .focused]
        for priorityState in priorityStates {
            if state.contains(priorityState), let title = titleStorage[priorityState.rawValue] {
                return title
            }
        }

        // 3. 最终回退到 normal
        return titleStorage[UIControl.State.normal.rawValue]
    }

    /// 设置指定状态的富文本标题
    /// - Parameters:
    ///   - title: 富文本标题，nil 表示清除
    ///   - state: 目标状态
    /// - Note: 富文本标题优先级高于普通标题
    open func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        let normalizedState = Self.normalizeState(state)
        attributedTitleStorage[normalizedState.rawValue] = title?.copy() as? NSAttributedString

        if self.state.contains(normalizedState) || normalizedState == .normal {
            updateCurrentState()
        }
    }

    /// 获取指定状态的富文本标题
    /// - Note: 支持组合状态回退，优先级与 title(for:) 一致
    open func attributedTitle(for state: UIControl.State) -> NSAttributedString? {
        // 1. 优先精确匹配
        if let title = attributedTitleStorage[state.rawValue] {
            return title
        }

        // 2. 按优先级尝试各个状态位
        let priorityStates: [UIControl.State] = [.disabled, .selected, .highlighted, .focused]
        for priorityState in priorityStates {
            if state.contains(priorityState), let title = attributedTitleStorage[priorityState.rawValue] {
                return title
            }
        }

        // 3. 最终回退到 normal
        return attributedTitleStorage[UIControl.State.normal.rawValue]
    }

    /// 设置指定状态的图片
    /// - Parameters:
    ///   - image: 图片，nil 表示清除
    ///   - state: 目标状态
    open func setImage(_ image: UIImage?, for state: UIControl.State) {
        let normalizedState = Self.normalizeState(state)
        imageStorage[normalizedState.rawValue] = image

        if self.state.contains(normalizedState) || normalizedState == .normal {
            updateCurrentState()
        }
    }

    /// 获取指定状态的图片
    /// - Note: 支持组合状态回退，优先级与 title(for:) 一致
    open func image(for state: UIControl.State) -> UIImage? {
        // 1. 优先精确匹配
        if let image = imageStorage[state.rawValue] {
            return image
        }

        // 2. 按优先级尝试各个状态位
        let priorityStates: [UIControl.State] = [.disabled, .selected, .highlighted, .focused]
        for priorityState in priorityStates {
            if state.contains(priorityState), let image = imageStorage[priorityState.rawValue] {
                return image
            }
        }

        // 3. 最终回退到 normal
        return imageStorage[UIControl.State.normal.rawValue]
    }

    /// 设置指定状态的背景图片
    /// - Parameters:
    ///   - image: 背景图片，nil 表示清除
    ///   - state: 目标状态
    open func setBackgroundImage(_ image: UIImage?, for state: UIControl.State) {
        let normalizedState = Self.normalizeState(state)
        backgroundImageStorage[normalizedState.rawValue] = image

        if self.state.contains(normalizedState) || normalizedState == .normal {
            updateCurrentState()
        }
    }

    /// 获取指定状态的背景图片
    /// - Note: 支持组合状态回退，优先级与 title(for:) 一致
    open func backgroundImage(for state: UIControl.State) -> UIImage? {
        // 1. 优先精确匹配
        if let image = backgroundImageStorage[state.rawValue] {
            return image
        }

        // 2. 按优先级尝试各个状态位
        let priorityStates: [UIControl.State] = [.disabled, .selected, .highlighted, .focused]
        for priorityState in priorityStates {
            if state.contains(priorityState), let image = backgroundImageStorage[priorityState.rawValue] {
                return image
            }
        }

        // 3. 最终回退到 normal
        return backgroundImageStorage[UIControl.State.normal.rawValue]
    }

    /// 设置指定状态的标题颜色
    /// - Parameters:
    ///   - color: 颜色，nil 表示清除
    ///   - state: 目标状态
    open func setTitleColor(_ color: UIColor?, for state: UIControl.State) {
        let normalizedState = Self.normalizeState(state)
        titleColorStorage[normalizedState.rawValue] = color

        if self.state.contains(normalizedState) || normalizedState == .normal {
            updateCurrentState()
        }
    }

    /// 获取指定状态的标题颜色
    /// - Note: 支持组合状态回退，优先级与 title(for:) 一致
    open func titleColor(for state: UIControl.State) -> UIColor? {
        // 1. 优先精确匹配
        if let color = titleColorStorage[state.rawValue] {
            return color
        }

        // 2. 按优先级尝试各个状态位
        let priorityStates: [UIControl.State] = [.disabled, .selected, .highlighted, .focused]
        for priorityState in priorityStates {
            if state.contains(priorityState), let color = titleColorStorage[priorityState.rawValue] {
                return color
            }
        }

        // 3. 最终回退到 normal
        return titleColorStorage[UIControl.State.normal.rawValue]
    }

    // MARK: - 便捷属性（默认操作 normal 状态）

    /// 当前标题（normal 状态）
    @IBInspectable
    public var title: String? {
        get { title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }

    /// 当前图片（normal 状态）
    @IBInspectable
    public var image: UIImage? {
        get { image(for: .normal) }
        set { setImage(newValue, for: .normal) }
    }

    /// 当前背景图片（normal 状态）
    @IBInspectable
    public var backgroundImage: UIImage? {
        get { backgroundImage(for: .normal) }
        set { setBackgroundImage(newValue, for: .normal) }
    }

    /// 当前标题颜色（normal 状态）
    @IBInspectable
    public var titleColor: UIColor? {
        get { titleColor(for: .normal) ?? titleLabel.textColor }
        set { setTitleColor(newValue, for: .normal) }
    }

    /// 标题字体
    public var titleFont: UIFont? {
        get { titleLabel.font }
        set { titleLabel.font = newValue }
    }

    // MARK: - 布局更新

    /// 根据图片位置更新布局
    private func updateLayoutForImagePlacement() {
        // 移除现有子视图
        contentStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 根据位置设置轴方向和子视图顺序
        switch imagePlacement {
        case .leading:
            contentStackView.axis = .horizontal
            contentStackView.addArrangedSubview(imageView)
            contentStackView.addArrangedSubview(titleLabel)

        case .trailing:
            contentStackView.axis = .horizontal
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(imageView)

        case .top:
            contentStackView.axis = .vertical
            contentStackView.addArrangedSubview(imageView)
            contentStackView.addArrangedSubview(titleLabel)

        case .bottom:
            contentStackView.axis = .vertical
            contentStackView.addArrangedSubview(titleLabel)
            contentStackView.addArrangedSubview(imageView)

        default:
            // 其他值默认使用 leading 行为
            contentStackView.axis = .horizontal
            contentStackView.addArrangedSubview(imageView)
            contentStackView.addArrangedSubview(titleLabel)
        }

        // 更新对齐方式
        updateStackViewAlignment()

        // 若正在 loading，重建 stack 后需重新把 indicator 放回 imageView 位置
        if showsActivityIndicator {
            insertActivityIndicatorInStack()
        }
    }

    /// 更新 StackView 内部对齐
    private func updateStackViewAlignment() {
        // 水平和垂直布局都使用居中对齐
        // 如需调整，可通过 contentHorizontalAlignment/contentVerticalAlignment
        contentStackView.alignment = .center
    }

    /// 更新内容对齐（水平和垂直）
    private func updateContentAlignment() {
        updateHorizontalAlignment()
        updateVerticalAlignment()
    }

    /// 更新水平方向对齐
    private func updateHorizontalAlignment() {
        // 先重置所有约束
        wrapperCenterXConstraint?.isActive = false
        wrapperLeadingConstraint?.isActive = false
        wrapperTrailingConstraint?.isActive = false

        switch contentHorizontalAlignment {
        case .center:
            wrapperCenterXConstraint?.isActive = true
            wrapperLeadingConstraint = contentWrapperView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor, constant: contentInsets.left)
            wrapperTrailingConstraint = contentWrapperView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -contentInsets.right)
            wrapperLeadingConstraint?.isActive = true
            wrapperTrailingConstraint?.isActive = true

        case .left, .leading:
            wrapperCenterXConstraint?.isActive = false
            wrapperLeadingConstraint = contentWrapperView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: contentInsets.left)
            wrapperTrailingConstraint = contentWrapperView.trailingAnchor.constraint(
                lessThanOrEqualTo: trailingAnchor, constant: -contentInsets.right)
            wrapperLeadingConstraint?.isActive = true
            wrapperTrailingConstraint?.isActive = true

        case .right, .trailing:
            wrapperCenterXConstraint?.isActive = false
            wrapperLeadingConstraint = contentWrapperView.leadingAnchor.constraint(
                greaterThanOrEqualTo: leadingAnchor, constant: contentInsets.left)
            wrapperTrailingConstraint = contentWrapperView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -contentInsets.right)
            wrapperLeadingConstraint?.isActive = true
            wrapperTrailingConstraint?.isActive = true

        case .fill:
            wrapperCenterXConstraint?.isActive = false
            wrapperLeadingConstraint = contentWrapperView.leadingAnchor.constraint(
                equalTo: leadingAnchor, constant: contentInsets.left)
            wrapperTrailingConstraint = contentWrapperView.trailingAnchor.constraint(
                equalTo: trailingAnchor, constant: -contentInsets.right)
            wrapperLeadingConstraint?.isActive = true
            wrapperTrailingConstraint?.isActive = true

        @unknown default:
            break
        }
    }

    /// 更新垂直方向对齐
    private func updateVerticalAlignment() {
        wrapperCenterYConstraint?.isActive = false
        wrapperTopConstraint?.isActive = false
        wrapperBottomConstraint?.isActive = false

        switch contentVerticalAlignment {
        case .center:
            wrapperCenterYConstraint?.isActive = true
            wrapperTopConstraint = contentWrapperView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor, constant: contentInsets.top)
            wrapperBottomConstraint = contentWrapperView.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom)
            wrapperTopConstraint?.isActive = true
            wrapperBottomConstraint?.isActive = true

        case .top:
            wrapperCenterYConstraint?.isActive = false
            wrapperTopConstraint = contentWrapperView.topAnchor.constraint(
                equalTo: topAnchor, constant: contentInsets.top)
            wrapperBottomConstraint = contentWrapperView.bottomAnchor.constraint(
                lessThanOrEqualTo: bottomAnchor, constant: -contentInsets.bottom)
            wrapperTopConstraint?.isActive = true
            wrapperBottomConstraint?.isActive = true

        case .bottom:
            wrapperCenterYConstraint?.isActive = false
            wrapperTopConstraint = contentWrapperView.topAnchor.constraint(
                greaterThanOrEqualTo: topAnchor, constant: contentInsets.top)
            wrapperBottomConstraint = contentWrapperView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -contentInsets.bottom)
            wrapperTopConstraint?.isActive = true
            wrapperBottomConstraint?.isActive = true

        case .fill:
            wrapperCenterYConstraint?.isActive = false
            wrapperTopConstraint = contentWrapperView.topAnchor.constraint(
                equalTo: topAnchor, constant: contentInsets.top)
            wrapperBottomConstraint = contentWrapperView.bottomAnchor.constraint(
                equalTo: bottomAnchor, constant: -contentInsets.bottom)
            wrapperTopConstraint?.isActive = true
            wrapperBottomConstraint?.isActive = true

        @unknown default:
            break
        }
    }

    /// 更新内容边距
    private func updateContentInsets() {
        updateContentAlignment()
    }

    /// 更新图片尺寸约束
    private func updateImageSizeConstraints() {
        imageWidthConstraint?.isActive = false
        imageHeightConstraint?.isActive = false
        imageWidthConstraint = nil
        imageHeightConstraint = nil

        if let size = imageSize, size.width > 0, size.height > 0 {
            imageWidthConstraint = imageView.widthAnchor.constraint(equalToConstant: size.width)
            imageHeightConstraint = imageView.heightAnchor.constraint(equalToConstant: size.height)
            imageWidthConstraint?.priority = .defaultHigh
            imageHeightConstraint?.priority = .defaultHigh
            imageWidthConstraint?.isActive = true
            imageHeightConstraint?.isActive = true
        }
    }

    /// 更新加载指示器状态
    /// 对齐官方 UIButton.Configuration.showsActivityIndicator 行为：
    /// - indicator 替换 imageView 位置，跟随 imagePlacement
    /// - titleLabel 保持可见
    /// - 不修改 isUserInteractionEnabled
    private func updateActivityIndicatorState() {
        if showsActivityIndicator {
            insertActivityIndicatorInStack()
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
            activityIndicator.removeFromSuperview()
            // 恢复 imageView 显示（基于是否有图片）
            imageView.isHidden = (imageView.image == nil)
        }
    }

    /// 将 activityIndicator 插入 contentStackView 中 imageView 所在位置，并隐藏 imageView
    private func insertActivityIndicatorInStack() {
        guard let imageIndex = contentStackView.arrangedSubviews.firstIndex(of: imageView) else {
            return
        }
        activityIndicator.removeFromSuperview()
        contentStackView.insertArrangedSubview(activityIndicator, at: imageIndex)
        imageView.isHidden = true
    }

    // MARK: - 状态更新

    /// 根据当前 UIControl.State 更新显示
    private func updateCurrentState() {
        let state = self.state

        // 更新标题（富文本优先）
        if let attributedTitle = attributedTitle(for: state) {
            titleLabel.attributedText = attributedTitle
        } else {
            titleLabel.text = title(for: state)
        }

        // 更新图片
        let newImage = image(for: state)
        imageView.image = newImage
        imageView.isHidden = (newImage == nil)

        // 更新背景图片
        let newBackgroundImage = backgroundImage(for: state)
        backgroundImageView.image = newBackgroundImage
        backgroundImageView.isHidden = (newBackgroundImage == nil)

        // 更新标题颜色
        if let color = titleColor(for: state) {
            titleLabel.textColor = color
        }

        // 更新可用性外观
        alpha = isEnabled ? 1.0 : disabledAlpha
    }

    // MARK: - UIControl State 监听

    override open var isEnabled: Bool {
        didSet {
            guard isEnabled != oldValue else { return }
            updateCurrentState()
        }
    }

    override open var isSelected: Bool {
        didSet {
            guard isSelected != oldValue else { return }
            updateCurrentState()
        }
    }

    override open var isHighlighted: Bool {
        didSet {
            guard isHighlighted != oldValue else { return }

            // 高亮动画
            UIView.animate(withDuration: animationDuration) {
                if self.isHighlighted {
                    self.transform = CGAffineTransform(scaleX: self.highlightScale, y: self.highlightScale)
                    self.alpha = self.highlightAlpha
                } else {
                    self.transform = .identity
                    self.alpha = self.isEnabled ? 1.0 : self.disabledAlpha
                }
            }
        }
    }

    // MARK: - 布局

    override open func layoutSubviews() {
        super.layoutSubviews()
        // 圆角已在 cornerRadius didSet 中处理，无需重复设置
    }

    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard hitTestEdgeInsets != .zero else {
            return super.point(inside: point, with: event)
        }
        let hitRect = bounds.inset(by: UIEdgeInsets(
            top: -hitTestEdgeInsets.top,
            left: -hitTestEdgeInsets.left,
            bottom: -hitTestEdgeInsets.bottom,
            right: -hitTestEdgeInsets.right
        ))
        return hitRect.contains(point)
    }

    override open var intrinsicContentSize: CGSize {
        // 计算内容尺寸
        let contentSize = contentStackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        return CGSize(
            width: contentSize.width + contentInsets.left + contentInsets.right,
            height: contentSize.height + contentInsets.top + contentInsets.bottom
        )
    }

    // MARK: - @IBInspectable 支持

    @IBInspectable
    var imagePlacementIndex: Int {
        get { Int(imagePlacement.rawValue) }
        set {
            imagePlacement = NSDirectionalRectEdge(rawValue: UInt(newValue))
        }
    }

    @IBInspectable
    var contentHorizontalAlignmentIndex: Int {
        get { contentHorizontalAlignment.rawValue }
        set {
            if let alignment = UIControl.ContentHorizontalAlignment(rawValue: newValue) {
                contentHorizontalAlignment = alignment
            }
        }
    }

    @IBInspectable
    var contentVerticalAlignmentIndex: Int {
        get { contentVerticalAlignment.rawValue }
        set {
            if let alignment = UIControl.ContentVerticalAlignment(rawValue: newValue) {
                contentVerticalAlignment = alignment
            }
        }
    }

    @IBInspectable
    public var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }

    @IBInspectable
    public var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    public var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    /// 内容边距（用于 Interface Builder）
    @IBInspectable
    public var contentInsetTop: CGFloat {
        get { contentInsets.top }
        set { contentInsets.top = newValue }
    }

    @IBInspectable
    public var contentInsetLeft: CGFloat {
        get { contentInsets.left }
        set { contentInsets.left = newValue }
    }

    @IBInspectable
    public var contentInsetBottom: CGFloat {
        get { contentInsets.bottom }
        set { contentInsets.bottom = newValue }
    }

    @IBInspectable
    public var contentInsetRight: CGFloat {
        get { contentInsets.right }
        set { contentInsets.right = newValue }
    }

    // MARK: - Interface Builder

    override open func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()

        // IB 中显示预览内容
        if title(for: .normal) == nil && image(for: .normal) == nil {
            titleLabel.text = "UIControlButton"
        }

        layoutIfNeeded()
    }

    // MARK: - Accessibility

    override open var accessibilityLabel: String? {
        get { titleLabel.text }
        set { super.accessibilityLabel = newValue }
    }

    override open var accessibilityTraits: UIAccessibilityTraits {
        get { [.button, super.accessibilityTraits] }
        set { super.accessibilityTraits = newValue }
    }

    // MARK: - 工具方法

    private func contentInsetsEqual(_ lhs: UIEdgeInsets, _ rhs: UIEdgeInsets) -> Bool {
        return lhs.top == rhs.top &&
               lhs.left == rhs.left &&
               lhs.bottom == rhs.bottom &&
               lhs.right == rhs.right
    }

    /// 归一化状态：将组合状态按优先级归一化为单一状态
    /// 优先级：disabled > selected > highlighted > focused > normal
    /// - Parameter state: 原始状态
    /// - Returns: 归一化后的单一状态
    private static func normalizeState(_ state: UIControl.State) -> UIControl.State {
        if state.contains(.disabled) { return .disabled }
        if state.contains(.selected) { return .selected }
        if state.contains(.highlighted) { return .highlighted }
        if #available(iOS 9.0, *), state.contains(.focused) { return .focused }
        return .normal
    }
}

// MARK: - 便捷方法扩展

public extension UIControlButton {

    /// 开始加载（显示 activityIndicator）
    func startLoading() {
        showsActivityIndicator = true
    }

    /// 停止加载（隐藏 activityIndicator）
    func stopLoading() {
        showsActivityIndicator = false
    }

    /// 设置内容边距
    /// - Parameter insets: 边距
    func setContentInsets(_ insets: UIEdgeInsets) {
        contentInsets = insets
    }

    /// 设置图片尺寸
    /// - Parameter size: 尺寸，nil 表示使用原始尺寸
    func setImageSize(_ size: CGSize?) {
        imageSize = size
    }

    /// 同时设置标题和图片（normal 状态）
    /// - Parameters:
    ///   - title: 标题
    ///   - image: 图片
    func setTitle(_ title: String?, image: UIImage?) {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
    }

    /// 配置常用属性（链式调用支持）
    /// - Parameters:
    ///   - title: 标题（normal 状态）
    ///   - image: 图片（normal 状态）
    ///   - placement: 图片位置
    ///   - padding: 图文间距
    /// - Returns: self，支持链式调用
    @discardableResult
    func configure(
        title: String? = nil,
        image: UIImage? = nil,
        placement: NSDirectionalRectEdge = .leading,
        padding: CGFloat = 8
    ) -> Self {
        setTitle(title, for: .normal)
        setImage(image, for: .normal)
        imagePlacement = placement
        imagePadding = padding
        return self
    }

    /// 设置背景色（支持链式调用）
    /// - Parameter color: 背景色
    /// - Returns: self
    @discardableResult
    func backgroundColor(_ color: UIColor) -> Self {
        backgroundColor = color
        return self
    }

    /// 设置标题颜色（normal 状态，支持链式调用）
    /// - Parameter color: 标题颜色
    /// - Returns: self
    @discardableResult
    func titleColor(_ color: UIColor) -> Self {
        setTitleColor(color, for: .normal)
        return self
    }

    /// 设置字体（支持链式调用）
    /// - Parameter font: 字体
    /// - Returns: self
    @discardableResult
    func font(_ font: UIFont) -> Self {
        titleFont = font
        return self
    }

    /// 设置圆角（支持链式调用）
    /// - Parameter radius: 圆角半径
    /// - Returns: self
    @discardableResult
    func cornerRadius(_ radius: CGFloat) -> Self {
        cornerRadius = radius
        return self
    }
}

// MARK: - Configuration 配置结构体（iOS 14+ 风格）

@available(iOS 14.0, *)
public extension UIControlButton {

    /// 配置结构体，类似 UIButton.Configuration
    struct Configuration {
        public var title: String?
        public var attributedTitle: NSAttributedString?
        public var image: UIImage?
        public var backgroundImage: UIImage?
        public var imagePlacement: NSDirectionalRectEdge = .leading
        public var imagePadding: CGFloat = 8
        public var contentInsets: UIEdgeInsets = .init(top: 8, left: 16, bottom: 8, right: 16)
        public var contentHorizontalAlignment: UIControl.ContentHorizontalAlignment = .center
        public var contentVerticalAlignment: UIControl.ContentVerticalAlignment = .center
        public var backgroundColor: UIColor? = nil
        public var titleColor: UIColor = .systemBlue
        public var titleFont: UIFont = .systemFont(ofSize: 16)
        public var cornerRadius: CGFloat = 0
        public var imageSize: CGSize?
        public var showsActivityIndicator: Bool = false
        public var activityIndicatorColor: UIColor?
        public var borderWidth: CGFloat = 0
        public var borderColor: UIColor?

        public init() {}
    }

    /// 应用 Configuration 配置
    /// - Parameter configuration: 配置对象
    func apply(configuration: Configuration) {
        if let title = configuration.title {
            setTitle(title, for: .normal)
        }
        if let attributedTitle = configuration.attributedTitle {
            setAttributedTitle(attributedTitle, for: .normal)
        }
        if let image = configuration.image {
            setImage(image, for: .normal)
        }
        if let backgroundImage = configuration.backgroundImage {
            setBackgroundImage(backgroundImage, for: .normal)
        }
        imagePlacement = configuration.imagePlacement
        imagePadding = configuration.imagePadding
        contentInsets = configuration.contentInsets
        contentHorizontalAlignment = configuration.contentHorizontalAlignment
        contentVerticalAlignment = configuration.contentVerticalAlignment
        if let bgColor = configuration.backgroundColor {
            backgroundColor = bgColor
        }
        setTitleColor(configuration.titleColor, for: .normal)
        titleFont = configuration.titleFont
        cornerRadius = configuration.cornerRadius
        imageSize = configuration.imageSize
        showsActivityIndicator = configuration.showsActivityIndicator
        activityIndicatorColor = configuration.activityIndicatorColor
        borderWidth = configuration.borderWidth
        borderColor = configuration.borderColor
    }
}
#endif
