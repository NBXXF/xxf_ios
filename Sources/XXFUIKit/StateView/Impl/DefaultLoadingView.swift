//
//  DefaultLoadingView.swift
//  xxf_ios
//
//  Created by xxf on 2023/3/25.
//

#if canImport(UIKit)
import UIKit

/// 默认加载中状态视图
@MainActor
open class DefaultLoadingView: UIView, ILoadingView {
    // MARK: - UI Components

    private let containerView = UIView()

    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = false
        return indicator
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "loading..."
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        return label
    }()

    // MARK: - Properties

    /// 标题文字
    public var title: String? {
        didSet {
            titleLabel.text = title
        }
    }

    /// 指示器颜色
    public var indicatorColor: UIColor? {
        didSet {
            activityIndicator.color = indicatorColor
        }
    }

    // MARK: - Initialization

    override public init(frame: CGRect) {
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

        let stackView = UIStackView(arrangedSubviews: [activityIndicator, titleLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(stackView)

        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            containerView.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -40),

            stackView.topAnchor.constraint(equalTo: containerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
        ])
    }

    // MARK: - Public Methods

    /// 开始加载动画
    public func startLoading() {
        activityIndicator.startAnimating()
    }

    /// 停止加载动画
    public func stopLoading() {
        activityIndicator.stopAnimating()
    }
}

#endif
