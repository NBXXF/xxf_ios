import Foundation
import MMKV
import XXFCache

open class MMKVPreferenceProvider: PreferenceProvider {
    public static let storage: any PreferencesStorage & Sendable = {
        // MMKV 要求第一次使用前必须先调用 initializeMMKV，
        // 否则 MMKV.default() / 任何其他 API 都会 NSAssert 崩溃。
        MMKV.initialize(rootDir: nil)
        if let storage = MMKVPreferencesStorage() {
            return storage
        }
        // 极端情况下 MMKV 初始化失败，兜底到 UserDefaults，保证业务可用。
        return UserDefaults.standard
    }()

    public init() {}
}
