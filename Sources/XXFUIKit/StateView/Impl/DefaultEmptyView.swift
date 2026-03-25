//
//  DefaultEmptyView.swift
//  xxf_ios
//
//  Created by xxf on 2026/3/25.
//
#if canImport(UIKit)
import UIKit

/// 默认空数据状态视图
@MainActor
open class DefaultEmptyView: UIView, IEmptyView {

    // MARK: - UI Components

    private let containerView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var retryButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.cornerRadius = 999 // 胶囊形状
        button.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        return button
    }()

    // MARK: - IEmptyView Protocol

    /// 标题
    public var title: String? {
        didSet {
            updateTitleLabel()
        }
    }

    /// 描述文字
    public var message: String? {
        didSet {
            updateMessageLabel()
        }
    }

    /// 重试按钮点击回调
    public var onRetry: (() -> Void)?

    // MARK: - Appearance Properties

    /// 标题字体（默认 Rubik Medium 20pt）
    public var titleFont: UIFont = {
        if let font = UIFont(name: "Rubik-Medium", size: 20) {
            return font
        }
        #if DEBUG
        print("⚠️ Rubik-Medium font not found, falling back to system font")
        #endif
        return .systemFont(ofSize: 20, weight: .medium)
    }()

    /// 描述字体（默认 Inter Regular 14pt）
    public var messageFont: UIFont = {
        if let font = UIFont(name: "Inter-Regular", size: 14) {
            return font
        }
        #if DEBUG
        print("⚠️ Inter-Regular font not found, falling back to system font")
        #endif
        return .systemFont(ofSize: 14, weight: .regular)
    }()

    /// 按钮字体（默认 Inter SemiBold 14pt）
    public var buttonFont: UIFont = {
        if let font = UIFont(name: "Inter-SemiBold", size: 14) {
            return font
        }
        return .systemFont(ofSize: 14, weight: .semibold)
    }()

    /// 标题颜色（默认 label，适配深色模式）
    public var titleColor: UIColor = .label

    /// 描述颜色（默认 label 40% 透明度）
    public var messageColor: UIColor = .label.withAlphaComponent(0.4)

    /// 按钮背景色（默认 systemGray6）
    public var buttonBackgroundColor: UIColor = .systemGray6

    /// 按钮标题颜色（默认 label）
    public var buttonTitleColor: UIColor = .label

    // MARK: - Other Properties

    /// 按钮文字
    public var buttonTitle: String? {
        didSet {
            retryButton.setTitle(buttonTitle, for: .normal)
        }
    }

    /// 是否显示按钮
    public var showsButton: Bool = true {
        didSet {
            retryButton.isHidden = !showsButton
        }
    }

    /// 行高倍数（标题默认 26/20 = 1.3）
    public var titleLineHeightMultiple: CGFloat = 26.0 / 20.0

    /// 行高倍数（描述默认 18/14 ≈ 1.29）
    public var messageLineHeightMultiple: CGFloat = 18.0 / 14.0

    /// 字间距（标题默认 -0.2）
    public var titleKerning: CGFloat = -0.2

    /// 按钮内边距
    public var buttonContentInsets = UIEdgeInsets(top: 6, left: 8, bottom: 6, right: 8)

    // MARK: - Initialization

    public init(title: String? = nil, message: String? = nil, buttonTitle: String? = nil, onRetry: (() -> Void)? = nil) {
        self.onRetry = onRetry
        super.init(frame: .zero)
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        setupUI()
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .systemBackground

        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false

        // 文字区域垂直布局
        let textStackView = UIStackView(arrangedSubviews: [titleLabel, messageLabel])
        textStackView.axis = .vertical
        textStackView.alignment = .center
        textStackView.spacing = 16
        textStackView.translatesAutoresizingMaskIntoConstraints = false

        // 主布局
        let mainStackView = UIStackView(arrangedSubviews: [textStackView, retryButton])
        mainStackView.axis = .vertical
        mainStackView.alignment = .center
        mainStackView.spacing = 16
        mainStackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(mainStackView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 34),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -34),

            mainStackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            mainStackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            mainStackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            mainStackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])

        // 应用初始值
        applyAppearance()
        if let title = title { updateTitleLabel() }
        if let message = message { updateMessageLabel() } else { messageLabel.isHidden = true }
        if let buttonTitle = buttonTitle { retryButton.setTitle(buttonTitle, for: .normal) }
    }

    private func applyAppearance() {
        retryButton.backgroundColor = buttonBackgroundColor
        retryButton.setTitleColor(buttonTitleColor, for: .normal)
        retryButton.titleLabel?.font = buttonFont
        retryButton.contentEdgeInsets = buttonContentInsets
    }

    private func updateTitleLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = titleLineHeightMultiple
        paragraphStyle.alignment = .center

        titleLabel.attributedText = NSAttributedString(
            string: title ?? "",
            attributes: [
                .font: titleFont,
                .foregroundColor: titleColor,
                .kern: titleKerning,
                .paragraphStyle: paragraphStyle
            ]
        )
    }

    private func updateMessageLabel() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = messageLineHeightMultiple
        paragraphStyle.alignment = .center

        messageLabel.attributedText = NSAttributedString(
            string: message ?? "",
            attributes: [
                .font: messageFont,
                .foregroundColor: messageColor,
                .paragraphStyle: paragraphStyle
            ]
        )
        messageLabel.isHidden = message?.isEmpty ?? true
    }

    // MARK: - Actions

    @objc private func retryButtonTapped() {
        onRetry?()
    }
}
#endif
