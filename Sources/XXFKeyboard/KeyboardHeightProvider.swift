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

/// 键盘高度提供者 - 全局标准键盘高度缓存
///
/// ## 设计目的
///
/// iOS 没有官方 API 可以预测键盘高度。本类通过 `UserDefaults` 持久化缓存**标准键盘高度**
///（即键盘完全展开时的最大高度），解决以下场景：
/// - App 重启后首次使用 `KeyboardPanelContainer(mode: .always)` 时显示正确高度
/// - 跨页面共享键盘标准高度
///
/// ## 核心设计原则
///
/// 1. **只缓存最大高度**: 忽略拖动过程中的临时小值，只保留观察到的最大值
/// 2. **防抖更新**: 使用 0.3 秒 debounce，只缓存"稳定"后的高度
/// 3. **区分实时与缓存**: 实时高度通过 RxKeyboard 获取，缓存只用于预估
///
/// ## 缓存策略
///
/// - 键盘收起时高度为 0，**不缓存**（排除收起状态）
/// - 键盘高度持续变化时（拖动），**不缓存**
/// - 键盘高度稳定 0.3 秒后，且为当前会话最大值，**更新缓存**
///
/// ## 高度获取优先级
///
/// 1. **内存缓存**（当前会话观察到的最大稳定高度）
/// 2. **UserDefaults 持久化缓存**（历史最大稳定高度）
/// 3. **预估高度**（基于设备类型）
///
@MainActor
public final class KeyboardHeightProvider {

    // MARK: - Constants

    private enum Constants {
        static let cacheKeyPrefix = "com.xxf.keyboard.height.stable"
        static let debounceInterval: RxTimeInterval = .milliseconds(300)
        static let minStableHeight: CGFloat = 200  // 最小有效键盘高度（排除拖动小值）
    }

    // MARK: - Singleton

    public static let shared = KeyboardHeightProvider()

    // MARK: - Properties

    /// 当前会话观察到的最大键盘高度（实时更新，非缓存）
    private var _currentSessionMaxHeight: CGFloat = 0

    /// 已缓存的标准高度（内存）
    private var _cachedStableHeight: CGFloat?

    /// 是否已经开始监听
    private var isMonitoring = false

    /// 监听用的 DisposeBag
    private var disposeBag = DisposeBag()

    // MARK: - Public Properties

    /// 标准键盘高度（用于预估）
    ///
    /// 获取优先级：内存缓存 → UserDefaults → 预估
    /// 这个值代表"键盘完全展开时的典型高度"，不随拖动变化
    @MainActor
    public var standardHeight: CGFloat {
        // 1. 内存缓存
        if let cached = _cachedStableHeight, cached > 0 {
            return cached
        }
        // 2. 持久化缓存
        if let persisted = loadPersistedHeight(), persisted > 0 {
            _cachedStableHeight = persisted
            return persisted
        }
        // 3. 预估
        return estimatedHeight
    }

    /// 实时键盘高度（通过 RxKeyboard 直接获取）
    ///
    /// 用于需要实时跟随的场景（如 .auto 模式的面板动画）
    /// **注意**: 这个值包含拖动过程中的临时高度，不应被缓存
    public var realtimeHeight: Driver<CGFloat> {
        return RxKeyboard.instance.visibleHeight
    }

    /// 是否有缓存的标准高度
    public var hasCachedHeight: Bool {
        if let cached = _cachedStableHeight, cached > 0 { return true }
        if let persisted = loadPersistedHeight(), persisted > 0 { return true }
        return false
    }

    /// 预估键盘高度（基于设备类型）
    @MainActor
    public var estimatedHeight: CGFloat {
        let screenSize = UIScreen.main.bounds.size
        let screenHeight = max(screenSize.width, screenSize.height)

        if UIDevice.current.userInterfaceIdiom == .pad {
            return 400
        }

        if screenHeight >= 950 { return 311 }
        else if screenHeight >= 920 { return 301 }
        else if screenHeight >= 812 { return 291 }
        else if screenHeight >= 667 { return 260 }
        return 216
    }

    // MARK: - Initialization

    private init() {
        _cachedStableHeight = loadPersistedHeight()
    }

    // MARK: - Public Methods

    /// 开始监听键盘高度
    ///
    /// 使用防抖策略：只缓存稳定后的最大高度
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        disposeBag = DisposeBag()

        RxKeyboard.instance.visibleHeight
            .do(onNext: { [weak self] height in
                // 实时更新会话最大值（但不缓存）
                guard let self = self, height > 0 else { return }
                self._currentSessionMaxHeight = max(self._currentSessionMaxHeight, height)
            })
            // 防抖：只处理稳定后的高度
            .debounce(Constants.debounceInterval, scheduler: MainScheduler.instance)
            .drive(onNext: { [weak self] height in
                guard let self = self else { return }
                self.updateStableHeight(height)
            })
            .disposed(by: disposeBag)
    }

    /// 停止监听
    public func stopMonitoring() {
        isMonitoring = false
        disposeBag = DisposeBag()
    }

    /// 手动设置标准高度（测试用）
    public func setStandardHeight(_ height: CGFloat) {
        guard height >= Constants.minStableHeight else { return }
        _cachedStableHeight = height
        persistHeight(height)
    }

    /// 重置缓存
    public func reset() {
        _cachedStableHeight = nil
        _currentSessionMaxHeight = 0
        clearPersistedCache()
    }

    // MARK: - Private Methods

    /// 更新稳定高度
    private func updateStableHeight(_ height: CGFloat) {
        // 只处理有效高度（排除收起状态和拖动小值）
        guard height >= Constants.minStableHeight else { return }

        // 只缓存最大值（确保是键盘完全展开的高度）
        let maxHeight = max(height, _currentSessionMaxHeight)

        // 避免频繁写入（变化小于 5pt 忽略）
        if let cached = _cachedStableHeight, abs(cached - maxHeight) < 5 {
            return
        }

        _cachedStableHeight = maxHeight
        persistHeight(maxHeight)
    }

    /// 生成缓存 Key
    private func cacheKey() -> String {
        let screenSize = UIScreen.main.bounds.size
        let width = Int(screenSize.width)
        let height = Int(screenSize.height)
        let orientation = UIDevice.current.orientation.isLandscape ? "landscape" : "portrait"
        return "\(Constants.cacheKeyPrefix).\(width)x\(height).\(orientation)"
    }

    /// 持久化高度
    private func persistHeight(_ height: CGFloat) {
        UserDefaults.standard.set(height, forKey: cacheKey())
    }

    /// 读取持久化高度
    private func loadPersistedHeight() -> CGFloat? {
        let height = UserDefaults.standard.double(forKey: cacheKey())
        return height >= Constants.minStableHeight ? height : nil
    }

    /// 清除持久化缓存
    private func clearPersistedCache() {
        UserDefaults.standard.removeObject(forKey: cacheKey())
    }
}

#endif
