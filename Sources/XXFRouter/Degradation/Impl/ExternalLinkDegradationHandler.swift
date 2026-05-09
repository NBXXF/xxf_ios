//
//  ExternalLinkDegradationHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/9.
//

import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// HTTP/HTTPS 外部链接降级处理器
public final class ExternalLinkDegradationHandler: DegradationHandler, @unchecked Sendable {
    public let name = "ExternalLinkDegradationHandler"
    public let priority: Int
    public let strategy: DegradationStrategy = .openExternal

    /// 创建外部链接降级处理器
    /// - Parameter priority: 优先级
    public init(priority: Int = 100) {
        self.priority = priority
    }

    public func canHandle(context: RouteContext) -> Bool {
        let url = context.url.lowercased()
        return url.hasPrefix("http://") || url.hasPrefix("https://")
    }

    public func handle(context: RouteContext) -> DegradationResult {
        #if canImport(UIKit)
        if let url = URL(string: context.url) {
            Task { @MainActor in
                await UIApplication.shared.open(url)
            }
            return .handled
        }
        #elseif canImport(AppKit)
        if let url = URL(string: context.url) {
            NSWorkspace.shared.open(url)
            return .handled
        }
        #endif
        return .failure(error: .invalidURL(url: context.url))
    }
}
