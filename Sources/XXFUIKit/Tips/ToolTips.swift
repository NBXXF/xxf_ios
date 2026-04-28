//
//  ToolTips.swift
//  nexus
//
//  锚点动作气泡（带箭头）
//
//  规则（避免后续改错）：
//  1) 业务默认只用 show(from:text:onTap:)；复杂需求走 configuration。
//  2) bubbleFillLayer 必须 insertSublayer(at: 0)，否则会盖住文案。
//  3) shadowPath 必须与气泡 path 完全一致，避免箭头/圆角阴影断裂。
//  4) 外部点击关闭有激活延迟，防止长按松手立即误关。
//
#if canImport(UIKit)
import QuartzCore
import SnapKit
import UIKit
import XXFFoundation

/// 锚点动作气泡（带箭头）。
/// 提供两层 API：
/// 1) 简单模式：`show(from:text:onTap:)`
/// 2) 可配置模式：`show(from:text:configuration:onTap:onDismiss:)`
open class ToolTips: UIView {
    public enum PreferredPlacement {
        /// 自动根据上下可用空间决定显示在 anchor 上方或下方。
        case automatic
        /// 优先显示在 anchor 上方（空间不够时自动回退）。
        case preferAboveAnchor
        /// 优先显示在 anchor 下方（空间不够时自动回退）。
        case preferBelowAnchor
    }

    public struct LayoutConfiguration {
        /// 相对屏幕安全区的左右最小间距。
        public var horizontalMargin: CGFloat = 8.pt
        /// 相对屏幕安全区的上下最小间距。
        public var verticalMargin: CGFloat = 8.pt
        /// 气泡与锚点间距。
        public var anchorGap: CGFloat = 8.pt
        public var cornerRadius: CGFloat = 14.pt
        /// 不含箭头高度的气泡主内容高度。
        public var rowHeight: CGFloat = 48.pt
        public var arrowWidth: CGFloat = 14.pt
        public var arrowHeight: CGFloat = 8.pt
        /// 箭头与圆角边界的额外安全距离，避免贴边。
        public var arrowEdgePadding: CGFloat = 2.pt
        /// 文案内容内边距。
        public var contentInsets: UIEdgeInsets = .init(top: 0, left: 16.pt, bottom: 0, right: 16.pt)
        public var minWidth: CGFloat = 116.pt
        public var maxWidth: CGFloat = 240.pt
        public var preferredPlacement: PreferredPlacement = .automatic

        public init() {}
    }

    public struct AppearanceConfiguration {
        public var backgroundColor: UIColor = UIColor.white
        /// 默认文本样式来自 SPM（ToolTipsTextStyle）。
        public var textColor: UIColor = ToolTipsTextStyle.defaultTextColor
        public var font: UIFont = ToolTipsTextStyle.defaultFont
        public var textAlignment: NSTextAlignment = .center
        /// 点击按下态背景色（作用于 actionControl）。
        public var highlightColor: UIColor = PlatformColor(hex: 0x000000, alpha: 0.06)
        /// Figma: Drop shadow / Y=-6 / Blur=40 / Spread=0 / Color=Neutral/Black6(黑 6% alpha)
        public var shadowColor: UIColor = PlatformColor(hex: 0x000000, alpha: 0.06)
        public var shadowOffset: CGSize = .init(width: 0, height: -6.pt)
        public var shadowRadius: CGFloat = 40.pt
        public var shadowOpacity: Float = 1

        public init() {}
    }

    public struct InteractionConfiguration {
        /// true: 点击外部自动关闭。
        public var dismissOnOutsideTap: Bool = true
        /// true: 拦截外部点击；false: 外部点击可透传到下层视图。
        public var swallowOutsideTouches: Bool = true
        /// 长按松手后，外部点击生效延迟。
        public var outsideTapActivationDelay: CFTimeInterval = 0.25
        public var presentAnimationDuration: TimeInterval = 0.18
        public var dismissAnimationDuration: TimeInterval = 0.16
        public var presentDismissOffset: CGFloat = 6.pt

        public init() {}
    }

    public struct Configuration {
        public var layout: LayoutConfiguration = .init()
        public var appearance: AppearanceConfiguration = .init()
        public var interaction: InteractionConfiguration = .init()
        /// 用于 UI 自动化定位点击区域。
        public var accessibilityIdentifier: String? = "tool_tips_button"

        public static var defaultStyle: Configuration {
            .init()
        }

        @available(*, deprecated, renamed: "defaultStyle")
        public static var deleteStickerDefault: Configuration {
            defaultStyle
        }

        public init() {}
    }

