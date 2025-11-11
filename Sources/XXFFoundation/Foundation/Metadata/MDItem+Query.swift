
//
//  MDItem+Query.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//

#if os(macOS)
import CoreServices
import Foundation

// 所有支持的 MDItem 字段
extension MDItem: NSMetadataOperationProtocol {
    public func value<T>(forMetadataItem key: String) -> T? {
        MDItemCopyAttribute(self, key as CFString) as? T
    }
}
#endif
