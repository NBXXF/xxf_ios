//
//  NSMetadataItem+Query.swift
//  xxf_ios
//
//  Created by xxf on 6/12.
//
import Foundation
#if os(macOS)
/// Spotlight 支持的字段
extension NSMetadataItem: NSMetadataOperationProtocol {
    public func value<T>(forMetadataItem key: String) -> T? {
        return value(forAttribute: key) as? T
    }
}
#endif
