//
//  KeyboardHeightProvider.swift
//  XXFKeyboard
//
//  Created on 04-11.
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
/// 本类通过 `UserDefaults` 持久化缓存键盘高度，解决以下场景：
/// - App 重启后首次使用 `KeyboardPanelContainer(mode: .always)` 时显示正确高度
/// - 跨页面共享键盘高度，避免每个页面重新获取
/// - 支持横竖屏不同高度的独立缓存
///
/// ## 缓存策略
///
/// 1. **持久化存储**: 使用 `UserDefaults` 保存键盘高度，App 重启后仍然有效
/// 2. **设备区分**: 根据屏幕尺寸生成缓存 Key，区分不同设备（iPhone/iPad）
/// 3. **方向区分**: 分别缓存横屏和竖屏的键盘高度
/// 4. **自动更新**: 键盘弹出时自动检测并更新缓存
///
/// ## 高度获取优先级
///
/// 1. **内存缓存**（当前会话已获取）
/// 2. **UserDefaults 持久化缓存**（上次使用时的真实高度）
/// 3. **预估高度**（基于设备类型的保守估计）
///
/// ## 使用方式
///
/// ```swift
/// // 在 AppDelegate 或 @main 中启动监听（只需一次）
/// KeyboardHeightProvider.shared.startMonitoring()
///
/// // 获取当前键盘高度（按优先级：内存 → 持久化 → 预估）
/// let height = KeyboardHeightProvider.shared.currentHeight
///
/// // 判断是否有真实缓存（非预估）
/// if KeyboardHeightProvider.shared.hasRealCache {
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
/// - 预估高度可能与实际高度有偏差（±10pt），会在键盘首次弹出后自动修正并缓存
/// - 更换设备后首次使用会回到预估高度，键盘弹出后自动更新
/// - iPad 浮动键盘高度变化较大，建议使用 `.auto` 模式
/// - 系统键盘设置变化（如添加新键盘）可能导致高度变化，会自动更新缓存
///
@MainActor
public final class KeyboardHeightProvider {

    // MARK: - Constants

    private enum Constants {
        /// UserDefaults Key 前缀
        static let cacheKeyPrefix = "com.xxf.keyboard.height"
        /// 缓存版本号（用于未来兼容性）
        static let cacheVersion = 1
    }

    // MARK: - Singleton

    /// 全局共享实例
    public static let shared = KeyboardHeightProvider()

    // MARK: - Properties

    /// 当前缓存的键盘高度（内存缓存）
    private var _memoryCachedHeight: CGFloat?

