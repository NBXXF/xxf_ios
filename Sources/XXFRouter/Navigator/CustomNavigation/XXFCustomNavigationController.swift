//
//  XXFCustomNavigationController.swift
//  xxf_ios
//
//  Created by xxf on 5/21.
//

#if canImport(UIKit)
import UIKit

// MARK: - XXFCustomNavigationController

/// 自绘导航栏版 `XXFNavigationController`。
///
/// 设计思想：
///
/// 1. `UINavigationController` 只负责栈、转场和手势，视觉导航栏完全由 `customNavigationBar` 自绘。
///    - 系统 `UINavigationBar` 在本类中必须始终隐藏。
///    - `viewDidLoad`、布局、栈变化、`willShow/didShow` 都会重新兜底隐藏系统 bar，避免业务页面把系统 bar 改回可见后出现白条。
///
/// 2. 对业务保持 UIKit 原有接入方式，不新增页面侧协议。
///    - 页面继续使用 `navigationController?.setNavigationBarHidden(...)`、`title`、`navigationItem`、`UIBarButtonItem`。
///    - 不定义 `Configurable`、`BackInterceptable` 这类系统没有的页面协议，避免业务接入成本和语义分叉。
///    - 需要定制视觉时，通过覆盖 `makeCustomNavigationBar()` 或直接定制 `customNavigationBar`，不让页面协议污染导航语义。
///
/// 3. `navigationItem` 是唯一导航内容数据源。
///    - 标题读取 `navigationItem.title` / `viewController.title` / `navigationItem.titleView`。
///    - 左右按钮读取 `leftBarButtonItem(s)` / `rightBarButtonItem(s)`。
///    - 返回按钮显隐读取 `navigationItem.hidesBackButton` 和 `leftItemsSupplementBackButton`。
///    - `titleView` / `UIBarButtonItem.customView` 不复制，直接移动同一个 view 到自绘 bar 中；外部异步修改 view 内部状态会自然生效。
///
/// 4. 外部延迟/异步设置要自动生效。
///    - UIKit 这些属性不能依赖 KVO 稳定通知，所以本类安装一次 UIKit setter hook。
///    - `UIViewController.title`、`UINavigationItem` 导航字段、`UIBarButtonItem` 可见/行为字段发生 setter 修改时会发内部通知。
///    - 当前 top view controller、当前 `navigationItem`、当前左右 `UIBarButtonItem` 的修改会合并到主线程下一轮 `syncCustomNavigationBar(animated: false)`。
///    - `syncCustomNavigationBar(animated:)` 只是兜底公开方法，不要求业务每次异步修改后手动调用。
///
/// 5. 外部 `navigationController.delegate` 不能覆盖内部同步链路。
///    - 本类保持 `super.delegate === self`，并把外部设置的 delegate 存为转发对象。
///    - `willShow/didShow` 会先让外部 delegate 有机会修改 `navigationItem`，再兜底隐藏系统 bar 并同步自绘 bar。
///
/// 兼容边界：
///
/// 1. 明确兼容的 UIKit 入口：
///    - `setNavigationBarHidden(_:animated:)` / `isNavigationBarHidden`：语义映射到自绘 bar；系统 bar 仍强制隐藏。
///    - 栈变更：`setViewControllers`、`push`、`pop`、`popToViewController`、`popToRootViewController` 后都会同步自绘 bar。
///    - 标题：`UIViewController.title`、`navigationItem.title`、`navigationItem.titleView`。
///    - 左右按钮：`leftBarButtonItem(s)`、`rightBarButtonItem(s)`、`leftItemsSupplementBackButton`。
///    - 返回显隐：`navigationItem.hidesBackButton` / `setHidesBackButton(_:animated:)`。
///    - `UIBarButtonItem` 基础字段：`customView`、`title`、`image`、`isEnabled`、`tintColor`、`width`、`menu`、`primaryAction`、`target`、`action`。
///    - `UIBarButtonItem` 标题样式：`titleTextAttributes(for: .normal/.highlighted/.disabled)`，以及后续 `setTitleTextAttributes(_:for:)` 的异步同步。
///
/// 2. 明确不兼容 / 不承诺完整复刻的系统导航栏能力：
///    - 直接操作 `navigationController?.navigationBar.*` 的视觉定制不会映射到自绘 bar。
///    - 包括但不限于 `standardAppearance`、`scrollEdgeAppearance`、`compactAppearance`、`tintColor`、`barTintColor`、阴影线、`backIndicatorImage`、系统 bar 子视图。
///    - `prefersLargeTitles`、`largeTitleDisplayMode`、`navigationItem.searchController`、`prompt` 不在当前自绘 bar 的兼容范围内。
///    - `backBarButtonItem`、`backButtonTitle`、`backButtonDisplayMode`、系统返回按钮长按栈菜单不做系统级复刻。
///    - `UIBarButtonItem.SystemItem` 原始类型没有公开反查 API；没有 title/image 但有 action/menu 的 item 只做兜底图标，不能保证和系统图标完全一致。
///    - `possibleTitles`、横屏专用图片、系统 bar 内部间距等细节不承诺完全一致。
///
/// 3. 自定义 view 的尺寸约束：
///    - `titleView` / `customView` 优先按 Auto Layout、intrinsicContentSize、已有 frame 推导尺寸。
///    - 若外部后续只改 frame 来改变尺寸，Auto Layout 不一定能感知；建议让 view 自身提供约束 / intrinsic size，必要时调用 `syncCustomNavigationBar()` 兜底。
open class XXFCustomNavigationController: XXFNavigationController {

