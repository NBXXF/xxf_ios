//
//  Array+XXFDiff.swift
//  xxf_ios
//  数组的拓展
//  Created by xxf on 7/8.
//

public enum DiffResult<Element> {
    case added(Element)
    case deleted(Element)
    case updated(old: Element, new: Element)
}

public extension Array {
    /// 计算两个数组的差异，支持新增、删除、修改
    /// 比官方的更自由    public func difference<C>(from other: C) -> CollectionDifference<Element> where C : BidirectionalCollection, Element == C.Element
    /// - Parameters:
    ///   - from: 另一个数组
    ///   - keySelector: 用于唯一标识元素的闭包
    ///   - hasChanges: 比较两个同id元素是否“有修改”，返回 true 表示有修改
    /// - Returns: 元组 (deleted, added, modified)
    func diff<Id: Hashable>(
        from other: [Element],
        keySelector: (Element) -> Id,
        hasChanges: (Element, Element) -> Bool
    ) -> (deleted: [Element], added: [Element], updated: [(old: Element, new: Element)]) {
        let oldDict = Dictionary(uniqueKeysWithValues: map { (keySelector($0), $0) })
        let newDict = Dictionary(uniqueKeysWithValues: other.map { (keySelector($0), $0) })

        var deleted = [Element]()
        var added = [Element]()
        var updated = [(old: Element, new: Element)]()

        for (key, oldElement) in oldDict {
            if newDict[key] == nil {
                deleted.append(oldElement)
            }
        }

        for (key, newElement) in newDict {
            if let oldElement = oldDict[key] {
                if hasChanges(oldElement, newElement) {
                    updated.append((old: oldElement, new: newElement))
                }
            } else {
                added.append(newElement)
            }
        }

        return (deleted, added, updated)
    }

    /// 计算两个数组的差异，返回扁平化的枚举形式
    /// - Parameters:
    ///   - other: 对比的另一个数组
    ///   - keySelector: 用于提取元素的唯一标识符
    ///   - hasChanges: 判断同一元素是否发生了变化
    /// - Returns: `[DiffResult]` 枚举数组，包含新增、删除、修改项
    func diff<Id: Hashable>(
        from other: [Element],
        keySelector: (Element) -> Id,
        hasChanges: (Element, Element) -> Bool
    ) -> [DiffResult<Element>] {
        let oldDict = Dictionary(uniqueKeysWithValues: map { (keySelector($0), $0) })
        let newDict = Dictionary(uniqueKeysWithValues: other.map { (keySelector($0), $0) })

        var result = [DiffResult<Element>]()

        for (key, oldElement) in oldDict {
            if newDict[key] == nil {
                result.append(.deleted(oldElement))
            }
        }

        for (key, newElement) in newDict {
            if let oldElement = oldDict[key] {
                if hasChanges(oldElement, newElement) {
                    result.append(.updated(old: oldElement, new: newElement))
                }
            } else {
                result.append(.added(newElement))
            }
        }

        return result
    }
}

// MARK: - 基础类型标记协议

public protocol BasicHashable: Hashable {}
extension Int: BasicHashable {}
extension String: BasicHashable {}
extension Double: BasicHashable {}
extension Float: BasicHashable {}
extension Bool: BasicHashable {}

// MARK: - 基础类型简化版扩展

public extension Array where Element: BasicHashable {
    /// 针对基础类型（Int/String/Bool等），简单计算当前数组相对于 `from` 的差异
    /// - Parameter from: 原始数组（旧值）
    /// - Returns: (deleted, added)：被删除的元素、新增的元素
    func diff(from: [Element]) -> (deleted: [Element], added: [Element]) {
        let oldSet = Set(from) // 原数组是“旧的”
        let newSet = Set(self) // 当前 self 是“新的”
        let deleted = oldSet.subtracting(newSet) // 从旧中删除了什么
        let added = newSet.subtracting(oldSet) // 新增了什么
        return (Array(deleted), Array(added))
    }
}
