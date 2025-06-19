//
//  OptionalProtocol.swift
//  xxf_ios
//
//  Created by xxf on 6/19.
//

public protocol OptionalProtocol {
    var isNil: Bool { get }
}

public extension Optional: OptionalProtocol {
    var isNil: Bool { self == nil }
}