    // MARK: Public Properties

    /// 自绘导航栏实例。
    ///
    /// 子类可通过覆盖 `makeCustomNavigationBar()` 替换具体实现；外部只能读取，避免运行中被替换导致约束和同步状态失配。
    public private(set) lazy var customNavigationBar: XXFCustomNavigationBar = makeCustomNavigationBar()

    /// 自绘导航栏内容区高度，默认对齐系统导航栏常规高度 44pt。
    ///
    /// 修改后会同时更新自绘 bar 的布局高度、当前页面的 safe area 补偿，并触发一次同步。
    open var customNavigationBarContentHeight: CGFloat = XXFCustomNavigationBar.defaultContentHeight {
        didSet {
            customNavigationBar.contentHeight = customNavigationBarContentHeight
            customNavigationBarBottomConstraint?.constant = customNavigationBarContentHeight
            syncCustomNavigationBar(animated: false)
        }
    }

    /// `setNavigationBarHidden(_:animated:)` 映射到自绘 bar 时使用的淡入淡出动画时长。
    open var customNavigationBarAnimationDuration: TimeInterval = 0.12

    /// 对外保持 `UINavigationController.delegate` 语义，同时内部始终持有真正的 delegate 链路。
    ///
    /// UIKit 的 `delegate` 是单一对象；本类需要自己接收 `willShow/didShow` 做同步，所以外部设置的 delegate
    /// 会被保存为 `externalNavigationDelegate` 并由本类转发。
    override open var delegate: UINavigationControllerDelegate? {
        get { externalNavigationDelegate ?? super.delegate }
        set {
            if let newValue, newValue === self {
                super.delegate = newValue
                return
            }
            externalNavigationDelegate = newValue
            super.delegate = self
        }
    }

    /// 映射自绘导航栏的隐藏状态。
    ///
    /// 系统 `UINavigationBar` 在本类中始终隐藏，因此这里返回的是 `customNavigationBar` 的逻辑隐藏状态。
    override open var isNavigationBarHidden: Bool {
        get { currentCustomNavigationBarHidden }
        set { setNavigationBarHidden(newValue, animated: false) }
    }

    // MARK: Private Properties

    /// 外部业务设置的 navigation delegate。
    ///
    /// 使用 weak 遵循 UIKit delegate 约定，避免导航控制器与业务 delegate 互相持有。
    private weak var externalNavigationDelegate: UINavigationControllerDelegate?

    /// 自绘导航栏底部约束，用于跟随 `customNavigationBarContentHeight` 动态调整内容高度。
    private var customNavigationBarBottomConstraint: NSLayoutConstraint?

    /// 外部通过 `setNavigationBarHidden` 请求的自绘 bar 隐藏状态。
    ///
    /// 和 `super.isNavigationBarHidden` 分开记录，因为系统 bar 必须始终隐藏。
    private var customNavigationBarHiddenByAPI = false

    /// 当前已经应用到 `customNavigationBar` 的隐藏状态，用于 `isNavigationBarHidden` 读取。
    private var currentCustomNavigationBarHidden = false

