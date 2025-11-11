//
//  Array+XXFUniqued.swift
//  xxf_ios
//
//  Created by xxf on 7/25.
//

public extension Array where Element: Hashable {
    /// 转换set
    func toSet() -> Set<Element> { Set(self) }

    /// 去重
    func distincted() -> [Element] {
        var seen = Set<Element>()
        return filter { element in
            if seen.contains(element) {
                return false
            } else {
                seen.insert(element)
                return true
            }
        }
    }
}

public extension Array {
    /// 根据闭包返回的 Key 去重，保留第一个出现的元素
    func distinctBy<K: Hashable>(_ keySelector: (Element) -> K) -> [Element] {
        var seenKeys = Set<K>()
        return filter { element in
            let key = keySelector(element)
            if seenKeys.contains(key) {
                return false
            } else {
                seenKeys.insert(key)
                return true
            }
        }
    }
}
