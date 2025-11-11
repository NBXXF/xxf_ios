//
//  Pair.swift
//  xxf_ios
//  用于简化元组 let pair: (first: Int, second: String) = (1, "Hello"),规避业务不写key的弊端 eg.（a,b）,业务解构的时候再声明key麻烦了
//  Created by xxf on 6/12.
//

public struct Pair<A, B>: CustomStringConvertible {
    public let first: A
    public let second: B

    public init(first: A, second: B) {
        self.first = first
        self.second = second
    }

    public var description: String {
        "Pair(\(first), \(second))"
    }
}
