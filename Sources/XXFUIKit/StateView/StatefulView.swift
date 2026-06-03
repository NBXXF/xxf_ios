//
//  StatefulView.swift
//  xxf_ios
//
//  Created by xxf on 2023/3/25.
//

#if canImport(UIKit)
import UIKit

/// 有状态的视图
/// 结构：
/// - contentView: 常驻内容视图（如 CollectionView/TableView）
/// - overlayView: 遮罩层，用于显示各种状态视图
@MainActor
open class StatefulView: UIView {
    /// 页面状态枚举
    public enum State: Hashable {
        /// 加载中
        case loading
        /// 空数据
        case empty
        /// 错误
        case error
        /// 正常内容
        case content
    }

    /// 全局默认状态视图创建回调，返回 nil 时继续使用内置默认视图
    public static var defaultStateViewProvider: ((State) -> UIView?)?

    /// 内容视图（常驻，不销毁）
    public let contentView: UIView

    /// 加载中视图（类型化访问）
    public var loadingView: ILoadingView? {
        return stateViews[.loading] as? ILoadingView
    }

    /// 空数据视图（类型化访问）
    public var emptyView: IEmptyView? {
        return stateViews[.empty] as? IEmptyView
    }

    /// 错误视图（类型化访问）
    public var errorView: IErrorView? {
        return stateViews[.error] as? IErrorView
    }

    /// 遮罩层（用于显示各种状态视图）
    private let overlayView = UIView()

    /// 状态视图存储
    private var stateViews: [State: UIView] = [:]

    /// 当前显示的状态
    private(set) var currentState: State = .content

    /// 是否允许点击穿透到 contentView（默认 false，状态显示时阻止交互）
    public var allowContentInteractionDuringState = false

    /// 重试回调
    public var onRetry: (() -> Void)?

    /// 当前动画标识，用于处理动画竞态
    private var animationToken: UUID?

    /// 状态切换动画时长（默认 0.25 秒，设为 0 禁用动画）
    public var animationDuration: TimeInterval = 0.25

    // MARK: - 初始化

    /// 使用自定义内容视图初始化
    /// - Parameter contentView: 内容视图（如 UICollectionView、UITableView 等）
    public init(contentView: UIView, onRetry: (() -> Void)? = nil) {
        self.contentView = contentView
        self.onRetry = onRetry
        super.init(frame: .zero)
        setupUI()
    }

    override public init(frame: CGRect) {
        self.contentView = UIView()
        super.init(frame: frame)
        setupUI()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        // 添加 contentView（常驻底层）
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        // 添加 overlayView（遮罩层）
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        overlayView.isHidden = true
        overlayView.backgroundColor = .clear
    }

    // MARK: - 公共方法

