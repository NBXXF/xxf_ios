//
//  XXFNavigationController.swift
//  xxf_ios
//
//  UINavigationController 的增强版，主要解决两个 iOS 经典痛点：
//
//  1. 栈内页面的「屏幕左边缘右滑返回」在业务隐藏系统 UINavigationBar 时经常失灵
//     —— `interactivePopGestureRecognizer.delegate` 要自己托管。
//  2. 当 NavigationController 被 `present` 出来作为模态页时，它的 **root VC**
//     没有栈下层可 pop，`interactivePopGestureRecognizer` 天然不工作,用户从
//     屏幕左边缘右滑也无法 dismiss 整个模态 —— 违反 iOS 用户肌肉记忆。
//
//  本类在作为 presented 根时注册一条 `UIScreenEdgePanGestureRecognizer`，
//  配合 `UIPercentDrivenInteractiveTransition` 做跟手横向滑出动画;一旦
//  push 进子页面,该手势自动让位给系统的 `interactivePopGestureRecognizer`，
//  保持栈深层页面的原生体验。
//
//  不侵入业务转场:如果外部设置了自己的 `transitioningDelegate`（例如
//  自定义 modal 弹出动画),可通过 `wrappedTransitioningDelegate` 透传;
//  本类只在「边缘手势主动触发 dismiss」那一刻接管转场,其余时刻保持默认。
//
//  用法(直接实例化,无需子类化;常用定制项全部通过 public 属性暴露):
//
//      let nav = XXFNavigationController(rootViewController: vc)
//      presentingVC.present(nav, animated: true)
//
//  可选定制：
//
//      // 1) 某些 root VC 必须完成某状态前不允许边缘 dismiss —— 走 iOS 原生语义
//      nav.isModalInPresentation = true
//
//      // 2) 业务已有自定义 modal 转场动画,但仍想保留边缘 dismiss 手势
//      //    本类仅接管「边缘手势触发」的 dismiss 动画,其余（present / 普通 dismiss /
//      //    presentationController / interaction for presentation）全部透传给下面这个 delegate
//      nav.wrappedTransitioningDelegate = myCustomTransitionDelegate
//
//      // 3) 彻底关掉本类注册的边缘 dismiss 手势
//      nav.enablesPresentedEdgeDismiss = false
//
//      // 4) 触发敏感度调参
//      nav.presentedEdgeDismissProgressThreshold = 0.25   // 滑过 1/4 屏宽即判完成（默认 0.33）
//      nav.presentedEdgeDismissVelocityThreshold = 500    // 甩得更轻也能触发（默认 800 pt/s）
//      nav.presentedEdgeDismissDuration = 0.25            // 滑出动画更短（默认 0.3s）
//
//      // 5) 子类化：需要精细策略（如「某几个 root VC 进入特定状态前不允许滑关」），
//      //    override 以下方法返回 false 即可；本类已将其标为 open
//      override func canPerformPresentedEdgeDismiss() -> Bool {
//          guard super.canPerformPresentedEdgeDismiss() else { return false }
//          return yourBusinessGateIsOpen
//      }
//
//  Created by xxf.
//

#if canImport(UIKit)
import UIKit

// MARK: - XXFNavigationController

/// 通用 NavigationController，解决 presented 根 VC 无法边缘滑动 dismiss 的问题
open class XXFNavigationController: UINavigationController {

    // MARK: Public Configuration

    /// 作为 presented 根时是否启用「左边缘右滑 dismiss」手势，默认 true
    /// - 若业务使用了自定义 modal 转场且不希望被接管，设为 false
    /// - 当 `isModalInPresentation == true` 时也会被强制忽略（遵循系统语义）
    public var enablesPresentedEdgeDismiss: Bool = true {
        didSet { presentedEdgeGesture?.isEnabled = enablesPresentedEdgeDismiss }
    }

    /// 判定 dismiss 完成的 progress 阈值，默认 0.33（滑过 1/3 屏宽即成立）
    public var presentedEdgeDismissProgressThreshold: CGFloat = 0.33

    /// 判定 dismiss 完成的 velocity 阈值（points/s），默认 800
    /// - progress 达不到阈值时，只要手速足够快也触发 finish
    public var presentedEdgeDismissVelocityThreshold: CGFloat = 800

