//
//  HostSwitchAlertView.swift
//  xxf_ios
//
//  Created by xxf on 2026/3/25.
//

#if canImport(UIKit)
import UIKit

/// Host 切换弹窗视图
@MainActor
public class HostSwitchAlertView: UIView {

    // MARK: - UI Components

    /// 背景遮罩
    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()

    /// 弹窗容器
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()

    /// 标题标签
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        label.textColor = .label
        label.textAlignment = .center
        label.text = "切换host"
        return label
    }()

    /// 当前 Host 标签
    private let currentHostLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()

    /// 输入框容器
    private let inputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        return view
    }()

    /// Host 输入框
    private let hostTextField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 14)
        textField.textColor = .label
        textField.placeholder = "请输入http host"
        textField.clearButtonMode = .whileEditing
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.spellCheckingType = .no
        textField.keyboardType = .URL
        return textField
    }()

    /// 下拉按钮
    private let dropdownButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "chevron.down"), for: .normal)
        button.tintColor = .systemBlue
        return button
    }()

    /// 按钮容器
    private let buttonContainerView: UIView = {
        let view = UIView()
        return view
    }()

    /// 确定按钮
    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("确定", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    /// 取消按钮
    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .secondarySystemBackground
        button.layer.cornerRadius = 8
        button.layer.masksToBounds = true
        return button
    }()

    /// 下拉菜单
    private var dropdownTableView: UITableView?

    /// 下拉菜单的约束
    private var dropdownConstraints: [NSLayoutConstraint] = []

    // MARK: - Properties

    /// 当前 Host
    public var currentHost: String = "" {
        didSet {
            currentHostLabel.text = "当前host: \(currentHost)"
        }
    }

    /// 预设 Host 选项
    public var hostOptions: [String] = [] {
        didSet {
            updateDropdownButtonVisibility()
        }
    }

    /// 确定回调
    public var onConfirm: ((String) -> Void)?

    /// 取消回调
    public var onCancel: (() -> Void)?

    /// 是否显示下拉菜单
    private var isDropdownVisible = false

    /// 容器视图原始约束（用于键盘适配）
    private var containerCenterYConstraint: NSLayoutConstraint?

    // MARK: - Initialization

    public init() {
        super.init(frame: .zero)
        setupUI()
        setupActions()
        setupKeyboardNotifications()
    }

    @available(*, unavailable)
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Setup

    private func setupUI() {
        // 添加背景遮罩
        addSubview(overlayView)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            overlayView.topAnchor.constraint(equalTo: topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            overlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])

        // 添加弹窗容器
        addSubview(containerView)
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let centerYConstraint = containerView.centerYAnchor.constraint(equalTo: centerYAnchor)
        self.containerCenterYConstraint = centerYConstraint
        NSLayoutConstraint.activate([
            centerYConstraint,
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 40),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -40)
        ])

        // 添加标题
        containerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])

        // 添加当前 Host 标签
        containerView.addSubview(currentHostLabel)
        currentHostLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            currentHostLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            currentHostLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            currentHostLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20)
        ])

        // 添加输入框容器
        containerView.addSubview(inputContainerView)
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            inputContainerView.topAnchor.constraint(equalTo: currentHostLabel.bottomAnchor, constant: 12),
            inputContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            inputContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            inputContainerView.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 添加下拉按钮
        inputContainerView.addSubview(dropdownButton)
        dropdownButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropdownButton.trailingAnchor.constraint(equalTo: inputContainerView.trailingAnchor, constant: -8),
            dropdownButton.centerYAnchor.constraint(equalTo: inputContainerView.centerYAnchor),
            dropdownButton.widthAnchor.constraint(equalToConstant: 32),
            dropdownButton.heightAnchor.constraint(equalToConstant: 32)
        ])

        // 添加输入框
        inputContainerView.addSubview(hostTextField)
        hostTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostTextField.topAnchor.constraint(equalTo: inputContainerView.topAnchor),
            hostTextField.bottomAnchor.constraint(equalTo: inputContainerView.bottomAnchor),
            hostTextField.leadingAnchor.constraint(equalTo: inputContainerView.leadingAnchor, constant: 12),
            hostTextField.trailingAnchor.constraint(equalTo: dropdownButton.leadingAnchor, constant: -4)
        ])

        // 添加按钮容器
        containerView.addSubview(buttonContainerView)
        buttonContainerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buttonContainerView.topAnchor.constraint(equalTo: inputContainerView.bottomAnchor, constant: 20),
            buttonContainerView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            buttonContainerView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            buttonContainerView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
            buttonContainerView.heightAnchor.constraint(equalToConstant: 44)
        ])

        // 添加取消按钮
        buttonContainerView.addSubview(cancelButton)
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cancelButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            cancelButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            cancelButton.leadingAnchor.constraint(equalTo: buttonContainerView.leadingAnchor),
            cancelButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 0.48)
        ])

        // 添加确定按钮
        buttonContainerView.addSubview(confirmButton)
        confirmButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            confirmButton.topAnchor.constraint(equalTo: buttonContainerView.topAnchor),
            confirmButton.bottomAnchor.constraint(equalTo: buttonContainerView.bottomAnchor),
            confirmButton.trailingAnchor.constraint(equalTo: buttonContainerView.trailingAnchor),
            confirmButton.widthAnchor.constraint(equalTo: buttonContainerView.widthAnchor, multiplier: 0.48)
        ])

        updateDropdownButtonVisibility()
    }

    private func setupActions() {
        // 按钮事件
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        dropdownButton.addTarget(self, action: #selector(dropdownButtonTapped), for: .touchUpInside)

        // 点击下拉菜单外部关闭
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapOutsideDropdown(_:)))
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
    }

    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    private func updateDropdownButtonVisibility() {
        dropdownButton.isHidden = hostOptions.isEmpty
    }

    // MARK: - Keyboard Handling

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        let keyboardHeight = keyboardFrame.height
        let containerBottomY = containerView.frame.maxY
        let screenHeight = UIScreen.main.bounds.height
        let visibleHeight = screenHeight - keyboardHeight

        if containerBottomY > visibleHeight {
            let offset = containerBottomY - visibleHeight + 20
            UIView.animate(withDuration: duration) {
                self.containerCenterYConstraint?.constant = -offset
                self.layoutIfNeeded()
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }

        UIView.animate(withDuration: duration) {
            self.containerCenterYConstraint?.constant = 0
            self.layoutIfNeeded()
        }
    }

    // MARK: - Actions

    @objc private func handleTapOutsideDropdown(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)

        // 如果点击不在下拉菜单内，关闭下拉菜单
        if let tableView = dropdownTableView, !tableView.frame.contains(location) {
            hideDropdown()
        }
    }

    @objc private func confirmButtonTapped() {
        let host = hostTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        dismiss()
        onConfirm?(host)
    }

    @objc private func cancelButtonTapped() {
        dismiss()
        onCancel?()
    }

    @objc private func dropdownButtonTapped() {
        toggleDropdown()
    }

    // MARK: - Dropdown

    private func toggleDropdown() {
        if isDropdownVisible {
            hideDropdown()
        } else {
            showDropdown()
        }
    }

    private func showDropdown() {
        guard !hostOptions.isEmpty, window != nil else { return }

        // 先关闭键盘
        hostTextField.resignFirstResponder()

        isDropdownVisible = true

        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.backgroundColor = .systemBackground
        tableView.layer.cornerRadius = 8
        tableView.layer.masksToBounds = true
        tableView.layer.borderColor = UIColor.separator.cgColor
        tableView.layer.borderWidth = 1
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "HostOptionCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.rowHeight = 44
        tableView.showsVerticalScrollIndicator = true

        addSubview(tableView)

        // 计算下拉菜单位置（在输入框下方）
        let inputFrame = inputContainerView.convert(inputContainerView.bounds, to: self)
        let maxHeight: CGFloat = 200
        let tableHeight = min(CGFloat(hostOptions.count) * 44, maxHeight)

        // 清除之前的约束
        NSLayoutConstraint.deactivate(dropdownConstraints)
        dropdownConstraints.removeAll()

        // 创建新约束
        let topConstraint = tableView.topAnchor.constraint(equalTo: topAnchor, constant: inputFrame.maxY + 4)
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: inputFrame.minX)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: leadingAnchor, constant: inputFrame.maxX)
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableHeight)

        dropdownConstraints = [topConstraint, leadingConstraint, trailingConstraint, heightConstraint]
        NSLayoutConstraint.activate(dropdownConstraints)

        dropdownTableView = tableView
        layoutIfNeeded()

        // 动画显示
        tableView.alpha = 0
        UIView.animate(withDuration: 0.2) {
            tableView.alpha = 1
        }
    }

    private func hideDropdown() {
        guard isDropdownVisible else { return }

        isDropdownVisible = false

        UIView.animate(withDuration: 0.2, animations: {
            self.dropdownTableView?.alpha = 0
        }, completion: { _ in
            self.dropdownTableView?.removeFromSuperview()
            self.dropdownTableView = nil
            NSLayoutConstraint.deactivate(self.dropdownConstraints)
            self.dropdownConstraints.removeAll()
        })
    }

    // MARK: - Public Methods

    /// 设置输入的 Host
    public func setHost(_ host: String) {
        hostTextField.text = host
    }

    /// 显示弹窗
    public func show(in view: UIView) {
        frame = view.bounds
        view.addSubview(self)

        // 初始状态
        overlayView.alpha = 0
        containerView.alpha = 0
        containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)

        // 动画显示
        UIView.animate(withDuration: 0.25) {
            self.overlayView.alpha = 1
            self.containerView.alpha = 1
            self.containerView.transform = .identity
        }
    }

    /// 关闭弹窗
    public func dismiss() {
        hideDropdown()
        hostTextField.resignFirstResponder()

        UIView.animate(withDuration: 0.25, animations: {
            self.overlayView.alpha = 0
            self.containerView.alpha = 0
            self.containerView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }

    /// 便利方法：在 keyWindow 上显示
    public func show() {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first?
            .windows
            .first(where: { $0.isKeyWindow }) else {
            return
        }
        show(in: window)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension HostSwitchAlertView: UITableViewDelegate, UITableViewDataSource {

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return hostOptions.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HostOptionCell", for: indexPath)
        cell.textLabel?.text = hostOptions[indexPath.row]
        cell.textLabel?.font = .systemFont(ofSize: 14)
        cell.backgroundColor = .systemBackground
        cell.selectionStyle = .default
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedHost = hostOptions[indexPath.row]
        hostTextField.text = selectedHost
        hideDropdown()
    }
}

#endif
