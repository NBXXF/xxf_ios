//
//  Array+XXFUnifed.swift
//  xxf_ios
//  array/set/dict 方法名字趋同
//  Created by xxf on 8/3.
//
public extension Array {
    mutating func add(_ element: Element) {
        append(element)
    }

    mutating func addAll<S: Sequence>(_ elements: S) where S.Element == Element {
        append(contentsOf: elements)
    }
}

public extension Array where Element: Equatable {
    mutating func remove(_ element: Element) {
        removeAll(where: { $0 == element })
    }

    mutating func removeAll<S: Sequence>(_ elements: S) where S.Element == Element {
        if let hashables = elements as? [AnyHashable] {
            let hashableSet = Set(hashables)
            removeAll {
                guard let anyHashable = $0 as? AnyHashable else { return false }
                return hashableSet.contains(anyHashable)
            }
        } else {
            removeAll { item in
                elements.contains(where: { $0 == item })
            }
        }
    }
}
