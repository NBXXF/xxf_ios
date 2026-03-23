//
//  AnyKey.swift
//  xxf_ios
//
//  Created by xxf
//

public struct AnyKey: CodingKey {
    public var stringValue: String
    public var intValue: Int? { nil }
    public init(stringValue: String) { self.stringValue = stringValue }
    public init?(intValue: Int) { nil }
}
