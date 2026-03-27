//
//  KeyboardFocusManagerView.swift
//  XXFKeyboard
//
//  Created on 2026-03-27.
//

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa

/// KeyboardFocusManagerView - 聊天列表键盘焦点管理容器
///
/// 提供类似微信的键盘交互体验：
/// - 列表滚动时自动收起键盘
/// - 上下滑动时收起键盘
/// - 点击空白处收起键盘
/// - 点击输入框区域不拦截事件
///
/// **重要：本组件不会拦截或影响内部子视图的任何事件**
/// - 点击输入框时，输入框正常响应，键盘保持弹出
/// - 点击按钮时，按钮正常响应
/// - 列表滚动时，列表正常滚动，同时收起键盘
///
/// 使用方式：
/// ```swift
/// let keyboardManager = KeyboardFocusManagerView()
/// view.addSubview(keyboardManager)
/// keyboardManager.snp.makeConstraints { $0.edges.equalToSuperview() }
///
/// // 将聊天列表和输入栏放入其中
/// keyboardManager.addSubview(tableView)
/// keyboardManager.addSubview(inputBar)
/// ```
open class KeyboardFocusManagerView: UIView {

    // MARK: - Properties

    private let disposeBag = DisposeBag()

    /// 是否启用点击空白处收起键盘（默认开启）
    public var isTapToDismissEnabled: Bool = true {
        didSet { tapGesture.isEnabled = isTapToDismissEnabled }
    }

    /// 是否启用滚动时收起键盘（默认开启）
    public var isScrollToDismissEnabled: Bool = true

    /// 是否启用滑动手势收起键盘（默认开启）
    public var isPanToDismissEnabled: Bool = true {
        didSet { panGesture.isEnabled = isPanToDismissEnabled }
    }

    /// 滚动触发收起的阈值速度
    public var scrollVelocityThreshold: CGFloat = 50.0

