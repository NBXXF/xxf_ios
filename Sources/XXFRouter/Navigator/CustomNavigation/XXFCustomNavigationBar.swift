//
//  XXFCustomNavigationBar.swift
//  xxf_ios
//
//  Created by xxf on 5/21.
//

#if canImport(UIKit)
import UIKit

// MARK: - XXFCustomNavigationBar

/// A lightweight custom container that renders a `UINavigationItem` while the
/// real `UINavigationBar` stays hidden.
open class XXFCustomNavigationBar: UIView {

    // MARK: Public Properties

    /// 自绘导航栏内容行默认高度，对齐系统常规导航栏内容高度。
    public static let defaultContentHeight: CGFloat = 44

    /// 左侧按钮容器。
    ///
    /// 顺序为默认返回按钮（如果需要）加 `navigationItem.leftBarButtonItem(s)`。
    public let leftStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    /// 右侧按钮容器。
    ///
    /// 按 UIKit 导航栏视觉顺序渲染 `navigationItem.rightBarButtonItem(s)`。
    public let rightStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 4
        return stackView
    }()

    /// 默认标题 label。
    ///
    /// 当 `navigationItem.titleView` 不存在时使用；存在 titleView 时该 label 会隐藏。
    public let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.lineBreakMode = .byTruncatingTail
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    /// 默认返回按钮。
    ///
    /// 当当前页面可返回且没有完全替代默认返回的左侧按钮时显示。
    public let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .label
        button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        button.accessibilityLabel = "Back"
        button.accessibilityTraits = .button
        return button
    }()

    /// 内容行高度。
    ///
    /// 修改后会刷新左右容器和默认返回按钮的尺寸约束。
    open var contentHeight: CGFloat = defaultContentHeight {
        didSet { updateContentHeightConstraints() }
    }

    /// 自绘导航栏背景色。
    open var barBackgroundColor: UIColor = .systemBackground {
        didSet { backgroundColor = barBackgroundColor }
    }

    // MARK: Private Properties

    /// 默认返回按钮点击回调，由 navigation controller 在每次配置时注入。
    private var onBack: (() -> Void)?

    /// 当前挂载在自绘导航栏中的 `navigationItem.titleView`。
    private weak var currentCustomTitleView: UIView?

    /// 当前 titleView 的布局约束集合，用于切换标题来源时完整移除旧约束。
    private var customTitleViewConstraints: [NSLayoutConstraint] = []

    /// 左侧按钮容器高度约束，随 `contentHeight` 更新。
    private var leftStackHeightConstraint: NSLayoutConstraint?

    /// 右侧按钮容器高度约束，随 `contentHeight` 更新。
    private var rightStackHeightConstraint: NSLayoutConstraint?

    /// 默认返回按钮宽度约束，随 `contentHeight` 更新。
    private var backButtonWidthConstraint: NSLayoutConstraint?

    /// 默认返回按钮高度约束，随 `contentHeight` 更新。
    private var backButtonHeightConstraint: NSLayoutConstraint?

    // MARK: Lifecycle

    /// 代码创建入口。
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    /// Storyboard / xib 创建入口。
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: Public Methods

    /// 使用指定页面的 `navigationItem` 重新配置自绘导航栏内容。
    ///
    /// - Parameters:
    ///   - viewController: 当前导航栈顶部页面。
    ///   - showBack: 是否需要显示默认返回按钮。
    ///   - onBack: 默认返回按钮点击后的处理逻辑。
    open func configure(
        topViewController viewController: UIViewController,
        showBack: Bool,
        onBack: @escaping () -> Void
    ) {
        self.onBack = onBack
        configureLeftItems(for: viewController, showBack: showBack)
        configureTitle(for: viewController)
        configureRightItems(for: viewController)
    }

    /// 获取右侧第 `index` 个按钮对应的真实 view。
    ///
    /// 若渲染过程中为 customView 加了 wrapper，这里会返回原始 customView。
    open func rightItemView(at index: Int) -> UIView? {
        guard index >= 0, index < rightStackView.arrangedSubviews.count else { return nil }
        let view = rightStackView.arrangedSubviews[index]
        return (view as? XXFCustomNavigationContentWrapper)?.contentView ?? view
    }

    /// 获取左侧第 `index` 个按钮对应的真实 view。
    open func leftItemView(at index: Int) -> UIView? {
        guard index >= 0, index < leftStackView.arrangedSubviews.count else { return nil }
        let view = leftStackView.arrangedSubviews[index]
        return (view as? XXFCustomNavigationContentWrapper)?.contentView ?? view
    }

    // MARK: UI Setup

    /// 初始化基础视图层级和静态约束。
    private func setupUI() {
        backgroundColor = barBackgroundColor
        isOpaque = true
        clipsToBounds = false

        backButton.addAction(UIAction { [weak self] _ in
            self?.onBack?()
        }, for: .touchUpInside)

        [leftStackView, titleLabel, rightStackView].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        let guide = safeAreaLayoutGuide
        let leftHeight = leftStackView.heightAnchor.constraint(equalToConstant: contentHeight)
        let rightHeight = rightStackView.heightAnchor.constraint(lessThanOrEqualToConstant: contentHeight)
        leftStackHeightConstraint = leftHeight
        rightStackHeightConstraint = rightHeight

        NSLayoutConstraint.activate([
            leftStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            leftStackView.topAnchor.constraint(equalTo: guide.topAnchor),
            leftHeight,

            rightStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            rightStackView.centerYAnchor.constraint(equalTo: leftStackView.centerYAnchor),
            rightHeight,

            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: leftStackView.centerYAnchor),
            titleLabel.leadingAnchor.constraint(greaterThanOrEqualTo: leftStackView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: rightStackView.leadingAnchor, constant: -8)
        ])
    }

    /// 根据 `contentHeight` 刷新会受高度影响的约束。
    private func updateContentHeightConstraints() {
        leftStackHeightConstraint?.constant = contentHeight
        rightStackHeightConstraint?.constant = contentHeight
        backButtonWidthConstraint?.constant = contentHeight
        backButtonHeightConstraint?.constant = contentHeight
        setNeedsLayout()
    }

    // MARK: Configuration

    /// 渲染左侧按钮区域。
    ///
    /// UIKit 语义中，存在 left item 时默认返回按钮会被替代；`leftItemsSupplementBackButton` 为 true 时两者同时显示。
    private func configureLeftItems(for viewController: UIViewController, showBack: Bool) {
        clearArrangedSubviews(in: leftStackView)

        let item = viewController.navigationItem
        let leftItems = item.leftBarButtonItems ?? item.leftBarButtonItem.map { [$0] } ?? []
        let shouldShowDefaultBack = showBack && (leftItems.isEmpty || item.leftItemsSupplementBackButton)

        if shouldShowDefaultBack {
            leftStackView.addArrangedSubview(backButton)
            installBackButtonConstraintsIfNeeded()
        }

        leftItems.compactMap { viewForBarButtonItem($0) }.forEach {
            leftStackView.addArrangedSubview($0)
        }
    }

    /// 渲染右侧按钮区域。
    ///
    /// `rightBarButtonItems` 在 UIKit 中数组第一个位于最右侧，这里通过 reversed 后加入 stack 保持视觉顺序。
    private func configureRightItems(for viewController: UIViewController) {
        clearArrangedSubviews(in: rightStackView)

        let item = viewController.navigationItem
        let rightItems = item.rightBarButtonItems ?? item.rightBarButtonItem.map { [$0] } ?? []
        rightItems.reversed().compactMap { viewForBarButtonItem($0) }.forEach {
            rightStackView.addArrangedSubview($0)
        }
    }

    /// 渲染标题区域。
    ///
    /// `navigationItem.titleView` 优先级高于文字标题；titleView 会直接移动到自绘 bar 中而不是复制。
    private func configureTitle(for viewController: UIViewController) {
        if let customTitleView = viewController.navigationItem.titleView {
            titleLabel.isHidden = true
            installCustomTitleViewIfNeeded(customTitleView)
            return
        }

        removeCustomTitleView()
        titleLabel.isHidden = false
        titleLabel.text = Self.resolvedTitle(from: viewController)
    }

    /// 首次展示默认返回按钮时安装尺寸约束。
    private func installBackButtonConstraintsIfNeeded() {
        guard backButtonWidthConstraint == nil, backButtonHeightConstraint == nil else { return }

        let width = backButton.widthAnchor.constraint(equalToConstant: contentHeight)
        let height = backButton.heightAnchor.constraint(equalToConstant: contentHeight)
        backButtonWidthConstraint = width
        backButtonHeightConstraint = height
        NSLayoutConstraint.activate([width, height])
    }

    /// 将 `navigationItem.titleView` 安装到自绘导航栏。
    ///
    /// 如果还是同一个 titleView，只保留现有挂载，避免重复创建约束。
    private func installCustomTitleViewIfNeeded(_ customTitleView: UIView) {
        guard currentCustomTitleView !== customTitleView else { return }

        removeCustomTitleView()
        customTitleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(customTitleView)
        customTitleViewConstraints = [
            customTitleView.centerXAnchor.constraint(equalTo: centerXAnchor),
            customTitleView.centerYAnchor.constraint(equalTo: leftStackView.centerYAnchor),
            customTitleView.leadingAnchor.constraint(greaterThanOrEqualTo: leftStackView.trailingAnchor, constant: 8),
            customTitleView.trailingAnchor.constraint(lessThanOrEqualTo: rightStackView.leadingAnchor, constant: -8)
        ]
        customTitleViewConstraints.append(contentsOf: customContentSizeConstraints(for: customTitleView, minimumWidth: 0))
        NSLayoutConstraint.activate(customTitleViewConstraints)
        currentCustomTitleView = customTitleView
    }

    /// 移除当前自定义 titleView 及其约束。
    private func removeCustomTitleView() {
        customTitleViewConstraints.forEach { $0.isActive = false }
        customTitleViewConstraints.removeAll()
        currentCustomTitleView?.removeFromSuperview()
        currentCustomTitleView = nil
    }

    /// 从页面上解析文本标题。
    ///
    /// 优先使用 `navigationItem.title`，再回退到 `UIViewController.title`。
    private static func resolvedTitle(from viewController: UIViewController) -> String {
        if let title = viewController.navigationItem.title, !title.isEmpty { return title }
        if let title = viewController.title, !title.isEmpty { return title }
        return ""
    }
}
#endif
