//
//  BadgeView.swift
//  AppUIKit
//
//  Production-grade alert badge component.
//  Visual spec: Figma MVP · node 51:4558 (multi-digit) / 51:4556 (single-digit)
//  Reference quality: WeChat / TikTok / iOS SpringBoard.
//
//  ┌─────────────────────────────────────────────────────────────────────────┐
//  │  Features                                                               │
//  │  • Content:     dot · count (99+) · text · hidden                       │
//  │  • Layout:      AutoLayout, intrinsicContentSize, dynamic pill width    │
//  │  • Anchor:      topTrailing · topLeading · topCenter · manual point     │
//  │  • Offset:      arbitrary CGPoint per-anchor                            │
//  │  • Animation:   spring pop-in, spring pop-out, content-change pop       │
//  │  • Config:      full customisation via BadgeConfiguration               │
//  │  • Presets:     .default · .bordered · .elevated                        │
//  │  • Platforms:   UIKit (iOS 13+) + AppKit (macOS 11+)                   │
//  │  • SwiftUI:     BadgeLabel view + .badgeOverlay(_:) modifier            │
//  └─────────────────────────────────────────────────────────────────────────┘

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
public typealias _PlatformColor = UIColor
public typealias _Font = UIFont
#elseif canImport(AppKit)
import AppKit
public typealias PlatformColor = NSColor
public typealias _Font = NSFont
#endif

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeContent
// ─────────────────────────────────────────────────────────────────────────────

/// What the badge renders.
public enum BadgeContent: Equatable {

    /// Solid circle with no label — the minimal "unread" dot.
    case dot

    /// Numeric count.
    ///   • Values ≤ `BadgeConfiguration.maxCount` render as-is: "1", "42"
    ///   • Values > `maxCount` render as overflow: "99+"
    case count(Int)

    /// Arbitrary short label, e.g. "NEW" or "LIVE".
    case text(String)

    /// Badge is not shown; animates out if it was previously visible.
    case hidden
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeConfiguration
// ─────────────────────────────────────────────────────────────────────────────

/// Complete visual and behavioural specification for a `BadgeView`.
///
/// Start from a preset (`.default`, `.bordered`, `.elevated`) and mutate:
/// ```swift
/// var cfg = BadgeConfiguration.bordered
/// cfg.borderWidth = 1.5
/// cfg.offset = CGPoint(x: 4, y: -4)
/// ```
public struct BadgeConfiguration {

    // MARK: Colors

    /// Badge background fill.
    /// Default: `#EF4444` — Figma `semantic/error` red.
    public var backgroundColor: _PlatformColor

    /// Label / text colour. Default: `.white`.
    public var textColor: _PlatformColor

    /// Border stroke colour. Visible only when `borderWidth > 0`. Default: `.white`.
    public var borderColor: _PlatformColor

    /// Border stroke width in points. `0` = no border. Default: `0`.
    public var borderWidth: CGFloat

    // MARK: Typography

    /// Font for `.count` and `.text` content.
    /// Default: system semi-bold 11 pt (visually matches Figma Inter SemiBold 11).
    public var font: _Font

    // MARK: Sizing

    /// Diameter of the circle in `.dot` mode. Default: `8` pt.
    public var dotSize: CGFloat

    /// Minimum badge height, and minimum width for single-character circles.
    /// Default: `16` pt — per Figma spec (node 51:4556 and 51:4558).
    public var minHeight: CGFloat

    /// Horizontal inset applied on **each** side inside the pill (left + right separately).
    /// Default: `4` pt — per Figma spec for multi-digit badges.
    public var horizontalPadding: CGFloat

    /// Corner radius of the pill. `nil` = fully capsule (`height / 2`). Default: `nil`.
    public var cornerRadius: CGFloat?

    // MARK: Count overflow

    /// Counts above this render as overflow, e.g. "99+". Default: `99`.
    public var maxCount: Int

    /// String appended to `maxCount` in the overflow case. Default: `"+"`.
    public var overflowSuffix: String

    // MARK: Positioning

    /// Which corner / edge of the host view the badge is attached to. Default: `.topTrailing`.
    public var anchor: BadgeAnchor

