//
//  XTextView.swift
//  xxf_ios
//
//  Created by xxf
//

#if canImport(UIKit)
import SnapKit
import UIKit

/// 带 placeholder 的 UITextView。
///
/// 设计为可继承组件(`open class`),业务方可子类化扩展
/// 工具栏、字符计数、IME 钩子等行为。
open class XTextView: UITextView {
    // MARK: - Public Config

    /// 控制该 TextView 是否允许成为 first responder。
    public var allowsFirstResponder: Bool = true

    /// 占位文案。
    public var placeholder: String? {
        didSet {
            placeholderLabel.text = placeholder
            updatePlaceholder()
        }
    }

    /// 占位文案颜色。
    public var placeholderColor: UIColor = .lightGray {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }

    /// 占位行数(默认 1 行,保持与 Android EditText 类似的一行占位体验)。
    public var placeholderNumberOfLines: Int = 1 {
        didSet {
            placeholderLabel.numberOfLines = placeholderNumberOfLines
        }
    }

    // MARK: - Private Internals

    private let placeholderLabel = UILabel()
    private var placeholderLeadingConstraint: Constraint?
    private var placeholderTopConstraint: Constraint?
    private var placeholderTrailingConstraint: Constraint?
    private var lastPlaceholderInsets: (leading: CGFloat, top: CGFloat, trailing: CGFloat)?

    // MARK: - UITextView Overrides

    override public var text: String! {
        didSet {
            updatePlaceholder()
        }
    }

    override public var attributedText: NSAttributedString! {
        didSet {
            updatePlaceholder()
        }
    }

    override public var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }

    override public var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }

    override public var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderInsets()
        }
    }

    /// 允许子类进一步定制"是否可成为 first responder"的决策。
    override open var canBecomeFirstResponder: Bool {
        allowsFirstResponder && super.canBecomeFirstResponder
    }

    // MARK: - Init

    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupPlaceholder()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupPlaceholder()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Layout

    /// 子类若需要额外布局,`open override` 以便链式扩展。
    override open func layoutSubviews() {
        super.layoutSubviews()
        updatePlaceholderInsets()
    }

    // MARK: - Setup

    private func setupPlaceholder() {
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.font = font
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.numberOfLines = placeholderNumberOfLines
        placeholderLabel.isUserInteractionEnabled = false
        placeholderLabel.isAccessibilityElement = false

        addSubview(placeholderLabel)
        placeholderLabel.snp.makeConstraints { make in
            placeholderLeadingConstraint = make.leading.equalToSuperview().offset(0).constraint
            placeholderTopConstraint = make.top.equalToSuperview().offset(0).constraint
            placeholderTrailingConstraint = make.trailing.lessThanOrEqualToSuperview().offset(0).constraint
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidChangeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidBeginEditingNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updatePlaceholder),
            name: UITextView.textDidEndEditingNotification,
            object: self
        )

        updatePlaceholderInsets()
        updatePlaceholder()
    }

    private func updatePlaceholderInsets() {
        let leading = textContainerInset.left + textContainer.lineFragmentPadding
        let top = textContainerInset.top
        let trailing = -(textContainerInset.right + textContainer.lineFragmentPadding)

        if let last = lastPlaceholderInsets,
           abs(last.leading - leading) < 0.5,
           abs(last.top - top) < 0.5,
           abs(last.trailing - trailing) < 0.5
        {
            return
        }
        lastPlaceholderInsets = (leading, top, trailing)

        placeholderLeadingConstraint?.update(offset: leading)
        placeholderTopConstraint?.update(offset: top)
        placeholderTrailingConstraint?.update(offset: trailing)
    }

    @objc
    private func updatePlaceholder() {
        // 输入法组合态(markedTextRange)也应隐藏 placeholder,避免与候选输入重叠。
        let hasMarkedText = markedTextRange != nil
        let hasContent = hasText || hasMarkedText
        placeholderLabel.isHidden = hasContent
    }
}
#endif