    /// 当前屏幕方向
    private var currentOrientation: UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }

    /// 是否已经开始监听
    private var isMonitoring = false

    /// 监听用的 DisposeBag，stop 后会重新创建
    private var disposeBag = DisposeBag()

    /// 键盘高度变化的 Driver（单例缓存）
    private lazy var heightDriver: Driver<CGFloat> = {
        return RxKeyboard.instance.visibleHeight
            .do(onNext: { [weak self] height in
                guard let self = self, height > 0 else { return }
                self.updateCachedHeight(height)
            })
    }()

    // MARK: - Public Properties

    /// 当前缓存的键盘高度
    ///
    /// 获取优先级：
    /// 1. 内存缓存（当前会话已获取）
    /// 2. UserDefaults 持久化缓存（上次使用时的真实高度）
    /// 3. 预估高度（基于设备类型的保守估计）
    @MainActor
    public var currentHeight: CGFloat {
        // 1. 优先返回内存缓存
        if let memoryHeight = _memoryCachedHeight, memoryHeight > 0 {
            return memoryHeight
        }

        // 2. 尝试读取持久化缓存
        if let persistedHeight = loadPersistedHeight(), persistedHeight > 0 {
            // 同步到内存缓存
            _memoryCachedHeight = persistedHeight
            return persistedHeight
        }

        // 3. 返回预估高度
        return estimatedKeyboardHeight
    }

    /// 是否有真实缓存的高度（非预估）
    ///
    /// 用于判断是否可以信任 `currentHeight` 为真实键盘高度
    /// - Note: 内部使用，不暴露给外部调用者
    internal var hasRealCache: Bool {
        // 内存缓存优先
        if let memoryHeight = _memoryCachedHeight, memoryHeight > 0 {
            return true
        }
        // 检查持久化缓存
        if let persistedHeight = loadPersistedHeight(), persistedHeight > 0 {
            return true
        }
        return false
    }

    /// 原始内存缓存高度（可能为 nil）
    internal var rawMemoryCachedHeight: CGFloat? {
        return _memoryCachedHeight
    }

    /// 预估键盘高度（基于 iOS 设计规范）
    ///
    /// iOS 键盘高度参考值（竖屏）：
    /// - iPhone SE/8: ~216 pt
    /// - iPhone X/11/12/13/14: ~291 pt
    /// - iPhone 14 Pro Max: ~301 pt
    /// - iPhone 16 Pro Max: ~311 pt
    /// - iPad: ~400+ pt（浮动键盘）
    ///
    /// 这里使用一个保守的估计值，实际高度会在键盘第一次弹出后自动修正并缓存
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
    @MainActor
    public var estimatedKeyboardHeightLandscape: CGFloat {
        return 200
    }

    // MARK: - Initialization

    private init() {
        // 预加载持久化缓存到内存
        _memoryCachedHeight = loadPersistedHeight()
    }

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
                self.updateCachedHeight(height)
            })
            .disposed(by: disposeBag)
    }

    /// 停止监听键盘高度变化
    ///
    /// 停止后已缓存的高度仍然保留（内存 + 持久化）。
    /// 如需清除缓存，调用 `reset()`。
    public func stopMonitoring() {
        isMonitoring = false
        disposeBag = DisposeBag()
    }

    /// 手动更新键盘高度
    ///
    /// 通常不需要手动调用，用于测试或特殊场景（如从通知扩展获取键盘高度）。
    /// 更新后会同时更新内存缓存和持久化缓存。
    ///
    /// - Parameter height: 新的键盘高度（pt）
    public func updateHeight(_ height: CGFloat) {
        updateCachedHeight(height)
    }

    /// 重置缓存的键盘高度
    ///
    /// 清除内存缓存和持久化缓存，下次 `currentHeight` 将返回预估高度。
    public func reset() {
        _memoryCachedHeight = nil
        clearPersistedCache()
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

    /// 强制刷新缓存（从 UserDefaults 重新读取）
    ///
    /// 适用于在多窗口场景下其他进程可能更新了缓存的情况。
    public func refreshCache() {
        _memoryCachedHeight = loadPersistedHeight()
    }

    // MARK: - Private Methods

    /// 更新缓存高度（内存 + 持久化）
    private func updateCachedHeight(_ height: CGFloat) {
        guard height > 0 else { return }

        // 避免微小变化触发写入（优化性能）
        let currentCached = _memoryCachedHeight ?? 0
        guard abs(currentCached - height) > 0.5 else { return }

        // 更新内存缓存
        _memoryCachedHeight = height

        // 持久化到 UserDefaults
        persistHeight(height)
    }

    /// 生成缓存 Key
    ///
    /// Key 格式: `com.xxf.keyboard.height.{screenWidth}x{screenHeight}.{orientation}`
    /// 示例: `com.xxf.keyboard.height.393x852.portrait`
    ///
    /// 通过屏幕尺寸区分不同设备（iPhone/iPad）
    /// 通过方向区分横竖屏
    private func cacheKey(for orientation: UIInterfaceOrientation) -> String {
        let screenSize = UIScreen.main.bounds.size
        let width = Int(screenSize.width)
        let height = Int(screenSize.height)
        let orientationKey = orientation.isLandscape ? "landscape" : "portrait"
        return "\(Constants.cacheKeyPrefix).\(width)x\(height).\(orientationKey)"
    }

    /// 持久化高度到 UserDefaults
    private func persistHeight(_ height: CGFloat) {
        let key = cacheKey(for: currentOrientation)
        UserDefaults.standard.set(height, forKey: key)
        UserDefaults.standard.set(Constants.cacheVersion, forKey: "\(key).version")
    }

    /// 从 UserDefaults 读取缓存高度
    private func loadPersistedHeight() -> CGFloat? {
        let key = cacheKey(for: currentOrientation)
        let height = UserDefaults.standard.double(forKey: key)
        return height > 0 ? height : nil
    }

    /// 清除持久化缓存
    private func clearPersistedCache() {
        let key = cacheKey(for: currentOrientation)
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.removeObject(forKey: "\(key).version")
    }
}

#endif
