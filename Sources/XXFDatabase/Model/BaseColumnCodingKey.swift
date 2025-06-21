//
//  BaseColumnCodingKey.swift
//  xxf_ios
//  列定义映射
//  Created by trl on 6/21.
//

public protocol BaseColumnCodingKey: CodingKey, CaseIterable, RawRepresentable where RawValue == String {}