    /// Offset applied to the anchor point.
    ///   • Positive `x` → moves badge further right.
    ///   • Positive `y` → moves badge further down.
    /// Default: `.zero` (badge centre exactly at the anchor corner).
    public var offset: CGPoint

    // MARK: Shadow

    /// Shadow colour. `nil` = no shadow. Default: `nil`.
    public var shadowColor: _PlatformColor?

    /// Shadow blur radius in points. Default: `4`.
    public var shadowRadius: CGFloat

    /// Shadow positional offset. Default: `(0, 2)`.
    public var shadowOffset: CGSize

    /// Shadow opacity [0…1]. Default: `0.2`.
    public var shadowOpacity: Float

    // MARK: Animation

    /// Transition style for show / hide / content changes. Default: `.standard`.
    public var animation: BadgeAnimation

    // ─── Presets ──────────────────────────────────────────────────────────────

    /// **Default** — red pill, 16 pt, white text, spring animation.
    /// Matches Figma MVP design spec exactly.
    public static var `default`: BadgeConfiguration { BadgeConfiguration() }

    /// **Bordered** — adds a 2 pt white border.
    /// Best for badges placed on coloured backgrounds (tab bars, avatars on images).
    public static var bordered: BadgeConfiguration {
        var c = BadgeConfiguration(); c.borderWidth = 2; return c
    }

    /// **Elevated** — subtle drop-shadow.
    /// Best for badges over photograph / video thumbnails.
    public static var elevated: BadgeConfiguration {
        var c = BadgeConfiguration()
        c.shadowColor   = _PlatformColor.black
        c.shadowOpacity = 0.25
        return c
    }

    // ─── Init ─────────────────────────────────────────────────────────────────