    /// 滑出动画时长，默认 0.3s
    public var presentedEdgeDismissDuration: TimeInterval = 0.3

    /// 外部转场代理：本类只接管 dismiss 动画，其余（present / presentationController
    /// / interaction for presentation）全部转发给此代理；设置为 nil 走系统默认
    public weak var wrappedTransitioningDelegate: UIViewControllerTransitioningDelegate?

    // MARK: Internals

    private lazy var edgeDismissInteractor = PresentedEdgeDismissInteractor()
    private var presentedEdgeGesture: UIScreenEdgePanGestureRecognizer?

    // MARK: Lifecycle

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
        commonInit()
    }

    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }

    override public init(navigationBarClass: AnyClass?, toolbarClass: AnyClass?) {
        super.init(navigationBarClass: navigationBarClass, toolbarClass: toolbarClass)
        commonInit()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        // 让本类既做转场代理（以便接管 dismiss 动画），也做 nav 自身的委托
        // 同时把 interactivePop 的代理拿过来，避免隐藏系统 bar 后手势失灵
        transitioningDelegate = self
    }

    override open func viewDidLoad() {
        super.viewDidLoad()

        // 系统 pop 手势托管：仅在栈深度 > 1 时启用，防止隐藏系统 bar 后失灵
        interactivePopGestureRecognizer?.delegate = self

        // 业务未另外设置 delegate 时兜底绑到自身，确保能收到 didShow 同步状态
        if delegate == nil {
            delegate = self
        }

        installPresentedEdgeDismissGestureIfNeeded()
    }

    // MARK: Gesture Install

    private func installPresentedEdgeDismissGestureIfNeeded() {
        // 重复安装保护
        guard presentedEdgeGesture == nil else { return }
        let gesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handlePresentedEdgePan(_:))
        )
        gesture.edges = .left
        gesture.delegate = self
        gesture.isEnabled = enablesPresentedEdgeDismiss
        view.addGestureRecognizer(gesture)
        presentedEdgeGesture = gesture
    }

    @objc private func handlePresentedEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        let translation = gesture.translation(in: view).x
        let width = max(view.bounds.width, 1)
        let progress = max(0, min(1, translation / width))

        switch gesture.state {
        case .began:
            // 标记交互开始，转场查询 interaction controller 时我们才返回自己
            edgeDismissInteractor.isInteracting = true
            // 触发 dismiss，系统会回调 transitioningDelegate 拿到我们的动画 + 交互控制器
            dismiss(animated: true)

        case .changed:
            edgeDismissInteractor.update(progress)

        case .ended:
            let velocity = gesture.velocity(in: view).x
            let shouldFinish = progress > presentedEdgeDismissProgressThreshold
                || velocity > presentedEdgeDismissVelocityThreshold
            if shouldFinish {
                edgeDismissInteractor.finish()
            } else {
                edgeDismissInteractor.cancel()
            }

        case .cancelled, .failed:
            edgeDismissInteractor.cancel()

        default:
            break
        }
    }

    // MARK: Edge Dismiss Eligibility

    /// 判断当前是否满足「边缘滑动 dismiss」条件
    /// 子类可 override 细化策略（例如某些 root VC 不允许）
    open func canPerformPresentedEdgeDismiss() -> Bool {
        guard enablesPresentedEdgeDismiss else { return false }
        guard presentingViewController != nil else { return false }
        guard viewControllers.count == 1 else { return false }
        if #available(iOS 13.0, *), isModalInPresentation { return false }
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension XXFNavigationController: UIGestureRecognizerDelegate {

    open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        // 系统 pop 手势：仅当栈深度 > 1 才放行，防止隐藏系统 bar 后越界触发
        if gestureRecognizer === interactivePopGestureRecognizer {
            return viewControllers.count > 1
        }
        // 自定义边缘 dismiss：仅在作为 presented 根、且业务未关闭时放行
        if gestureRecognizer === presentedEdgeGesture {
            return canPerformPresentedEdgeDismiss()
        }
        return true
    }

    /// 让 ScrollView 水平 pan 为边缘手势让路，避免列表页边缘滑返失灵
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                                shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        let isOurs = gestureRecognizer === interactivePopGestureRecognizer
            || gestureRecognizer === presentedEdgeGesture
        guard isOurs, otherGestureRecognizer is UIPanGestureRecognizer else { return false }
        return true
    }
}