    /// 点击手势 - 仅用于检测点击空白处
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        // 不拦截子视图事件，允许事件继续传递
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        return gesture
    }()

    /// 滑动手势 - 用于检测上下滑动
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        // 不拦截子视图事件
        gesture.cancelsTouchesInView = false
        gesture.delaysTouchesBegan = false
        gesture.delaysTouchesEnded = false
        gesture.delegate = self
        // 只允许垂直方向
      ///  gesture.direction = .vertical
        return gesture
    }()

    /// 已发现的 scrollViews - 使用 WeakBox 避免循环引用
    private var trackedScrollViews: [WeakBox<UIScrollView>] = []

    /// 滚动状态追踪 - 使用 WeakBox 作为 key
    private var scrollStates: [ObjectIdentifier: ScrollState] = [:]

    /// 每个 scrollView 独立的 disposeBag，用于在取消追踪时释放订阅
    private var scrollViewDisposeBags: [ObjectIdentifier: DisposeBag] = [:]

    /// 标记是否已初始化追踪
    private var hasInitializedTracking = false

    /// 标记是否正在处理 pan 手势，防止重复触发
    private var isPanning = false

    private struct ScrollState {
        var isDragging = false
        var lastOffset: CGPoint = .zero
    }

    // MARK: - Initialization

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestures()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGestures()
    }

    deinit {
        // 清理所有订阅
        scrollViewDisposeBags.removeAll()
    }

    // MARK: - Setup

    private func setupGestures() {
        addGestureRecognizer(tapGesture)
        addGestureRecognizer(panGesture)
    }

    public override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && !hasInitializedTracking {
            hasInitializedTracking = true
            discoverAndTrackScrollViews()
        }
    }

    // MARK: - ScrollView Discovery

    /// 自动发现并追踪所有子视图中的 UIScrollView
    /// 只在 didMoveToWindow 时调用一次，后续依赖 KVO 监听 subviews 变化
    private func discoverAndTrackScrollViews() {
        let scrollViews = findAllScrollViews()

        // 找到新的 scrollViews
        for scrollView in scrollViews {
            let identifier = ObjectIdentifier(scrollView)
            let alreadyTracked = trackedScrollViews.contains { box in
                guard let tracked = box.value else { return false }
                return ObjectIdentifier(tracked) == identifier
            }

            if !alreadyTracked {
                trackScrollView(scrollView)
                trackedScrollViews.append(WeakBox(scrollView))
            }
        }

        // 清理已释放的引用
        cleanupReleasedReferences()
    }

    /// 清理已释放的 scrollView 引用
    private func cleanupReleasedReferences() {
        trackedScrollViews.removeAll { $0.value == nil }

        // 清理对应的状态和 disposeBag
        let activeIdentifiers = Set(trackedScrollViews.compactMap { box -> ObjectIdentifier? in
            guard let scrollView = box.value else { return nil }
            return ObjectIdentifier(scrollView)
        })

        scrollStates = scrollStates.filter { activeIdentifiers.contains($0.key) }
        scrollViewDisposeBags = scrollViewDisposeBags.filter { activeIdentifiers.contains($0.key) }
    }

    private func findAllScrollViews() -> [UIScrollView] {
        var result: [UIScrollView] = []
        findScrollViews(in: self, result: &result, depth: 0)
        return result
    }

    /// 递归查找 scrollViews，限制深度避免性能问题
    private func findScrollViews(in view: UIView, result: inout [UIScrollView], depth: Int) {
        // 限制递归深度，避免深层嵌套导致性能问题
        guard depth < 10 else { return }

        // 跳过隐藏的视图
        guard !view.isHidden && view.alpha > 0.01 else { return }

        // 如果是 UIScrollView 且不是输入框，加入结果
        if let scrollView = view as? UIScrollView,
           !(scrollView is UITextView) {
            result.append(scrollView)
            // 如果是 UITableView/UICollectionView，通常不需要再查找其子视图中的 scrollView
            if scrollView is UITableView || scrollView is UICollectionView {
                return
            }
        }

        // 递归查找子视图
        for subview in view.subviews {
            // 跳过输入栏区域（包含 UITextField/UITextView 的容器）
            if isInputContainer(subview) {
                continue
            }
            findScrollViews(in: subview, result: &result, depth: depth + 1)
        }
    }

    /// 判断是否是输入容器（包含文本输入框的视图）
    /// 使用 iterative 方式避免深层嵌套时的栈溢出问题
    private func isInputContainer(_ view: UIView) -> Bool {
        var stack: [UIView] = [view]
        var visitedCount = 0
        let maxVisitCount = 50 // 限制检查的视图数量

        while !stack.isEmpty && visitedCount < maxVisitCount {
            let current = stack.removeLast()
            visitedCount += 1

            if current is UITextField || current is UITextView {
                return true
            }

            // 只添加直接子视图，限制检查深度
            if current !== view {
                // 对于子视图，只检查一层
                for subview in current.subviews.prefix(5) {
                    if subview is UITextField || subview is UITextView {
                        return true
                    }
                }
            } else {
                stack.append(contentsOf: current.subviews)
            }
        }

        return false
    }

    // MARK: - ScrollView Tracking

    private func trackScrollView(_ scrollView: UIScrollView) {
        let identifier = ObjectIdentifier(scrollView)
        scrollStates[identifier] = ScrollState()

        // 为这个 scrollView 创建独立的 disposeBag
        let scrollViewBag = DisposeBag()
        scrollViewDisposeBags[identifier] = scrollViewBag

        // 监听 contentOffset 变化
        scrollView.rx.contentOffset
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak scrollView] _ in
                guard let self = self, let scrollView = scrollView else { return }
                self.handleScroll(scrollView)
            })
            .disposed(by: scrollViewBag)

        // 监听拖拽开始
        scrollView.rx.willBeginDragging
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak scrollView] in
                guard let self = self, let scrollView = scrollView else { return }
                let identifier = ObjectIdentifier(scrollView)
                var state = self.scrollStates[identifier] ?? ScrollState()
                state.isDragging = true
                state.lastOffset = scrollView.contentOffset
                self.scrollStates[identifier] = state
            })
            .disposed(by: scrollViewBag)

        // 监听拖拽结束
        scrollView.rx.didEndDragging
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak scrollView] decelerate in
                guard let self = self, let scrollView = scrollView else { return }
                let identifier = ObjectIdentifier(scrollView)
                var state = self.scrollStates[identifier] ?? ScrollState()
                state.isDragging = false
                // 如果不减速，清除 lastOffset 避免误判
                if !decelerate {
                    state.lastOffset = .zero
                }
                self.scrollStates[identifier] = state

                // 收起键盘（拖拽结束时）
                if self.isScrollToDismissEnabled {
                    self.dismissKeyboard()
                }
            })
            .disposed(by: scrollViewBag)

        // 监听减速开始
        scrollView.rx.willBeginDecelerating
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self, self.isScrollToDismissEnabled else { return }
                self.dismissKeyboard()
            })
            .disposed(by: scrollViewBag)

        // 监听减速结束，清理状态
        scrollView.rx.didEndDecelerating
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self, weak scrollView] in
                guard let self = self, let scrollView = scrollView else { return }
                let identifier = ObjectIdentifier(scrollView)
                var state = self.scrollStates[identifier] ?? ScrollState()
                state.lastOffset = .zero
                self.scrollStates[identifier] = state
            })
            .disposed(by: scrollViewBag)
    }

    private func handleScroll(_ scrollView: UIScrollView) {
        guard isScrollToDismissEnabled else { return }

        let identifier = ObjectIdentifier(scrollView)
        var state = scrollStates[identifier] ?? ScrollState()
        guard state.isDragging else { return }

        let currentOffset = scrollView.contentOffset

        // 处理 contentOffset 可能的负值（下拉刷新等情况）
        guard currentOffset.y >= -scrollView.adjustedContentInset.top else { return }

        let delta = currentOffset.y - state.lastOffset.y
        let velocity = abs(delta)

        // 当滚动速度超过阈值时收起键盘
        // 同时检查滚动方向，避免微小的抖动触发
        if velocity > scrollVelocityThreshold && velocity > abs(delta) * 0.5 {
            dismissKeyboard()
        }

        state.lastOffset = currentOffset
        scrollStates[identifier] = state
    }

    // MARK: - Gesture Handlers

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard isTapToDismissEnabled,
              gesture.state == .ended else { return }

        // 获取触摸位置
        let location = gesture.location(in: self)

        // 检查点击位置是否在输入区域内
        // 使用 hitTest 找到实际被点击的视图
        guard let hitView = self.hitTest(location, with: nil) else {
            dismissKeyboard()
            return
        }

        // 如果被点击的视图是输入框或包含输入框，不收起键盘
        if isViewOrAncestorInputContainer(hitView) {
            return
        }

        // 点击的是空白处，收起键盘
        dismissKeyboard()
    }

    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard isPanToDismissEnabled else { return }

        switch gesture.state {
        case .began:
            isPanning = false

        case .changed:
            guard !isPanning else { return }

            let velocity = gesture.velocity(in: self)
            let translation = gesture.translation(in: self)

            // 判断是否为明显的垂直滑动
            // 1. 垂直速度足够大
            // 2. 垂直位移大于水平位移（确保是上下滑动而非左右）
            let isVerticalSwipe = abs(velocity.y) > 200 &&
                                  abs(translation.y) > abs(translation.x) &&
                                  abs(translation.y) > 20

            if isVerticalSwipe {
                isPanning = true
                dismissKeyboard()
            }

        case .ended, .cancelled, .failed:
            isPanning = false

        default:
            break
        }
    }

    /// 检查视图或其祖先是否是输入容器
    private func isViewOrAncestorInputContainer(_ view: UIView) -> Bool {
        var currentView: UIView? = view
        var depth = 0
        let maxDepth = 20 // 限制遍历深度

        while let v = currentView, depth < maxDepth {
            if v is UITextField || v is UITextView {
                return true
            }
            currentView = v.superview
            depth += 1
            // 只检查到本组件为止
            if currentView === self {
                break
            }
        }
        return false
    }

    /// 收起键盘
    public func dismissKeyboard() {
        endEditing(true)
    }
}

