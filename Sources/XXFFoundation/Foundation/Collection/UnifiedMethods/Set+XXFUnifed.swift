//
//  Array+XXFUnifed.swift
//  xxf_ios
//  array/set/dict 方法名字趋同
//  Created by xxf on 8/3.
//
public extension Set {
    mutating func add(_ element: Element) {
        insert(element)
    }

    mutating func addAll<S: Sequence>(_ elements: S) where S.Element == Element {
        formUnion(elements)
    }

    mutating func removeAll<S: Sequence>(_ elements: S) where S.Element == Element {
        subtract(elements)
    }

    mutating func clear() {
        removeAll()
    }
}
