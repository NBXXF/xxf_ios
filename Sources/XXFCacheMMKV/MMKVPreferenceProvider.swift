import Foundation
import MMKV
import XXFCache

open class MMKVPreferenceProvider: PreferenceProvider {
    public static var storage: any PreferencesStorage = {
        // 先判断是否已有默认实例，避免重复初始化。
        if let storage = MMKVPreferencesStorage() {
            return storage
        }

        MMKV.initialize(rootDir: nil)
        if let storage = MMKVPreferencesStorage() {
            return storage
        }

        return UserDefaults.standard
    }()

    public init() {}
}