    /// 设置自定义状态视图
    /// - Parameters:
    ///   - view: 自定义视图
    ///   - state: 对应的状态
    public func setStateView(_ view: UIView, for state: State) {
        // 移除该状态已有的视图
        if let existingView = stateViews[state] {
            stopLoadingIfNeeded(existingView, for: state)
            existingView.removeFromSuperview()
        }

        // 存储并添加到 overlayView
        stateViews[state] = view
        overlayView.addSubview(view)

        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.topAnchor.constraint(equalTo: overlayView.topAnchor),
            view.bottomAnchor.constraint(equalTo: overlayView.bottomAnchor),
            view.leadingAnchor.constraint(equalTo: overlayView.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: overlayView.trailingAnchor),
        ])

        view.isHidden = true
    }

    /// 更新状态（状态之间互斥）
    /// - Parameter state: 目标状态
    /// - Parameter animated: 是否使用动画（默认 true）
    open func update(state: State, animated: Bool = true) {
        let duration = animated ? animationDuration : 0
        let token = UUID()
        animationToken = token

        currentState = state

        switch state {
        case .content:
            // 内容状态：隐藏所有状态视图和遮罩层
            guard duration > 0 else {
                hideAllStateViews()
                overlayView.isHidden = true
                updateContentInteraction()
                return
            }

            UIView.animate(withDuration: duration, animations: {
                self.stateViews.values.forEach { $0.alpha = 0 }
            }, completion: { [weak self] _ in
                guard let self = self, self.animationToken == token else { return }
                self.hideAllStateViews()
                self.overlayView.isHidden = true
                self.stateViews.values.forEach { $0.alpha = 1 }
            })

        case .loading, .empty, .error:
            // 其他状态：显示遮罩层，显示对应状态视图
            overlayView.isHidden = false
            overlayView.alpha = 0

            // 先准备要显示的视图
            prepareStateView(for: state)

            guard duration > 0 else {
                overlayView.alpha = 1
                showStateView(for: state, animated: false)
                updateContentInteraction()
                return
            }

            UIView.animate(withDuration: duration, animations: {
                [weak self] in
                guard let self = self, self.animationToken == token else { return }
                self.overlayView.alpha = 1
                self.showStateView(for: state, animated: false)
            })
        }

        updateContentInteraction()
    }

    /// 获取指定状态对应的视图（如果不存在则自动创建）
    /// - Parameter state: 目标状态
    /// - Returns: 对应的状态视图
    public func stateView(for state: State) -> UIView {
        // 如果已存在对应状态的视图，直接返回
        if let view = stateViews[state] {
            return view
        }

        // 创建默认视图
        prepareStateView(for: state)
        return stateViews[state] ?? UIView()
    }

    /// 获取指定状态对应的视图（如果不存在则返回 nil，不自动创建）
    /// - Parameter state: 目标状态
    public func stateViewIfExists(for state: State) -> UIView? {
        return stateViews[state]
    }

    /// 移除指定状态视图
    public func removeStateView(for state: State) {
        if let stateView = stateViews[state] {
            stopLoadingIfNeeded(stateView, for: state)
        }
        stateViews[state]?.removeFromSuperview()
        stateViews.removeValue(forKey: state)
    }

    /// 清空所有状态视图
    public func removeAllStateViews() {
        stateViews.forEach { state, view in
            stopLoadingIfNeeded(view, for: state)
        }
        stateViews.values.forEach { $0.removeFromSuperview() }
        stateViews.removeAll()
    }

    // MARK: - 私有方法

    private func hideAllStateViews() {
        stopLoadingIfNeeded(stateViews[.loading], for: .loading)
        stateViews.values.forEach { $0.isHidden = true }
    }

    private func prepareStateView(for state: State) {
        // 如果已存在对应状态的视图，直接返回
        guard stateViews[state] == nil else { return }

        // 创建默认视图
        let defaultView = createDefaultView(for: state)
        setStateView(defaultView, for: state)
    }

    private func showStateView(for state: State, animated: Bool) {
        // 先隐藏所有状态视图
        hideAllStateViews()

        // 显示目标状态视图
        if let targetView = stateViews[state] {
            targetView.isHidden = false
            startLoadingIfNeeded(targetView, for: state)
            if animated {
                targetView.alpha = 0
                UIView.animate(withDuration: animationDuration) {
                    targetView.alpha = 1
                }
            } else {
                targetView.alpha = 1
            }
        }
    }

    private func startLoadingIfNeeded(_ view: UIView, for state: State) {
        guard state == .loading else { return }
        (view as? ILoadingView)?.startLoading()
    }

    private func stopLoadingIfNeeded(_ view: UIView?, for state: State) {
        guard state == .loading else { return }
        (view as? ILoadingView)?.stopLoading()
    }

    private func createDefaultView(for state: State) -> UIView {
        if let defaultStateView = Self.defaultStateViewProvider?(state) {
            return defaultStateView
        }

        switch state {
        case .loading:
            return DefaultLoadingView()

        case .empty:
            let emptyView = DefaultEmptyView(
                title: "Nothing here yet",
                message: "Check back later.",
                buttonTitle: "Try again"
            )
            emptyView.onRetry = { [weak self] in
                self?.onRetry?()
            }
            return emptyView

        case .error:
            let errorView = DefaultErrorView(
                title: "Oops, something went wrong",
                message: "Please check your connection and try again",
                buttonTitle: "Try again"
            )
            errorView.onRetry = { [weak self] in
                self?.onRetry?()
            }
            return errorView

        case .content:
            return UIView()
        }
    }

    private func updateContentInteraction() {
        // 当显示非内容状态时，可以选择是否阻止 contentView 的交互
        contentView.isUserInteractionEnabled = currentState == .content || allowContentInteractionDuringState
    }
}

#endif
