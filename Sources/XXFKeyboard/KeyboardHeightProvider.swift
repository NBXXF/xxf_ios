//
//  KeyboardHeightProvider.swift
//  XXFKeyboard
//
//  Created on 2026-04-11.
//

#if os(iOS)
import UIKit
import RxSwift
import RxCocoa
import RxKeyboard

/// 键盘高度提供者 - 全局键盘高度缓存与预估
///
/// ## 设计目的
///
/// iOS 没有官方 API 可以预测键盘高度，必须在键盘弹出后才能获取真实高度。
/// 本类通过全局单例模式缓存键盘高度，解决以下场景：
/// - 首次进入页面时键盘面板容器（`KeyboardPanelContainer`）需要显示默认高度
/// - 跨页面共享键盘高度，避免每个页面重新获取
///
/// ## 高度优先级
///
/// 1. **已缓存的真实高度**（用户曾弹出过键盘）
/// 2. **预估高度**（基于设备类型和屏幕尺寸）
///
/// ## 使用方式
///
/// ```swift
/// // 在 AppDelegate 或 @main 中启动监听（只需一次）
/// KeyboardHeightProvider.shared.startMonitoring()
///
/// // 获取当前键盘高度（缓存值或预估值）
/// let height = KeyboardHeightProvider.shared.currentHeight
///
/// // 判断是否有缓存值
/// if KeyboardHeightProvider.shared.hasCachedHeight {
///     print("使用真实高度: \(height)")
/// } else {
///     print("使用预估高度: \(height)")
/// }
/// ```
///
/// ## iPhone 预估高度参考
///
/// | 设备 | 屏幕尺寸 | 预估高度 |
/// |------|----------|----------|
/// | iPhone SE/8 | 667pt | 216pt |
/// | iPhone 12/13/14/15/16 | 812-852pt | 291pt |
/// | iPhone 14/15/16 Plus | 932pt | 301pt |
/// | iPhone 16 Pro Max | 956pt | 311pt |
/// | iPad | - | 400pt |
///
/// ## 注意事项
///
/// - 预估高度可能与实际高度有偏差（±10pt），会在键盘首次弹出后自动修正
/// - 横屏/竖屏高度不同，切换方向后会自动更新
/// - iPad 浮动键盘高度变化较大，建议使用 `.auto` 模式
///
@MainActor
public final class KeyboardHeightProvider {

    // MARK: - Singleton

    /// 全局共享实例
    public static let shared = KeyboardHeightProvider()

    // MARK: - Properties

    /// 当前缓存的键盘高度
    ///
    /// 如果从未获取过键盘高度（`hasCachedHeight == false`），返回 `estimatedKeyboardHeight`
    @MainActor
    public var currentHeight: CGFloat {
        get {
            if _cachedHeight == 0 {
                return estimatedKeyboardHeight
            }
            return _cachedHeight
        }
        set {
            _cachedHeight = newValue
        }
    }

    /// 实际缓存的高度（可能为 0）
    private var _cachedHeight: CGFloat = 0

    /// 是否已经开始监听
    private var isMonitoring = false

    /// 监听用的 DisposeBag，stop 后会重新创建
    private var disposeBag = DisposeBag()

    /// 键盘高度变化的 Driver（单例缓存）
    private lazy var heightDriver: Driver<CGFloat> = {
        return RxKeyboard.instance.visibleHeight
            .do(onNext: { [weak self] height in
                if height > 0 {
                    self?._cachedHeight = height
                }
            })
    }()

    // MARK: - Estimated Height

    /// 预估键盘高度（基于 iOS 设计规范）
    ///
    /// 根据设备类型和屏幕尺寸返回合理的预估高度。
    /// 预估高度可能与实际高度有偏差，会在键盘首次弹出后自动修正。
    ///
    /// ## 预估逻辑
    ///
    /// 1. iPad: 400pt（考虑浮动键盘）
    /// 2. iPhone 16 Pro Max (956pt+): 311pt
    /// 3. iPhone Plus/Max (920pt+): 301pt
    /// 4. iPhone 刘海屏 (812pt+): 291pt
    /// 5. iPhone 标准屏 (667pt+): 260pt
    /// 6. 小屏设备: 216pt
    @MainActor
    public var estimatedKeyboardHeight: CGFloat {
        let screenSize = UIScreen.main.bounds.size
        let screenHeight = max(screenSize.width, screenSize.height)

        if UIDevice.current.userInterfaceIdiom == .pad {
            return 400
        }

        if screenHeight >= 950 {
            return 311
        } else if screenHeight >= 920 {
            return 301
        } else if screenHeight >= 812 {
            return 291
        } else if screenHeight >= 667 {
            return 260
        }
        return 216
    }

    /// 预估键盘高度（横屏）
    ///
    /// 横屏时键盘高度通常较小（约 200pt）
    @MainActor
    public var estimatedKeyboardHeightLandscape: CGFloat {
        return 200
    }

    /// 是否有缓存的键盘高度
    ///
    /// 用于判断键盘是否曾经显示过，首次显示前为 `false`
    public var hasCachedHeight: Bool {
        return _cachedHeight > 0
    }

    /// 原始缓存高度（内部使用）
    ///
    /// - Warning: 可能为 0，表示从未获取过真实高度
    internal var rawCachedHeight: CGFloat {
        return _cachedHeight
    }

    // MARK: - Initialization

    private init() {}

    // MARK: - Public Methods

    /// 开始监听键盘高度变化
    ///
    /// 建议在 `AppDelegate.application(_:didFinishLaunchingWithOptions:)` 或 `@main` 中调用一次。
    /// 重复调用会被忽略，停止后再次调用会重新开始监听。
    ///
    /// ```swift
    /// // AppDelegate.swift
    /// func application(_ application: UIApplication,
    ///                  didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    ///     KeyboardHeightProvider.shared.startMonitoring()
    ///     return true
    /// }
    /// ```
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true

        // 创建新的 disposeBag，允许重新监听
        disposeBag = DisposeBag()

        heightDriver
            .drive(onNext: { [weak self] height in
                guard let self = self, height > 0 else { return }
                self._cachedHeight = height
            })
            .disposed(by: disposeBag)
    }

    /// 停止监听键盘高度变化
    ///
    /// 停止后已缓存的高度仍然保留，可通过 `currentHeight` 获取。
    /// 如需清除缓存，调用 `reset()`。
    public func stopMonitoring() {
        isMonitoring = false
        disposeBag = DisposeBag()
    }

    /// 手动更新键盘高度
    ///
    /// 通常不需要手动调用，用于测试或特殊场景（如从通知扩展获取键盘高度）。
    ///
    /// - Parameter height: 新的键盘高度（pt）
    public func updateHeight(_ height: CGFloat) {
        self._cachedHeight = height
    }

    /// 重置缓存的键盘高度
    ///
    /// 清除已缓存的高度，下次 `currentHeight` 将返回预估高度。
    public func reset() {
        self._cachedHeight = 0
    }

    /// 获取当前预估高度（考虑屏幕方向）
    ///
    /// - Parameter orientation: 屏幕方向
    /// - Returns: 预估键盘高度
    @MainActor
    public func estimatedHeight(for orientation: UIInterfaceOrientation) -> CGFloat {
        if orientation.isLandscape {
            return estimatedKeyboardHeightLandscape
        }
        return estimatedKeyboardHeight
    }
}

#endif