    /// 合并连续 navigationItem / barButtonItem setter 通知的标记，避免同一轮 RunLoop 内重复同步。
    private var isSyncScheduled = false

    /// UIKit setter hook 发出的内部通知 observer token。
    nonisolated(unsafe)
    private var navigationMutationObserver: NSObjectProtocol?

    /// 临时桥接 `Notification.object` 的非 Sendable 类型。
    private struct NavigationMutationSource: @unchecked Sendable {
        let value: Any?
    }

    /// 记录每个页面由本类额外追加的 top safe area，避免覆盖业务自己设置的 `additionalSafeAreaInsets.top`。
    private var appliedTopInsetAdditions: [ObjectIdentifier: CGFloat] = [:]

    // MARK: Lifecycle

    /// 初始化自绘导航栏、安装 setter hook，并强制隐藏系统导航栏。
    override open func viewDidLoad() {
        XXFCustomNavigationMutationInstaller.installIfNeeded()
        super.viewDidLoad()
        super.delegate = self
        installNavigationMutationObserverIfNeeded()
        hideSystemNavigationBarIfNeeded()
        setupCustomNavigationBar()
        syncCustomNavigationBar(animated: false)
    }

    /// 释放内部通知监听。
    deinit {
        if let navigationMutationObserver {
            NotificationCenter.default.removeObserver(navigationMutationObserver)
        }
    }

