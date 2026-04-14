//
//  KeyboardResizeContainer+Example.swift
//  XXFKeyboard
//
//  Created on 2022-03-18.
//
//  使用示例

#if os(iOS)
import UIKit
import RxSwift
import SnapKit

/// 使用示例 1: 基础用法
///
/// ```swift
/// class ViewController: UIViewController {
///
///     private let disposeBag = DisposeBag()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 创建容器
///         let container = KeyboardResizeContainer()
///         view.addSubview(container)
///         container.snp.makeConstraints {
///             $0.edges.equalTo(view.safeAreaLayoutGuide)
///         }
///
///         // 创建内容视图
///         let contentView = UIView()
///         contentView.backgroundColor = .white
///         container.bindContentView(contentView)
///
///         // 添加输入框
///         let textField = UITextField()
///         textField.borderStyle = .roundedRect
///         contentView.addSubview(textField)
///         textField.snp.makeConstraints {
///             $0.leading.trailing.equalToSuperview().inset(20)
///             $0.bottom.equalToSuperview().offset(-100)
///             $0.height.equalTo(44)
///         }
///
///         // 点击空白处收起键盘
///         container.addTapToDismiss()
///     }
/// }
/// ```
///
/// 使用示例 2: 带 ScrollView 的用法
///
/// ```swift
/// class FormViewController: UIViewController {
///
///     private let scrollView = UIScrollView()
///     private let disposeBag = DisposeBag()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 创建容器
///         let container = KeyboardResizeContainer()
///         view.addSubview(container)
///         container.snp.makeConstraints {
///             $0.edges.equalTo(view.safeAreaLayoutGuide)
///         }
///
///         // 绑定 scrollView
///         container.bindContentView(scrollView)
///
///         // 创建内容容器
///         let content = UIView()
///         scrollView.addSubview(content)
///         content.snp.makeConstraints {
///             $0.edges.equalTo(scrollView.contentLayoutGuide)
///             $0.width.equalTo(scrollView.frameLayoutGuide)
///         }
///
///         // 添加多个输入框
///         let stackView = UIStackView()
///         stackView.axis = .vertical
///         stackView.spacing = 16
///         content.addSubview(stackView)
///         stackView.snp.makeConstraints {
///             $0.edges.equalToSuperview().inset(20)
///         }
///
///         for i in 0..<10 {
///             let textField = UITextField()
///             textField.placeholder = "Field \(i)"
///             textField.borderStyle = .roundedRect
///             stackView.addArrangedSubview(textField)
///         }
///
///         // 自动处理 scrollView 的键盘适配
///         container.bindScrollView(scrollView)
///         container.addTapToDismiss()
///     }
/// }
/// ```
///
/// 使用示例 3: 直接订阅键盘事件
///
/// ```swift
/// class ViewController: UIViewController {
///
///     private let disposeBag = DisposeBag()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 方式 1: 通过 XXFKeyboard 单例
///         XXFKeyboard.instance.visibleHeight
///             .drive(onNext: { height in
///                 print("键盘高度：\(height)")
///                 // 根据需要调整 UI
///             })
///             .disposed(by: disposeBag)
///
///         // 方式 2: 通过容器的 keyboardVisibleHeight
///         let container = KeyboardResizeContainer()
///         container.keyboardVisibleHeight
///             .drive(onNext: { height in
///                 print("键盘高度：\(height)")
///             })
///             .disposed(by: disposeBag)
///
///         // 订阅键盘 frame 变化
///         container.keyboardFrame
///             .drive(onNext: { frame in
///                 print("键盘 frame: \(frame)")
///             })
///             .disposed(by: disposeBag)
///     }
/// }
/// ```
///
/// 使用示例 4: 类似 iOS 原生消息列表的布局
///
/// ```swift
/// class MessageViewController: UIViewController {
///
///     private let tableView = UITableView()
///     private let inputContainer = UIView()
///     private let textField = UITextField()
///     private let disposeBag = DisposeBag()
///
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 创建主容器
///         let container = KeyboardResizeContainer()
///         view.addSubview(container)
///         container.snp.makeConstraints {
///             $0.edges.equalTo(view.safeAreaLayoutGuide)
///         }
///
///         // 内容视图
///         let contentView = UIView()
///         container.bindContentView(contentView)
///
///         // TableView
///         contentView.addSubview(tableView)
///         tableView.snp.makeConstraints {
///             $0.top.leading.trailing.equalToSuperview()
///             $0.bottom.equalTo(inputContainer.snp.top)
///         }
///
///         // 底部输入区域
///         contentView.addSubview(inputContainer)
///         inputContainer.snp.makeConstraints {
///             $0.leading.trailing.bottom.equalToSuperview()
///             $0.height.equalTo(50)
///         }
///
///         inputContainer.addSubview(textField)
///         textField.snp.makeConstraints {
///             $0.edges.equalToSuperview().inset(8)
///         }
///
///         // 自动适配键盘
///         container.bindScrollView(tableView)
///     }
/// }
/// ```
public struct KeyboardResizeContainerExample {
    // 这个文件仅用于文档说明，不需要实际代码
}

#endif
