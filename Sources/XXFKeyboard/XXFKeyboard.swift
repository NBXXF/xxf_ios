//
//  XXFKeyboard.swift
//  XXFKeyboard
//
//  Created on 2026-03-18.
//

#if os(iOS)
import Foundation
import RxKeyboard

/// XXFKeyboard 模块
/// 基于 RxKeyboard 提供的键盘适配组件
///
/// 主要组件：
/// - KeyboardResizeContainer: 类似 Android adjustPan 的容器，自动调整高度适配键盘
/// - KeyboardPanelContainer: 高度等于键盘高度的容器，用于表情/功能面板
/// - KeyboardHeightProvider: 全局键盘高度缓存（UserDefaults 持久化），解决首次显示高度问题
/// - KeyboardFocusManagerView: 聊天列表键盘管理容器，支持滚动/滑动/点击收起键盘
///
/// ## 核心特性
///
/// - **UserDefaults 持久化**: 键盘高度自动保存，App 重启后仍可用
/// - **设备区分**: 根据屏幕尺寸生成缓存 Key，区分 iPhone/iPad
/// - **方向区分**: 分别缓存横屏和竖屏的键盘高度
/// - **自动更新**: 键盘弹出时自动检测并更新缓存
///
/// ## 启动配置
///
/// 建议在 AppDelegate 中启动监听（只需一次）：
///
/// ```swift
/// import XXFKeyboard
///
/// // AppDelegate.swift
/// func application(_ application: UIApplication,
///                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
///     // 开启全局键盘高度监听
///     // 会自动从 UserDefaults 读取上次缓存的高度
///     KeyboardHeightProvider.shared.startMonitoring()
///     return true
/// }
/// ```
///
/// ## 高度获取优先级
///
/// 1. **内存缓存**（当前会话已获取）
/// 2. **UserDefaults 持久化缓存**（上次使用时的真实高度）
/// 3. **预估高度**（基于设备类型的保守估计）
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