    public init(
        backgroundColor:   _PlatformColor    = _PlatformColor(hex: 0xEF4444),
        textColor:         _PlatformColor    = .white,
        borderColor:       _PlatformColor    = .white,
        borderWidth:       CGFloat          = 0,
        font:              _Font            = .systemFont(ofSize: 11, weight: .semibold),
        dotSize:           CGFloat          = 8,
        minHeight:         CGFloat          = 16,
        horizontalPadding: CGFloat          = 4,
        cornerRadius:      CGFloat?         = nil,
        maxCount:          Int              = 99,
        overflowSuffix:    String           = "+",
        anchor:            BadgeAnchor      = .topTrailing,
        offset:            CGPoint          = .zero,
        shadowColor:       _PlatformColor?   = nil,
        shadowRadius:      CGFloat          = 4,
        shadowOffset:      CGSize           = CGSize(width: 0, height: 2),
        shadowOpacity:     Float            = 0.2,
        animation:         BadgeAnimation   = .standard
    ) {
        self.backgroundColor   = backgroundColor
        self.textColor         = textColor
        self.borderColor       = borderColor
        self.borderWidth       = borderWidth
        self.font              = font
        self.dotSize           = dotSize
        self.minHeight         = minHeight
        self.horizontalPadding = horizontalPadding
        self.cornerRadius      = cornerRadius
        self.maxCount          = maxCount
        self.overflowSuffix    = overflowSuffix
        self.anchor            = anchor
        self.offset            = offset
        self.shadowColor       = shadowColor
        self.shadowRadius      = shadowRadius
        self.shadowOffset      = shadowOffset
        self.shadowOpacity     = shadowOpacity
        self.animation         = animation
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeAnchor
// ─────────────────────────────────────────────────────────────────────────────

/// The point on the host view where the badge's **center** is anchored.
public enum BadgeAnchor {
    /// Top-trailing corner (top-right in LTR). Most common — tabs, avatars. Default.
    case topTrailing
    /// Top-leading corner (top-left in LTR). Useful for RTL or custom layouts.
    case topLeading
    /// Center of the top edge.
    case topCenter
    /// Explicit point in the host view's **local** coordinate space (badge center placed here).
    case point(CGPoint)
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeAnimation
// ─────────────────────────────────────────────────────────────────────────────

/// Animation applied when a badge appears, disappears, or changes content.
public enum BadgeAnimation {
    /// No animation. Transitions are instantaneous.
    case none

    /// Physics-based spring pop.
    ///   - `damping`:  stiffness of the spring [0…1]; lower = more bounce.
    ///   - `velocity`: initial push (pts·s⁻¹ ÷ total travel). Default 0.8.
    case spring(damping: CGFloat, velocity: CGFloat)

    /// Cross-fade with a fixed duration.
    case fade(duration: TimeInterval)

    /// Default spring — tuned to match iOS system notification badge.
    nonisolated(unsafe) public static let standard = BadgeAnimation.spring(damping: 0.62, velocity: 0.8)

    /// Returns `true` for any animated variant.
    public var isAnimated: Bool {
        if case .none = self { return false }
        return true
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeView  (UIKit)
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(UIKit)

/// A self-sizing badge pill / dot view.
///
/// **Usage — standalone:**
/// ```swift
/// let badge = BadgeView(content: .count(5))
/// tabBarItem.addSubview(badge)
/// ```
///
/// **Usage — attached to a host view:**
/// ```swift
/// avatarImageView.setBadge(.count(3))
/// iconButton.setBadge(.dot, configuration: .bordered)
/// iconButton.removeBadge()
/// ```
public final class BadgeView: UIView {

    // MARK: Public

    /// Current badge content. Setting this triggers an animated transition.
    /// Use `setContent(_:animated:)` to control animation explicitly.
    public var content: BadgeContent {
        get { _content }
        set { setContent(newValue, animated: true) }
    }

    /// Visual configuration. Updating this immediately refreshes the appearance.
    public var configuration: BadgeConfiguration {
        didSet { applyStyle() }
    }

    // MARK: Private

    private var _content: BadgeContent = .hidden
    private let label = UILabel()
    private var sizeConstraints: [NSLayoutConstraint] = []

    // MARK: Init

    /// Create a badge with explicit content and configuration.
    public init(
        content: BadgeContent = .hidden,
        configuration: BadgeConfiguration = .default
    ) {
        self.configuration = configuration
        super.init(frame: .zero)
        commonInit()
        setContent(content, animated: false)
    }

    public required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        commonInit()
    }

    // MARK: - Setup

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        isUserInteractionEnabled = false
        clipsToBounds = false // Allow shadow to bleed beyond bounds

        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment   = .center
        label.numberOfLines   = 1
        label.lineBreakMode   = .byClipping
        label.adjustsFontSizeToFitWidth = false
        label.setContentCompressionResistancePriority(.required, for: .horizontal)
        addSubview(label)

        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        applyStyle()
    }

    // ─── Public API ───────────────────────────────────────────────────────────

    /// Update the badge content with explicit animation control.
    ///
    /// - Parameters:
    ///   - content:  New content to display.
    ///   - animated: When `true`, uses the animation from `configuration.animation`.
    public func setContent(_ content: BadgeContent, animated: Bool) {
        assert(Thread.isMainThread, "BadgeView must be updated on the main thread.")
        let previous = _content
        _content = content

        switch (previous == .hidden, content == .hidden) {
        case (_, true):
            // Any → hidden
            animateOut(animated: animated) { [weak self] in
                self?.isHidden = true
                self?.label.text = nil
            }
        case (true, false):
            // Hidden → visible: size first, then pop in
            label.text = displayText(for: content)
            isHidden = false
            updateSize(for: content)
            animateIn(animated: animated)
        case (false, false):
            // Visible → visible: pop, then swap text + resize
            if animated { popAnimation() }
            label.text = displayText(for: content)
            updateSize(for: content)
        default:
            break
        }
    }

    // ─── Layout ───────────────────────────────────────────────────────────────

    public override var intrinsicContentSize: CGSize { pillSize(for: _content) }

    private func pillSize(for content: BadgeContent) -> CGSize {
        switch content {
        case .hidden:
            return .zero
        case .dot:
            let d = configuration.dotSize
            return CGSize(width: d, height: d)
        case .count, .text:
            let str  = displayText(for: content) as NSString
            let attr = [NSAttributedString.Key.font: configuration.font]
            let tw   = str.size(withAttributes: attr).width
            let h    = configuration.minHeight
            let w    = max(h, ceil(tw) + configuration.horizontalPadding * 2)
            return CGSize(width: w, height: h)
        }
    }

    private func updateSize(for content: BadgeContent) {
        NSLayoutConstraint.deactivate(sizeConstraints)
        let size = pillSize(for: content)
        sizeConstraints = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
        ]
        NSLayoutConstraint.activate(sizeConstraints)
        layer.cornerRadius = configuration.cornerRadius ?? (size.height / 2)
    }

    // ─── Appearance ───────────────────────────────────────────────────────────

    private func applyStyle() {
        layer.backgroundColor = configuration.backgroundColor.cgColor
        layer.borderColor     = configuration.borderColor.cgColor
        layer.borderWidth     = configuration.borderWidth
        label.font            = configuration.font
        label.textColor       = configuration.textColor

        if let sc = configuration.shadowColor {
            layer.shadowColor   = sc.cgColor
            layer.shadowRadius  = configuration.shadowRadius
            layer.shadowOffset  = configuration.shadowOffset
            layer.shadowOpacity = configuration.shadowOpacity
        } else {
            layer.shadowOpacity = 0
        }

        if _content != .hidden { updateSize(for: _content) }
    }

    // ─── Text formatting ──────────────────────────────────────────────────────

    private func displayText(for content: BadgeContent) -> String {
        switch content {
        case .hidden, .dot:   return ""
        case .text(let s):    return s
        case .count(let n):
            return n > configuration.maxCount
                ? "\(configuration.maxCount)\(configuration.overflowSuffix)"
                : "\(n)"
        }
    }

    // ─── Animation helpers ────────────────────────────────────────────────────

    private func animateIn(animated: Bool) {
        guard animated, configuration.animation.isAnimated else { return }
        layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
        let anim = makeSpringAnimation(from: 0.01, to: 1.0)
        layer.add(anim, forKey: "badge.in")
        layer.transform = CATransform3DIdentity
    }

    private func animateOut(animated: Bool, completion: @escaping () -> Void) {
        guard animated, configuration.animation.isAnimated else {
            completion(); return
        }
        let duration: TimeInterval
        if case .fade(let d) = configuration.animation { duration = d } else { duration = 0.18 }
        UIView.animate(
            withDuration: duration,
            delay: 0,
            options: [.curveEaseIn, .beginFromCurrentState],
            animations: {
                self.layer.transform = CATransform3DMakeScale(0.01, 0.01, 1)
                self.alpha = 0
            },
            completion: { _ in
                self.layer.transform = CATransform3DIdentity
                self.alpha = 1
                completion()
            }
        )
    }

    /// Brief scale bounce: 1.0 → 1.28 → 1.0 when count/text changes.
    private func popAnimation() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values      = [1.0, 1.28, 1.0]
        anim.keyTimes    = [0.0, 0.38,  1.0]
        anim.duration    = 0.28
        anim.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeIn),
        ]
        layer.add(anim, forKey: "badge.pop")
    }