    private enum ArrowDirection {
        case up
        case down
    }

    private let configuration: Configuration

    private let shadowContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let bubbleContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()

    private let actionControl: HighlightControl

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        return label
    }()

    private let bubbleFillLayer = CAShapeLayer()

    private weak var anchorView: UIView?
    private var actionHandler: (() -> Void)?
    private var dismissHandler: (() -> Void)?
    private var actionText: String = ""
    private var direction: ArrowDirection = .down
    private var arrowLocalX: CGFloat = 0

    private var lastAnchorFrame: CGRect = .zero
    private var lastOverlayBounds: CGRect = .zero
    private var lastSafeInsets: UIEdgeInsets = .zero
    private var outsideDismissWorkItem: DispatchWorkItem?
    private var isDismissing = false
    private var outsideTapEnabledAt: CFTimeInterval = 0
    private var hasTriggeredDismissHandler = false

    // MARK: - Init

    private init(configuration: Configuration) {
        self.configuration = configuration
        actionControl = HighlightControl(highlightColor: configuration.appearance.highlightColor)
        super.init(frame: .zero)
        setupUI()
        applyConfiguration()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    isolated deinit {
        outsideDismissWorkItem?.cancel()
    }

    open override func layoutSubviews() {
        super.layoutSubviews()
        updatePlacementIfNeeded()
    }

    // MARK: - Public API

    /// 简单模式：业务只传锚点、文案、点击回调。
    @discardableResult
    public static func show(
        from anchorView: UIView,
        text: String,
        onTap: @escaping () -> Void
    ) -> ToolTips? {
        show(
            from: anchorView,
            text: text,
            configuration: .defaultStyle,
            onTap: onTap,
            onDismiss: nil
        )
    }

    /// 可配置模式：支持自定义布局、样式、交互。
    @discardableResult
    public static func show(
        from anchorView: UIView,
        text: String,
        customize: (inout Configuration) -> Void,
        onTap: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> ToolTips? {
        var configuration = Configuration.defaultStyle
        customize(&configuration)
        return show(
            from: anchorView,
            text: text,
            configuration: configuration,
            onTap: onTap,
            onDismiss: onDismiss
        )
    }

    /// 可配置模式：支持自定义布局、样式、交互。
    @discardableResult
    public static func show(
        from anchorView: UIView,
        text: String,
        configuration: Configuration,
        onTap: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) -> ToolTips? {
        guard let window = anchorView.window else { return nil }

        // 同一 window 只保留一个，避免叠层和点击链冲突。
        for subview in window.subviews {
            guard let existing = subview as? ToolTips else { continue }
            existing.dismiss(animated: false)
        }

        let overlay = ToolTips(configuration: configuration)
        overlay.anchorView = anchorView
        overlay.actionText = text
        overlay.actionHandler = onTap
        overlay.dismissHandler = onDismiss
        overlay.titleLabel.text = text
        overlay.actionControl.accessibilityLabel = text

        window.addSubview(overlay)
        overlay.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        window.layoutIfNeeded()
        overlay.present()
        return overlay
    }

    /// 动态更新文案并重算布局（例如多语言切换或状态文案变更）。
    public func update(text: String) {
        actionText = text
        titleLabel.text = text
        actionControl.accessibilityLabel = text
        lastAnchorFrame = .zero
        setNeedsLayout()
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard !isDismissing else { return }
        isDismissing = true
        outsideDismissWorkItem?.cancel()
        outsideDismissWorkItem = nil

        let end = { [weak self] in
            guard let self = self else { return }
            self.removeFromSuperview()
            self.triggerDismissHandlerIfNeeded()
            completion?()
        }

        guard animated else {
            end()
            return
        }

        let offset = configuration.interaction.presentDismissOffset
        let offsetY: CGFloat = direction == .down ? offset : -offset
        UIView.animate(
            withDuration: configuration.interaction.dismissAnimationDuration,
            delay: 0,
            options: [.curveEaseIn]
        ) {
            self.bubbleContainer.alpha = 0
            self.bubbleContainer.transform = CGAffineTransform(translationX: 0, y: offsetY).scaledBy(x: 0.96, y: 0.96)
        } completion: { _ in
            end()
        }
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .clear

        addSubview(shadowContainer)
        shadowContainer.addSubview(bubbleContainer)
        bubbleContainer.addSubview(actionControl)
        actionControl.addSubview(titleLabel)

        // 注意：背景层必须处于最底部，避免文案被遮挡。
        bubbleContainer.layer.insertSublayer(bubbleFillLayer, at: 0)

        actionControl.addTarget(self, action: #selector(onActionTapped), for: .touchUpInside)
        actionControl.accessibilityTraits = .button
    }

    private func applyConfiguration() {
        titleLabel.font = configuration.appearance.font
        titleLabel.textColor = configuration.appearance.textColor
        titleLabel.textAlignment = configuration.appearance.textAlignment
        actionControl.accessibilityIdentifier = configuration.accessibilityIdentifier

        shadowContainer.layer.shadowColor = configuration.appearance.shadowColor.cgColor
        shadowContainer.layer.shadowOffset = configuration.appearance.shadowOffset
        shadowContainer.layer.shadowRadius = configuration.appearance.shadowRadius
        shadowContainer.layer.shadowOpacity = configuration.appearance.shadowOpacity

        titleLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(configuration.layout.contentInsets.left)
            make.trailing.equalToSuperview().offset(-configuration.layout.contentInsets.right)
            make.top.equalToSuperview().offset(configuration.layout.contentInsets.top)
            make.bottom.equalToSuperview().offset(-configuration.layout.contentInsets.bottom)
        }
    }

    // MARK: - Event

    open override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let bubblePoint = bubbleContainer.convert(point, from: self)
        if bubbleContainer.bounds.contains(bubblePoint) {
            return super.hitTest(point, with: event)
        }

        if configuration.interaction.dismissOnOutsideTap,
           event != nil,
           CACurrentMediaTime() >= outsideTapEnabledAt
        {
            scheduleOutsideDismiss()
        }
        return configuration.interaction.swallowOutsideTouches ? self : nil
    }

    @objc private func onActionTapped() {
        let callback = actionHandler
        dismiss(animated: true) {
            callback?()
        }
    }

    private func scheduleOutsideDismiss() {
        outsideDismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismiss(animated: true)
        }
        outsideDismissWorkItem = workItem
        DispatchQueue.main.async(execute: workItem)
    }

    private func triggerDismissHandlerIfNeeded() {
        guard !hasTriggeredDismissHandler else { return }
        hasTriggeredDismissHandler = true
        dismissHandler?()
    }

    // MARK: - Layout

    private func present() {
        updatePlacementIfNeeded(force: true)
        // 规避长按松手时将同一手势误判为外部点击。
        outsideTapEnabledAt = CACurrentMediaTime() + configuration.interaction.outsideTapActivationDelay

        let offset = configuration.interaction.presentDismissOffset
        let offsetY: CGFloat = direction == .down ? offset : -offset
        bubbleContainer.alpha = 0
        bubbleContainer.transform = CGAffineTransform(translationX: 0, y: offsetY).scaledBy(x: 0.96, y: 0.96)
        UIView.animate(
            withDuration: configuration.interaction.presentAnimationDuration,
            delay: 0,
            options: [.curveEaseOut]
        ) {
            self.bubbleContainer.alpha = 1
            self.bubbleContainer.transform = .identity
        }
    }

    private func updatePlacementIfNeeded(force: Bool = false) {
        guard let anchorView,
              let anchorWindow = anchorView.window,
              anchorWindow == window
        else {
            dismiss(animated: false)
            return
        }

        let anchorFrame = anchorView.convert(anchorView.bounds, to: self)
        let currentBounds = bounds.integral
        let currentSafeInsets = safeAreaInsets
        guard force
            || anchorFrame.integral != lastAnchorFrame.integral
            || currentBounds != lastOverlayBounds
            || currentSafeInsets != lastSafeInsets
        else { return }
        lastAnchorFrame = anchorFrame
        lastOverlayBounds = currentBounds
        lastSafeInsets = currentSafeInsets

        let layout = configuration.layout
        let textWidth = measuredTextWidth(actionText)
        let bubbleWidth = max(layout.minWidth, min(layout.maxWidth, textWidth + layout.contentInsets.left + layout.contentInsets.right))
        let bubbleHeight = layout.rowHeight + layout.arrowHeight

        let safeTop = currentSafeInsets.top + layout.verticalMargin
        let safeBottom = bounds.height - currentSafeInsets.bottom - layout.verticalMargin
        let safeLeft = currentSafeInsets.left + layout.horizontalMargin
        let safeRight = bounds.width - currentSafeInsets.right - layout.horizontalMargin

        let spaceAbove = anchorFrame.minY - layout.anchorGap - safeTop
        let spaceBelow = safeBottom - anchorFrame.maxY - layout.anchorGap
        let placeAbove = decidePlaceAbove(spaceAbove: spaceAbove, spaceBelow: spaceBelow, bubbleHeight: bubbleHeight)
        direction = placeAbove ? .down : .up

        var bubbleX = anchorFrame.midX - bubbleWidth / 2
        bubbleX = min(max(bubbleX, safeLeft), safeRight - bubbleWidth)

        var bubbleY: CGFloat = placeAbove
            ? anchorFrame.minY - layout.anchorGap - bubbleHeight
            : anchorFrame.maxY + layout.anchorGap
        bubbleY = min(max(bubbleY, safeTop), safeBottom - bubbleHeight)

        shadowContainer.frame = CGRect(x: bubbleX, y: bubbleY, width: bubbleWidth, height: bubbleHeight)
        bubbleContainer.frame = shadowContainer.bounds

        let arrowHalfWidth = layout.arrowWidth / 2
        let minTipX = bubbleX + layout.cornerRadius + arrowHalfWidth + layout.arrowEdgePadding
        let maxTipX = bubbleX + bubbleWidth - layout.cornerRadius - arrowHalfWidth - layout.arrowEdgePadding
        let tipX = min(max(anchorFrame.midX, minTipX), maxTipX)
        arrowLocalX = tipX - bubbleX

        let contentRect: CGRect
        switch direction {
        case .up:
            contentRect = CGRect(x: 0, y: layout.arrowHeight, width: bubbleWidth, height: layout.rowHeight)
        case .down:
            contentRect = CGRect(x: 0, y: 0, width: bubbleWidth, height: layout.rowHeight)
        }
        actionControl.frame = contentRect

        let path = bubblePath(in: bubbleContainer.bounds, direction: direction, arrowTipX: arrowLocalX)
        bubbleFillLayer.frame = bubbleContainer.bounds
        bubbleFillLayer.path = path.cgPath
        bubbleFillLayer.fillColor = configuration.appearance.backgroundColor.cgColor

        // 规则：阴影 path 必须和气泡 path 一致（包含箭头）。
        shadowContainer.layer.shadowPath = path.cgPath
    }

    private func decidePlaceAbove(spaceAbove: CGFloat, spaceBelow: CGFloat, bubbleHeight: CGFloat) -> Bool {
        switch configuration.layout.preferredPlacement {
        case .automatic:
            return (spaceAbove >= bubbleHeight) || (spaceAbove >= spaceBelow)
        case .preferAboveAnchor:
            if spaceAbove >= bubbleHeight { return true }
            return spaceAbove >= spaceBelow
        case .preferBelowAnchor:
            if spaceBelow >= bubbleHeight { return false }
            return spaceAbove >= spaceBelow
        }
    }

    private func measuredTextWidth(_ text: String) -> CGFloat {
        guard !text.isEmpty else { return 0 }
        let width = (text as NSString).boundingRect(
            with: CGSize(width: .greatestFiniteMagnitude, height: configuration.layout.rowHeight),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            attributes: [.font: titleLabel.font as Any],
            context: nil
        ).width
        return ceil(width)
    }

    private func bubblePath(in rect: CGRect, direction: ArrowDirection, arrowTipX: CGFloat) -> UIBezierPath {
        let layout = configuration.layout
        let path = UIBezierPath()
        let corner = layout.cornerRadius
        let arrowHalf = layout.arrowWidth / 2
        let arrowHeight = layout.arrowHeight

        let bodyRect: CGRect
        switch direction {
        case .up:
            bodyRect = CGRect(x: 0, y: arrowHeight, width: rect.width, height: rect.height - arrowHeight)
        case .down:
            bodyRect = CGRect(x: 0, y: 0, width: rect.width, height: rect.height - arrowHeight)
        }

        path.append(UIBezierPath(roundedRect: bodyRect, cornerRadius: corner))

        switch direction {
        case .up:
            path.move(to: CGPoint(x: arrowTipX, y: 0))
            path.addLine(to: CGPoint(x: arrowTipX - arrowHalf, y: arrowHeight))
            path.addLine(to: CGPoint(x: arrowTipX + arrowHalf, y: arrowHeight))
            path.close()
        case .down:
            let y = rect.height
            path.move(to: CGPoint(x: arrowTipX, y: y))
            path.addLine(to: CGPoint(x: arrowTipX - arrowHalf, y: y - arrowHeight))
            path.addLine(to: CGPoint(x: arrowTipX + arrowHalf, y: y - arrowHeight))
            path.close()
        }
        return path
    }
}

private final class HighlightControl: UIControl {
    private let highlightColor: UIColor

    init(highlightColor: UIColor) {
        self.highlightColor = highlightColor
        super.init(frame: .zero)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? highlightColor : .clear
        }
    }
}
#endif