// MARK: - UINavigationControllerDelegate (default wiring)

extension XXFNavigationController: UINavigationControllerDelegate {
    open func navigationController(_ navigationController: UINavigationController,
                                   didShow viewController: UIViewController,
                                   animated: Bool) {
        // 部分 iOS 版本转场中会重置 interactivePop 启用状态，完成后再校准
        interactivePopGestureRecognizer?.isEnabled = viewControllers.count > 1
    }
}

// MARK: - UIViewControllerTransitioningDelegate (proxying)

extension XXFNavigationController: UIViewControllerTransitioningDelegate {

    open func animationController(forPresented presented: UIViewController,
                                  presenting: UIViewController,
                                  source: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        // 我们不接管 present 动画；若业务自带转场代理则透传，否则系统默认
        wrappedTransitioningDelegate?.animationController?(
            forPresented: presented, presenting: presenting, source: source
        )
    }

    open func animationController(forDismissed dismissed: UIViewController)
        -> UIViewControllerAnimatedTransitioning? {
        // 仅当我们的边缘手势主动发起 dismiss 时返回自定义横向动画
        if edgeDismissInteractor.isInteracting {
            return PresentedEdgeDismissAnimator(duration: presentedEdgeDismissDuration)
        }
        return wrappedTransitioningDelegate?.animationController?(forDismissed: dismissed)
    }

    open func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        wrappedTransitioningDelegate?.interactionControllerForPresentation?(using: animator)
    }

    open func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
        if edgeDismissInteractor.isInteracting {
            return edgeDismissInteractor
        }
        return wrappedTransitioningDelegate?.interactionControllerForDismissal?(using: animator)
    }

    open func presentationController(forPresented presented: UIViewController,
                                     presenting: UIViewController?,
                                     source: UIViewController)
        -> UIPresentationController? {
        wrappedTransitioningDelegate?.presentationController?(
            forPresented: presented, presenting: presenting, source: source
        )
    }
}

// MARK: - PresentedEdgeDismissInteractor

/// 包装 UIPercentDrivenInteractiveTransition，额外记录「是否正在交互」以便转场代理按需返回
private final class PresentedEdgeDismissInteractor: UIPercentDrivenInteractiveTransition {
    var isInteracting = false

    override func finish() {
        super.finish()
        isInteracting = false
    }

    override func cancel() {
        super.cancel()
        isInteracting = false
    }
}

// MARK: - PresentedEdgeDismissAnimator

/// 将 presenting nav 的 view 沿 X 轴整体滑出屏幕右侧
private final class PresentedEdgeDismissAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let duration: TimeInterval

    init(duration: TimeInterval) {
        self.duration = duration
    }

    func transitionDuration(using _: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }

    func animateTransition(using ctx: UIViewControllerContextTransitioning) {
        guard let fromView = ctx.view(forKey: .from) ?? ctx.viewController(forKey: .from)?.view else {
            ctx.completeTransition(false)
            return
        }
        let container = ctx.containerView

        // 关键：`.fullScreen` / `.automatic` present 时，iOS 会把 presenting VC 的 view 从
        // window 层级摘掉节省渲染；dismiss 默认由系统自己负责把它塞回去。我们自定义了
        // dismiss 动画后，系统就不管了；若不自己补回 toView，底下露出的就是黑屏。
        // `.overFullScreen` / sheet 类样式下 toView 已经在 container 里，insertSubview
        // 会平移不会复制，依然安全。
        if let toView = ctx.view(forKey: .to) ?? ctx.viewController(forKey: .to)?.view {
            if toView.superview !== container {
                toView.frame = ctx.finalFrame(for: ctx.viewController(forKey: .to)!)
                container.insertSubview(toView, belowSubview: fromView)
            }
        }

        let targetX = container.bounds.width

        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseOut],
            animations: {
                fromView.transform = CGAffineTransform(translationX: targetX, y: 0)
            },
            completion: { _ in
                let finished = !ctx.transitionWasCancelled
                // 取消时需把 transform 复位，否则回弹后页面位置错乱
                if !finished {
                    fromView.transform = .identity
                }
                ctx.completeTransition(finished)
            }
        )
    }
}

#endif
