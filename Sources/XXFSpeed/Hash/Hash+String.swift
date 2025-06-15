//
//  Hash+String.swift
//  xxf_ios
//
//  Created by trl on 6/15.
//
import Foundation
public extension String {
    /// 跨平台有问题
    func toFarmHash64() -> UInt64 {
        return HighwayHash.hash64(self.data(using: .utf8))
    }
}