    /// 布局后再次兜底隐藏系统 bar，并确保自绘 bar 位于导航控制器 view 的最上层。
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        hideSystemNavigationBarIfNeeded()
        view.bringSubviewToFront(customNavigationBar)
    }

    /// 让 UIKit 在查询 delegate 可选方法时，同时看到外部 delegate 支持的方法。
    override open func responds(to aSelector: Selector!) -> Bool {
        if super.responds(to: aSelector) {
            return true
        }
        return externalNavigationDelegate?.responds(to: aSelector) ?? false
    }

    /// 将本类未实现但外部 delegate 实现的可选方法转发出去。
    override open func forwardingTarget(for aSelector: Selector!) -> Any? {
        if let externalNavigationDelegate,
           externalNavigationDelegate.responds(to: aSelector) {
            return externalNavigationDelegate
        }
        return super.forwardingTarget(for: aSelector)
    }

    // MARK: System Navigation Bar Compatibility

    /// 兼容系统隐藏导航栏 API。
    ///
    /// 外部调用该方法时只影响自绘导航栏；系统 `UINavigationBar` 会继续保持隐藏。
    override open func setNavigationBarHidden(_ hidden: Bool, animated: Bool) {
        customNavigationBarHiddenByAPI = hidden
        currentCustomNavigationBarHidden = hidden
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return }
        syncCustomNavigationBar(animated: animated)
    }

    /// 栈整体替换后同步自绘导航栏内容。
    override open func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return }
        syncCustomNavigationBar(animated: animated)
    }

    /// push 后同步目标页面的自绘导航栏内容。
    override open func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return }
        syncCustomNavigationBar(animated: animated)
    }

    /// pop 后同步新的 top view controller 的自绘导航栏内容。
    override open func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return poppedViewController }
        syncCustomNavigationBar(animated: animated)
        return poppedViewController
    }

    /// pop 到指定页面后同步该页面的自绘导航栏内容。
    override open func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToViewController(viewController, animated: animated)
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return poppedViewControllers }
        syncCustomNavigationBar(animated: animated)
        return poppedViewControllers
    }

    /// pop 到根页面后同步根页面的自绘导航栏内容。
    override open func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let poppedViewControllers = super.popToRootViewController(animated: animated)
        hideSystemNavigationBarIfNeeded()
        guard isViewLoaded else { return poppedViewControllers }
        syncCustomNavigationBar(animated: animated)
        return poppedViewControllers
    }

    // MARK: Public Methods

    /// 创建自绘导航栏实例。
    ///
    /// 子类需要替换导航栏样式时覆盖该方法，不要运行中直接替换 `customNavigationBar`。
    open func makeCustomNavigationBar() -> XXFCustomNavigationBar {
        XXFCustomNavigationBar()
    }

    /// 手动触发自绘导航栏同步。
    ///
    /// 正常情况下 setter hook 会自动同步；该方法主要作为 frame-only 自定义 view 或特殊业务时机的兜底入口。
    open func syncCustomNavigationBar(animated: Bool = false) {
        guard let topViewController else { return }
        applyCustomNavigationBar(for: topViewController, animated: animated)
    }

    /// 返回自绘导航栏右侧第 `index` 个按钮对应的真实 view。
    ///
    /// 若按钮由 `UIBarButtonItem.customView` 提供，会返回原始 custom view，适合作为菜单/popover 锚点。
    open func customNavigationBarRightItemView(at index: Int) -> UIView? {
        customNavigationBar.rightItemView(at: index)
    }

    /// 返回自绘导航栏左侧第 `index` 个按钮对应的真实 view。
    open func customNavigationBarLeftItemView(at index: Int) -> UIView? {
        customNavigationBar.leftItemView(at: index)
    }

    /// 判断当前页面是否应该显示默认自绘返回按钮。
    ///
    /// 栈内子页面和 presented 根页面都可以显示返回入口；页面设置 `hidesBackButton` 时遵循 UIKit 语义隐藏。
    open func shouldShowCustomNavigationBackButton(for viewController: UIViewController) -> Bool {
        let isModalRoot = viewControllers.count == 1 && presentingViewController != nil
        let canGoBack = viewControllers.count > 1 || isModalRoot
        return canGoBack && !viewController.navigationItem.hidesBackButton
    }

    /// 处理默认自绘返回按钮点击。
    ///
    /// 栈深大于 1 时 pop；presented 根页面时 dismiss 整个 navigation controller。
    open func handleCustomNavigationBack(for viewController: UIViewController) {
        if viewControllers.count > 1 {
            _ = popViewController(animated: true)
        } else {
            dismiss(animated: true)
        }
    }

    /// 将指定页面的 `navigationItem` 状态应用到自绘导航栏。
    ///
    /// 这是实际同步入口：负责隐藏状态、返回按钮、左右按钮、标题和 safe area 补偿。
    open func applyCustomNavigationBar(for viewController: UIViewController, animated: Bool) {
        hideSystemNavigationBarIfNeeded()

        let hidden = customNavigationBarHiddenByAPI
        let showBack = !hidden && shouldShowCustomNavigationBackButton(for: viewController)

        let updates = {
            self.currentCustomNavigationBarHidden = hidden
            self.customNavigationBar.isHidden = hidden
            self.customNavigationBar.alpha = hidden ? 0 : 1
            self.customNavigationBar.isUserInteractionEnabled = !hidden
            self.updateAdditionalSafeAreaInsets(for: viewController, customNavigationBarHidden: hidden)

            guard !hidden else { return }

            self.customNavigationBar.configure(
                topViewController: viewController,
                showBack: showBack
            ) { [weak self, weak viewController] in
                guard let self, let viewController else { return }
                self.handleCustomNavigationBack(for: viewController)
            }
        }

        if animated {
            UIView.transition(
                with: customNavigationBar,
                duration: customNavigationBarAnimationDuration,
                options: [.transitionCrossDissolve, .allowUserInteraction],
                animations: updates
            )
        } else {
            updates()
        }
    }

    // MARK: UINavigationControllerDelegate

    /// `willShow` 阶段先转发给外部 delegate，再按外部可能更新后的 `navigationItem` 同步自绘 bar。
    open func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        guard navigationController === self else { return }
        externalNavigationDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        hideSystemNavigationBarIfNeeded()
        applyCustomNavigationBar(for: viewController, animated: animated)
    }

    /// `didShow` 阶段校准交互返回状态和自绘导航栏最终状态。
    override open func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        super.navigationController(navigationController, didShow: viewController, animated: animated)
        guard navigationController === self else { return }
        externalNavigationDelegate?.navigationController?(navigationController, didShow: viewController, animated: animated)
        hideSystemNavigationBarIfNeeded()
        applyCustomNavigationBar(for: viewController, animated: false)
    }

    // MARK: Private Methods

    /// 将自绘导航栏安装到 navigation controller view 顶部。
    private func setupCustomNavigationBar() {
        customNavigationBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customNavigationBar)

        let bottomConstraint = customNavigationBar.bottomAnchor.constraint(
            equalTo: view.safeAreaLayoutGuide.topAnchor,
            constant: customNavigationBarContentHeight
        )
        customNavigationBarBottomConstraint = bottomConstraint

        NSLayoutConstraint.activate([
            customNavigationBar.topAnchor.constraint(equalTo: view.topAnchor),
            customNavigationBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavigationBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomConstraint
        ])
        view.bringSubviewToFront(customNavigationBar)
    }

    /// 强制隐藏系统导航栏。
    ///
    /// 使用 `super` 写入隐藏状态，同时直接设置 `navigationBar.isHidden` 做兜底，避免业务或 UIKit 转场中恢复显示。
    private func hideSystemNavigationBarIfNeeded() {
        if !super.isNavigationBarHidden {
            super.setNavigationBarHidden(true, animated: false)
        }
        navigationBar.isHidden = true
    }

    /// 安装内部导航内容变更通知监听。
    private func installNavigationMutationObserverIfNeeded() {
        guard navigationMutationObserver == nil else { return }
        navigationMutationObserver = NotificationCenter.default.addObserver(
            forName: .xxfCustomNavigationSourceDidChange,
            object: nil,
            queue: nil
        ) { [weak self] notification in
            self?.handleNavigationMutation(from: NavigationMutationSource(value: notification.object))
        }
    }

    /// 接收 setter hook 通知，并确保后续处理切回主线程。
    @MainActor
    private func handleNavigationMutation(from source: NavigationMutationSource) {
        if Thread.isMainThread {
            handleNavigationMutationOnMain(from: source.value)
            return
        }

        DispatchQueue.main.async { [weak self] in
            self?.handleNavigationMutationOnMain(from: source.value)
        }
    }

    /// 在主线程判断通知来源是否属于当前 top 页面，并安排一次合并同步。
    private func handleNavigationMutationOnMain(from source: Any?) {
        guard isCurrentNavigationSource(source) else { return }
        scheduleCustomNavigationBarSync()
    }

    /// 判断 setter hook 的通知来源是否影响当前显示中的自绘导航栏。
    private func isCurrentNavigationSource(_ source: Any?) -> Bool {
        guard let topViewController else { return false }

        if let sourceViewController = source as? UIViewController {
            return sourceViewController === topViewController
        }
        if let sourceItem = source as? UINavigationItem {
            return sourceItem === topViewController.navigationItem
        }
        if let sourceBarButtonItem = source as? UIBarButtonItem {
            return currentBarButtonItems(for: topViewController).contains { $0 === sourceBarButtonItem }
        }
        return false
    }

    /// 收集当前页面正在参与渲染的左右 `UIBarButtonItem`。
    private func currentBarButtonItems(for viewController: UIViewController) -> [UIBarButtonItem] {
        let item = viewController.navigationItem
        let leftItems = item.leftBarButtonItems ?? item.leftBarButtonItem.map { [$0] } ?? []
        let rightItems = item.rightBarButtonItems ?? item.rightBarButtonItem.map { [$0] } ?? []
        return leftItems + rightItems
    }

    /// 将多次 setter 通知合并到主线程下一轮执行，避免连续设置 title/buttons 时重复布局。
    private func scheduleCustomNavigationBarSync() {
        guard isViewLoaded, !isSyncScheduled else { return }
        isSyncScheduled = true
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.isSyncScheduled = false
            self.syncCustomNavigationBar(animated: false)
        }
    }

    /// 更新当前页面的 top safe area 补偿。
    ///
    /// 只调整本类自己追加的高度，保留业务页面已有的 `additionalSafeAreaInsets.top`。
    private func updateAdditionalSafeAreaInsets(
        for viewController: UIViewController,
        customNavigationBarHidden: Bool
    ) {
        let identifier = ObjectIdentifier(viewController)
        let previousAddition = appliedTopInsetAdditions[identifier] ?? 0
        let currentTopInset = viewController.additionalSafeAreaInsets.top
        let baseTopInset = currentTopInset - previousAddition
        let targetAddition = customNavigationBarHidden ? 0 : customNavigationBarContentHeight
        let targetTopInset = baseTopInset + targetAddition

        guard abs(viewController.additionalSafeAreaInsets.top - targetTopInset) > CGFloat.ulpOfOne else {
            appliedTopInsetAdditions[identifier] = targetAddition
            return
        }

        var insets = viewController.additionalSafeAreaInsets
        insets.top = targetTopInset
        viewController.additionalSafeAreaInsets = insets
        appliedTopInsetAdditions[identifier] = targetAddition
    }
}
#endif
