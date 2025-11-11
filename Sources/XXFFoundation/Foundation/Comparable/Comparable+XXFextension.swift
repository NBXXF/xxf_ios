//
//  Comparable+XXFextension.swift
//  xxf_ios
//  Created by xxf on 6/12.
import Foundation

public extension Comparable {
    // 限定区间
    func clamp(min minValue: Self, max maxValue: Self) -> Self {
        return Swift.max(minValue, Swift.min(self, maxValue))
    }
}
