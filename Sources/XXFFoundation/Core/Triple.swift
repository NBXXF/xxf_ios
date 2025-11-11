//
//  Triple.swift
//  xxf_ios
//  let triple = Triple(first: 1, second: "Hello", third: 3.14),规避业务不写key的弊端 eg.（a,b,c）,业务解构的时候再声明key麻烦了
//  Created by xxf on 6/12.
//

public struct Triple<A, B, C>: CustomStringConvertible {
    public let first: A
    public let second: B
    public let third: C

    public init(first: A, second: B, third: C) {
        self.first = first
        self.second = second
        self.third = third
    }

    public var description: String {
        "Triple(\(first), \(second), \(third))"
    }
}
