//
//  TrackerConverterChain.swift
//  xxf_ios
//
//  Created by xxf on 10/14.
//

public protocol TrackerConverterChain {
    func convert(data: Any, extra: inout [AnyHashable: Any]) -> String
}