    private func makeSpringAnimation(from: CGFloat, to: CGFloat) -> CASpringAnimation {
        let anim = CASpringAnimation(keyPath: "transform.scale")
        // CASpringAnimation.damping is a physics coefficient, not a UIKit ratio.
        // Multiply the user's [0…1] ratio by ~18 to approximate UIKit spring feel.
        if case .spring(let d, let v) = configuration.animation {
            anim.damping         = d * 18
            anim.initialVelocity = v
        } else {
            anim.damping         = 11.2
            anim.initialVelocity = 0.8
        }
        anim.fromValue = from
        anim.toValue   = to
        anim.duration  = anim.settlingDuration
        return anim
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - UIView + Badge attachment
// ─────────────────────────────────────────────────────────────────────────────

private nonisolated(unsafe) var _badgeViewKey: UInt8 = 0
private nonisolated(unsafe) var _anchorKey:    UInt8 = 0

extension UIView {

    /// The badge currently attached to this view, if any.
    public var attachedBadge: BadgeView? {
        objc_getAssociatedObject(self, &_badgeViewKey) as? BadgeView
    }

    /// Attach (or update) a badge anchored to this view.
    ///
    /// The badge is inserted as a **sibling** in the parent's view hierarchy so it
    /// can overflow the host view's bounds without clipping.  If the host has no
    /// superview yet the badge is added as a subview (ensure `clipsToBounds = false`).
    ///
    /// Calling this a second time reuses the existing badge and updates its content.
    ///
    /// - Parameters:
    ///   - content:       Badge content (`.dot`, `.count(n)`, `.text(s)`, `.hidden`).
    ///   - configuration: Full visual config. Defaults to `BadgeConfiguration.default`.
    ///   - animated:      Animate the initial appearance. Default: `true`.
    /// - Returns: The `BadgeView` for further customisation or observation.
    @discardableResult
    public func setBadge(
        _ content: BadgeContent,
        configuration: BadgeConfiguration = .default,
        animated: Bool = true
    ) -> BadgeView {
        // Reuse existing badge
        if let existing = attachedBadge {
            existing.configuration = configuration
            existing.setContent(content, animated: animated)
            return existing
        }

        let badge = BadgeView(content: .hidden, configuration: configuration)
        objc_setAssociatedObject(self, &_badgeViewKey, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        // Prefer sibling so badge overflows host bounds freely
        let container = superview ?? self
        container.addSubview(badge)

        // Install anchor constraints
        let anchors = makeAnchorConstraints(for: badge, in: container, configuration: configuration)
        NSLayoutConstraint.activate(anchors)
        objc_setAssociatedObject(self, &_anchorKey, anchors, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        badge.setContent(content, animated: animated)
        return badge
    }

    /// Remove the badge from this view (with optional hide animation).
    public func removeBadge(animated: Bool = true) {
        guard let badge = attachedBadge else { return }
        objc_setAssociatedObject(self, &_badgeViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        badge.setContent(.hidden, animated: animated)
        if animated {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                badge.removeFromSuperview()
            }
        } else {
            badge.removeFromSuperview()
        }
    }

    // ─── Private helpers ──────────────────────────────────────────────────────

    private func makeAnchorConstraints(
        for badge: BadgeView,
        in container: UIView,
        configuration: BadgeConfiguration
    ) -> [NSLayoutConstraint] {
        let dx = configuration.offset.x
        let dy = configuration.offset.y

        switch configuration.anchor {
        case .topTrailing:
            return [
                badge.centerXAnchor.constraint(equalTo: trailingAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,      constant: dy),
            ]
        case .topLeading:
            return [
                badge.centerXAnchor.constraint(equalTo: leadingAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,     constant: dy),
            ]
        case .topCenter:
            return [
                badge.centerXAnchor.constraint(equalTo: centerXAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,     constant: dy),
            ]
        case .point(let pt):
            // Place badge centre at an absolute point in container coordinates.
            // Uses the host view's frame origin as a base.
            return [
                badge.centerXAnchor.constraint(
                    equalTo: container.leadingAnchor,
                    constant: frame.origin.x + pt.x + dx
                ),
                badge.centerYAnchor.constraint(
                    equalTo: container.topAnchor,
                    constant: frame.origin.y + pt.y + dy
                ),
            ]
        }
    }
}

#endif // UIKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeView  (AppKit)
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(AppKit) && !targetEnvironment(macCatalyst)

/// AppKit badge view — mirrors the UIKit `BadgeView` API exactly.
public final class BadgeView: NSView {

    // MARK: Public

    /// Current badge content. Assigning triggers an animated transition.
    public var content: BadgeContent {
        get { _content }
        set { setContent(newValue, animated: true) }
    }

    /// Configuration. Updating immediately refreshes appearance.
    public var configuration: BadgeConfiguration {
        didSet { applyStyle() }
    }

    // MARK: Private

    private var _content: BadgeContent = .hidden
    private let textField: NSTextField = {
        let tf = NSTextField(labelWithString: "")
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.alignment   = .center
        tf.isBezeled   = false
        tf.isEditable  = false
        tf.drawsBackground = false
        return tf
    }()
    private var sizeConstraints: [NSLayoutConstraint] = []

    // MARK: Init

    public init(
        content: BadgeContent = .hidden,
        configuration: BadgeConfiguration = .default
    ) {
        self.configuration = configuration
        super.init(frame: .zero)
        commonInit()
        setContent(content, animated: false)
    }

    public required init?(coder: NSCoder) {
        self.configuration = .default
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        translatesAutoresizingMaskIntoConstraints = false
        wantsLayer = true

        addSubview(textField)
        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])

        applyStyle()
    }

    // ─── Public API ───────────────────────────────────────────────────────────

    /// Update content with explicit animation control.
    public func setContent(_ content: BadgeContent, animated: Bool) {
        let previous = _content
        _content = content

        switch (previous == .hidden, content == .hidden) {
        case (_, true):
            animateOut(animated: animated) { [weak self] in
                self?.isHidden = true
                self?.textField.stringValue = ""
            }
        case (true, false):
            textField.stringValue = displayText(for: content)
            isHidden = false
            updateSize(for: content)
            animateIn(animated: animated)
        case (false, false):
            if animated { popAnimation() }
            textField.stringValue = displayText(for: content)
            updateSize(for: content)
        default:
            break
        }
    }

    // ─── Layout ───────────────────────────────────────────────────────────────

    public override var intrinsicContentSize: NSSize { pillSize(for: _content) }

    private func pillSize(for content: BadgeContent) -> CGSize {
        switch content {
        case .hidden:
            return .zero
        case .dot:
            let d = configuration.dotSize; return CGSize(width: d, height: d)
        case .count, .text:
            let str  = displayText(for: content) as NSString
            let attr = [NSAttributedString.Key.font: configuration.font]
            let tw   = str.size(withAttributes: attr).width
            let h    = configuration.minHeight
            let w    = max(h, ceil(tw) + configuration.horizontalPadding * 2)
            return CGSize(width: w, height: h)
        }
    }

    private func updateSize(for content: BadgeContent) {
        NSLayoutConstraint.deactivate(sizeConstraints)
        let size = pillSize(for: content)
        sizeConstraints = [
            widthAnchor.constraint(equalToConstant: size.width),
            heightAnchor.constraint(equalToConstant: size.height),
        ]
        NSLayoutConstraint.activate(sizeConstraints)
        layer?.cornerRadius = configuration.cornerRadius ?? (size.height / 2)
    }

    // ─── Appearance ───────────────────────────────────────────────────────────

    private func applyStyle() {
        layer?.backgroundColor = configuration.backgroundColor.cgColor
        layer?.borderColor     = configuration.borderColor.cgColor
        layer?.borderWidth     = configuration.borderWidth
        textField.font         = configuration.font
        textField.textColor    = configuration.textColor

        if let sc = configuration.shadowColor {
            layer?.shadowColor   = sc.cgColor
            layer?.shadowRadius  = configuration.shadowRadius
            layer?.shadowOffset  = configuration.shadowOffset
            layer?.shadowOpacity = configuration.shadowOpacity
        } else {
            layer?.shadowOpacity = 0
        }

        if _content != .hidden { updateSize(for: _content) }
    }

    // ─── Text ─────────────────────────────────────────────────────────────────

    private func displayText(for content: BadgeContent) -> String {
        switch content {
        case .hidden, .dot:  return ""
        case .text(let s):   return s
        case .count(let n):
            return n > configuration.maxCount
                ? "\(configuration.maxCount)\(configuration.overflowSuffix)"
                : "\(n)"
        }
    }

    // ─── Animations ───────────────────────────────────────────────────────────

    private func animateIn(animated: Bool) {
        guard animated, configuration.animation.isAnimated else { return }
        layer?.transform = CATransform3DMakeScale(0.01, 0.01, 1)
        let anim = makeSpringAnimation(from: 0.01, to: 1.0)
        layer?.add(anim, forKey: "badge.in")
        layer?.transform = CATransform3DIdentity
    }

    private func animateOut(animated: Bool, completion: @escaping () -> Void) {
        guard animated, configuration.animation.isAnimated else {
            completion(); return
        }
        let duration: TimeInterval
        if case .fade(let d) = configuration.animation { duration = d } else { duration = 0.18 }
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = duration
            ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        } completionHandler: {
            self.alphaValue = 1
            completion()
        }
    }

    private func popAnimation() {
        let anim = CAKeyframeAnimation(keyPath: "transform.scale")
        anim.values      = [1.0, 1.28, 1.0]
        anim.keyTimes    = [0.0, 0.38,  1.0]
        anim.duration    = 0.28
        anim.timingFunctions = [
            CAMediaTimingFunction(name: .easeOut),
            CAMediaTimingFunction(name: .easeIn),
        ]
        layer?.add(anim, forKey: "badge.pop")
    }

    private func makeSpringAnimation(from: CGFloat, to: CGFloat) -> CASpringAnimation {
        let anim = CASpringAnimation(keyPath: "transform.scale")
        if case .spring(let d, let v) = configuration.animation {
            anim.damping         = d * 18
            anim.initialVelocity = v
        } else {
            anim.damping         = 11.2
            anim.initialVelocity = 0.8
        }
        anim.fromValue = from
        anim.toValue   = to
        anim.duration  = anim.settlingDuration
        return anim
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - NSView + Badge attachment
// ─────────────────────────────────────────────────────────────────────────────

private nonisolated(unsafe) var _nsBadgeViewKey: UInt8 = 0

extension NSView {

    /// The badge currently attached to this view, if any.
    public var attachedBadge: BadgeView? {
        objc_getAssociatedObject(self, &_nsBadgeViewKey) as? BadgeView
    }

    /// Attach (or update) a badge anchored to this view.
    @discardableResult
    public func setBadge(
        _ content: BadgeContent,
        configuration: BadgeConfiguration = .default,
        animated: Bool = true
    ) -> BadgeView {
        if let existing = attachedBadge {
            existing.configuration = configuration
            existing.setContent(content, animated: animated)
            return existing
        }

        let badge = BadgeView(content: .hidden, configuration: configuration)
        objc_setAssociatedObject(self, &_nsBadgeViewKey, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)

        let container = superview ?? self
        container.addSubview(badge)
        NSLayoutConstraint.activate(makeAnchorConstraints(for: badge, in: container, configuration: configuration))

        badge.setContent(content, animated: animated)
        return badge
    }

    /// Remove the badge from this view.
    public func removeBadge(animated: Bool = true) {
        guard let badge = attachedBadge else { return }
        objc_setAssociatedObject(self, &_nsBadgeViewKey, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        badge.setContent(.hidden, animated: animated)
        if animated {
            Task { @MainActor in
                try? await Task.sleep(nanoseconds: 300_000_000)
                badge.removeFromSuperview()
            }
        } else {
            badge.removeFromSuperview()
        }
    }

    private func makeAnchorConstraints(
        for badge: BadgeView,
        in container: NSView,
        configuration: BadgeConfiguration
    ) -> [NSLayoutConstraint] {
        let dx = configuration.offset.x
        let dy = configuration.offset.y
        switch configuration.anchor {
        case .topTrailing:
            return [
                badge.centerXAnchor.constraint(equalTo: trailingAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,      constant: dy),
            ]
        case .topLeading:
            return [
                badge.centerXAnchor.constraint(equalTo: leadingAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,     constant: dy),
            ]
        case .topCenter:
            return [
                badge.centerXAnchor.constraint(equalTo: centerXAnchor, constant: dx),
                badge.centerYAnchor.constraint(equalTo: topAnchor,     constant: dy),
            ]
        case .point(let pt):
            return [
                badge.centerXAnchor.constraint(equalTo: container.leadingAnchor, constant: frame.origin.x + pt.x + dx),
                badge.centerYAnchor.constraint(equalTo: container.topAnchor,     constant: frame.origin.y + pt.y + dy),
            ]
        }
    }
}

#endif // AppKit

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - SwiftUI wrapper
// ─────────────────────────────────────────────────────────────────────────────

#if canImport(UIKit) || canImport(AppKit)

/// Internal UIViewRepresentable / NSViewRepresentable bridge.
private struct _BadgeRepresentable {
    let content:       BadgeContent
    let configuration: BadgeConfiguration
}

#if canImport(UIKit)

extension _BadgeRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> BadgeView {
        BadgeView(content: content, configuration: configuration)
    }

    func updateUIView(_ view: BadgeView, context: Context) {
        view.configuration = configuration
        view.setContent(content, animated: context.transaction.animation != nil)
    }

    @available(iOS 16.0, *)
    func sizeThatFits(_ proposal: ProposedViewSize, uiView: BadgeView, context: Context) -> CGSize? {
        uiView.intrinsicContentSize
    }
}

#elseif canImport(AppKit) && !targetEnvironment(macCatalyst)

extension _BadgeRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> BadgeView {
        BadgeView(content: content, configuration: configuration)
    }

    func updateNSView(_ view: BadgeView, context: Context) {
        view.configuration = configuration
        view.setContent(content, animated: context.transaction.animation != nil)
    }
}

#endif

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - BadgeLabel (SwiftUI)
// ─────────────────────────────────────────────────────────────────────────────

/// A SwiftUI view that renders a `BadgeView`.
///
/// Sizes itself to exactly fit the badge content via `fixedSize()`.
///
/// ```swift
/// HStack {
///     Image(systemName: "bell")
///     BadgeLabel(.count(12))
/// }
/// ```
public struct BadgeLabel: View {
    private let content:       BadgeContent
    private let configuration: BadgeConfiguration

    public init(
        _ content: BadgeContent,
        configuration: BadgeConfiguration = .default
    ) {
        self.content       = content
        self.configuration = configuration
    }

    public var body: some View {
        _BadgeRepresentable(content: content, configuration: configuration)
            .fixedSize()
    }
}

// ─────────────────────────────────────────────────────────────────────────────
// MARK: - .badgeOverlay(_:) SwiftUI modifier
// ─────────────────────────────────────────────────────────────────────────────

extension View {

    /// Overlays a `BadgeView` anchored to this view.
    ///
    /// The badge **centre** is placed at the anchor corner + `configuration.offset`:
    ///
    /// ```swift
    /// // Red dot at top-right (default)
    /// avatarImage.badgeOverlay(.dot)
    ///
    /// // Count with a white border, pushed slightly out
    /// tabIcon.badgeOverlay(
    ///     .count(notifications),
    ///     configuration: {
    ///         var c = BadgeConfiguration.bordered
    ///         c.offset = CGPoint(x: 2, y: -2)
    ///         return c
    ///     }()
    /// )
    ///
    /// // Hidden (animates out automatically via SwiftUI transaction)
    /// icon.badgeOverlay(showBadge ? .count(n) : .hidden)
    /// ```
    public func badgeOverlay(
        _ content: BadgeContent,
        configuration: BadgeConfiguration = .default
    ) -> some View {
        modifier(_BadgeOverlayModifier(content: content, configuration: configuration))
    }
}

private struct _BadgeOverlayModifier: ViewModifier {
    let content:       BadgeContent
    let configuration: BadgeConfiguration

    func body(content view: Content) -> some View {
        view.overlay(
            GeometryReader { geo in
                if self.content != .hidden {
                    _BadgeRepresentable(content: self.content, configuration: configuration)
                        .fixedSize()
                        .position(anchorPoint(in: geo.size))
                        .allowsHitTesting(false)
                }
            }
        )
    }

    /// Converts `BadgeAnchor` → an absolute point (badge center) within `size`.
    private func anchorPoint(in size: CGSize) -> CGPoint {
        let dx = configuration.offset.x
        let dy = configuration.offset.y
        switch configuration.anchor {
        case .topTrailing: return CGPoint(x: size.width + dx,         y: dy)
        case .topLeading:  return CGPoint(x: dx,                      y: dy)
        case .topCenter:   return CGPoint(x: size.width / 2 + dx,     y: dy)
        case .point(let p): return CGPoint(x: p.x + dx,               y: p.y + dy)
        }
    }
}

#endif // canImport(UIKit) || canImport(AppKit)
