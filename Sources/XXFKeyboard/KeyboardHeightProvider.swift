//
//  KeyboardHeightProvider.swift
//  XXFKeyboard
//
//  Created on 2022-04-11.
//

#if os(iOS)
import RxCocoa
import RxKeyboard
import RxSwift
import UIKit

/// 键盘高度提供者 - 全局标准键盘高度缓存
///
/// ## 核心设计
///
/// 监听 RxKeyboard.visibleHeight，但只在键盘完全展开时（高度稳定后）缓存最大值。
/// 忽略拖动过程中的临时值，只保留观察到的最大稳定高度。
///
/// ## 缓存策略
///
/// 1. 监听 visibleHeight，实时更新会话最大值
/// 2. 当键盘收起（height = 0）时，将观察到的最大值写入缓存
/// 3. 下次启动时，读取上次缓存的最大值作为预估
///
@MainActor
public final class KeyboardHeightProvider {
    // MARK: - Constants

    private enum Constants {
        static let cacheKeyPrefix = "com.xxf.keyboard.height"
        static let minValidHeight: CGFloat = 200
    }

    // MARK: - Singleton

    public static let shared = KeyboardHeightProvider()

    // MARK: - Properties

    /// 当前会话观察到的最大高度
    private var sessionMaxHeight: CGFloat = 0

    /// 上次缓存的高度（内存）
    private var cachedHeight: CGFloat?

    private var isMonitoring = false
    private var disposeBag = DisposeBag()

    // MARK: - Public Properties

    /// 标准键盘高度（用于预估显示）
    ///
    /// 获取优先级：内存缓存 → UserDefaults → 预估
    @MainActor
    public var standardHeight: CGFloat {
        if let cached = cachedHeight, cached > 0 {
            return cached
        }
        if let persisted = loadFromDisk(), persisted > 0 {
            cachedHeight = persisted
            return persisted
        }
        return estimatedHeight
    }

    /// 是否有缓存的真实高度
    public var hasCachedHeight: Bool {
        cachedHeight != nil || loadFromDisk() != nil
    }

    /// 基于设备类型的预估高度
    @MainActor
    public var estimatedHeight: CGFloat {
        let h = UIScreen.main.bounds.height
        if UIDevice.current.userInterfaceIdiom == .pad { return 400 }
        if h >= 950 { return 311 }
        if h >= 920 { return 301 }
        if h >= 812 { return 291 }
        if h >= 667 { return 260 }
        return 216
    }

    // MARK: - Initialization

    private init() {
        cachedHeight = loadFromDisk()
    }

    // MARK: - Public Methods

    /// 开始监听键盘高度
    ///
    /// 监听 visibleHeight：
    /// - 当 height > 0 时，更新 sessionMaxHeight 并实时更新内存缓存
    /// - 当 height = 0 时（键盘收起），将最大值持久化到磁盘
    public func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        disposeBag = DisposeBag()

        RxKeyboard.instance.visibleHeight
            .drive(onNext: { [weak self] height in
                guard let self = self else { return }

                if height > 0 {
                    // 键盘显示中，更新会话最大值
                    self.sessionMaxHeight = max(self.sessionMaxHeight, height)
                    // 实时更新内存缓存（不写入磁盘），让 standardHeight 立即可用
                    if self.sessionMaxHeight > (self.cachedHeight ?? 0) {
                        self.cachedHeight = self.sessionMaxHeight
                    }
                } else {
                    // 键盘收起，保存到磁盘
                    self.saveIfNeeded()
                }
            })
            .disposed(by: disposeBag)
    }

    /// 停止监听
    public func stopMonitoring() {
        isMonitoring = false
        disposeBag = DisposeBag()
    }

    /// 手动设置标准高度
    public func setStandardHeight(_ height: CGFloat) {
        guard height >= Constants.minValidHeight else { return }
        cachedHeight = height
        saveToDisk(height)
    }

    // MARK: - Private Methods

    /// 保存到磁盘（如果比缓存值大）
    private func saveIfNeeded() {
        guard sessionMaxHeight >= Constants.minValidHeight else { return }

        // 只保存比之前缓存大的值
        let previousMax = cachedHeight ?? loadFromDisk() ?? 0
        guard sessionMaxHeight > previousMax else { return }

        cachedHeight = sessionMaxHeight
        saveToDisk(sessionMaxHeight)
    }

    private func cacheKey() -> String {
        let size = UIScreen.main.bounds.size
        return "\(Constants.cacheKeyPrefix).\(Int(size.width))x\(Int(size.height))"
    }

    private func saveToDisk(_ height: CGFloat) {
        UserDefaults.standard.set(height, forKey: cacheKey())
    }

    private func loadFromDisk() -> CGFloat? {
        let h = UserDefaults.standard.double(forKey: cacheKey())
        return h >= Constants.minValidHeight ? h : nil
    }
}

#endif
