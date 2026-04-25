import Foundation
import MMKV
import XXFCache

open class MMKVPreferencesStorage: PreferencesStorage {
    // MMKV 是“按类型读取”的接口，需额外记录每个 key 的值类型，
    // 才能在 object(forKey:) 中恢复为与写入一致的 Any 类型。
    private enum ValueType: String {
        case bool
        case int
        case double
        case float
        case string
        case data
        case url
        case date
    }

    private let mmkv: MMKV

    public init(mmkv: MMKV) {
        self.mmkv = mmkv
    }

    public convenience init?() {
        guard let mmkv = MMKV.default() else {
            return nil
        }
        self.init(mmkv: mmkv)
    }

    open func object(forKey key: String) -> Any? {
        // 先读取类型元数据，再用对应 MMKV API 取值，避免错读类型。
        guard let rawType = mmkv.string(forKey: typeKey(for: key)),
              let type = ValueType(rawValue: rawType)
        else {
            return nil
        }

        switch type {
        case .bool:
            return mmkv.bool(forKey: key)
        case .int:
            return Int(mmkv.int64(forKey: key))
        case .double:
            return mmkv.double(forKey: key)
        case .float:
            return mmkv.float(forKey: key)
        case .string:
            return mmkv.string(forKey: key)
        case .data:
            return mmkv.data(forKey: key)
        case .url:
            guard let urlString = mmkv.string(forKey: key) else { return nil }
            return URL(string: urlString)
        case .date:
            return Date(timeIntervalSince1970: mmkv.double(forKey: key))
        }
    }

    open func set(_ value: Any?, forKey key: String) {
        guard let value else {
            removeObject(forKey: key)
            return
        }

        switch value {
        case let boolValue as Bool:
            mmkv.set(boolValue, forKey: key)
            setType(.bool, forKey: key)
        case let intValue as Int:
            mmkv.set(Int64(intValue), forKey: key)
            setType(.int, forKey: key)
        case let doubleValue as Double:
            mmkv.set(doubleValue, forKey: key)
            setType(.double, forKey: key)
        case let floatValue as Float:
            mmkv.set(floatValue, forKey: key)
            setType(.float, forKey: key)
        case let stringValue as String:
            mmkv.set(stringValue, forKey: key)
            setType(.string, forKey: key)
        case let dataValue as Data:
            mmkv.set(dataValue, forKey: key)
            setType(.data, forKey: key)
        case let urlValue as URL:
            mmkv.set(urlValue.absoluteString, forKey: key)
            setType(.url, forKey: key)
        case let dateValue as Date:
            mmkv.set(dateValue.timeIntervalSince1970, forKey: key)
            setType(.date, forKey: key)
        default:
            // 与 UserDefaults 行为保持一致：不支持的类型按删除处理
            removeObject(forKey: key)
        }
    }

    open func removeObject(forKey key: String) {
        mmkv.removeValue(forKey: key)
        // 删除真实值时，同步删除类型元数据，避免脏类型残留。
        mmkv.removeValue(forKey: typeKey(for: key))
    }

    private func setType(_ type: ValueType, forKey key: String) {
        mmkv.set(type.rawValue, forKey: typeKey(for: key))
    }

    private func typeKey(for key: String) -> String {
        // 与业务 key 隔离，避免命名冲突。
        "__xxf_type__\(key)"
    }
}
