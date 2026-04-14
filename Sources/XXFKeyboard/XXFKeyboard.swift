//
//  XXFKeyboard.swift
//  XXFKeyboard
//
//  Created on 2022-03-18.
//

#if os(iOS)
import Foundation
import RxKeyboard

/// XXFKeyboard 模块
/// 基于 RxKeyboard 提供的键盘适配组件
///
/// 主要组件：
/// - KeyboardResizeContainer: 类似 Android adjustPan 的容器，自动调整高度适配键盘
/// - KeyboardPanelContainer: 高度等于键盘实时高度的容器，用于表情/功能面板
/// - KeyboardHeightProvider: 全局**标准键盘高度**缓存（只缓存完全展开的最大高度）
/// - KeyboardFocusManagerView: 聊天列表键盘管理容器，支持滚动/滑动/点击收起键盘
///
/// ## 核心设计原则
///
/// 1. **只缓存标准高度**: Provider 只缓存键盘完全展开时的最大高度，忽略拖动过程中的临时值
/// 2. **防抖缓存**: Provider 使用 0.3 秒 debounce，只缓存"稳定"后的高度
/// 3. **实时跟随**: PanelContainer 实时跟随键盘高度（带 throttle 性能优化）
/// 4. **预估备用**: 从未获取过键盘高度时，使用基于设备类型的预估高度
///
/// ## 启动配置
///
/// ```swift
/// // AppDelegate.swift
/// func application(_ application: UIApplication,
///                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///     // 开启全局键盘高度监听
///     KeyboardHeightProvider.shared.startMonitoring()
///     return true
/// }
/// ```
///
/// ## 高度获取
///
/// ```swift
/// // 获取标准高度（用于预估，不随拖动变化）
/// let standardHeight = KeyboardHeightProvider.shared.standardHeight
///
/// // 获取实时高度（用于动画跟随，会随拖动变化）
/// KeyboardHeightProvider.shared.realtimeHeight
///     .drive(onNext: { height in
///         // 实时更新 UI
///     })
/// ```
///
/// 使用示例：
/// ```swift
/// import XXFKeyboard
///
/// // 1. 键盘自适应容器（内容区域自动上移）
/// class ViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         let container = KeyboardResizeContainer()
///         view.addSubview(container)
///         container.snp.makeConstraints {
///             $0.edges.equalTo(view.safeAreaLayoutGuide)
///         }
///
///         let contentView = UIView()
///         container.bindContentView(contentView)
///     }
/// }
///
/// // 2. 键盘面板容器（高度跟随键盘）
/// class ChatViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         // 自动模式：键盘收起时高度为0，弹出时等于键盘高度
///         let emojiPanel = KeyboardPanelContainer(mode: .auto)
///         view.addSubview(emojiPanel)
///         emojiPanel.snp.makeConstraints {
///             $0.leading.trailing.bottom.equalToSuperview()
///         }
///
///         // 总是显示模式：始终占用键盘高度（首次使用预估高度）
///         let toolbar = KeyboardPanelContainer(mode: .always)
///     }
/// }
///
/// // 3. 聊天键盘管理
/// class ChatViewController: UIViewController {
///     override func viewDidLoad() {
///         super.viewDidLoad()
///
///         let keyboardManager = KeyboardFocusManagerView()
///         view.addSubview(keyboardManager)
///         keyboardManager.snp.makeConstraints { $0.edges.equalToSuperview() }
///
///         let tableView = UITableView()
///         keyboardManager.bindScrollView(tableView)
///
///         let inputBar = InputBarView()
///         keyboardManager.setInputBar(inputBar)
///     }
/// }
/// ```
public struct XXFKeyboard {

    /// 获取单例 RxKeyboard 实例
    /// 可以直接使用它来订阅键盘事件
    public static nonisolated(unsafe) let instance = RxKeyboard.instance

    private init() {}
}

// MARK: - Re-exports

// 重新暴露 RxKeyboard 的类型，方便使用者
public typealias KeyboardFrameObservable = RxKeyboard

#endif