// MARK: - UIGestureRecognizerDelegate

extension KeyboardFocusManagerView: UIGestureRecognizerDelegate {

    /// 决定是否接收触摸事件
    /// 返回 false 表示不接收，事件将传递给子视图
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // 多指触摸时忽略
        guard touch.tapCount <= 1 else { return false }

        let location = touch.location(in: self)

        // 检查位置是否有效
        guard bounds.contains(location) else { return false }

        // 使用 hitTest 找到实际被触摸的视图
        guard let hitView = self.hitTest(location, with: nil) else {
            return true
        }

        // 如果触摸的是输入框本身，不收起键盘，也不拦截事件
        if hitView is UITextField || hitView is UITextView {
            return false
        }

        // 如果触摸的是 UIControl（按钮、开关等），检查是否在输入区域内
        if hitView is UIControl {
            if isViewOrAncestorInputContainer(hitView) {
                return false
            }
            // 点击 UIControl 但不触发键盘收起，由 UIControl 自己处理
            return false
        }

        // 检查触摸点是否在输入容器内
        if isViewOrAncestorInputContainer(hitView) {
            return false
        }

        // 点击的是空白区域，可以接收手势
        return true
    }

    /// 允许与其他手势同时识别
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 特别允许与 ScrollView 的 Pan 手势共存
        if otherGestureRecognizer.view is UIScrollView {
            return true
        }
        // 允许与其他所有手势同时识别
        return true
    }
}

// MARK: - UIScrollView+Rx Extension

private extension Reactive where Base: UIScrollView {
    var willBeginDragging: Observable<Void> {
        return delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDragging(_:)))
            .observe(on: MainScheduler.instance)
            .map { _ in () }
    }

    var didEndDragging: Observable<Bool> {
        return delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDragging(_:willDecelerate:)))
            .observe(on: MainScheduler.instance)
            .map { $0[1] as? Bool ?? false }
    }

    var willBeginDecelerating: Observable<Void> {
        return delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewWillBeginDecelerating(_:)))
            .observe(on: MainScheduler.instance)
            .map { _ in () }
    }

    var didEndDecelerating: Observable<Void> {
        return delegate.methodInvoked(#selector(UIScrollViewDelegate.scrollViewDidEndDecelerating(_:)))
            .observe(on: MainScheduler.instance)
            .map { _ in () }
    }
}

// MARK: - WeakBox Helper

/// 弱引用包装器，用于数组/字典中避免循环引用
private struct WeakBox<T: AnyObject> {
    weak var value: T?

    init(_ value: T) {
        self.value = value
    }
}

#endif
