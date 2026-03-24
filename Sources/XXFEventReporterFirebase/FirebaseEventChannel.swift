//
//  FirebaseEventChannel.swift
//  xxf_ios
//  Firebase Analytics 事件上报渠道
//  Created by xxf on 2019/5/28.
//
#if os(iOS)
import FirebaseAnalytics
import Foundation
import XXFEventReporter

// MARK: - FirebaseEventChannel

/// 建议先初始化 Firebase FirebaseApp.configure()
/// Firebase Analytics 事件上报渠道
public final class FirebaseEventChannel: EventChannel {
    public let channelName: String = "FirebaseAnalytics"

    private let autoSanitize: Bool

    public init(autoSanitize: Bool = true) {
        self.autoSanitize = autoSanitize
    }

    public func onEventReported(event: String, parameters: [String: Any]) {
        let name = autoSanitize ? sanitize(event) : event
        let params = sanitizeParameters(parameters)
        Analytics.logEvent(name, parameters: params)
    }

    public func supports(event: String) -> Bool {
        let name = sanitize(event)
        return !name.isEmpty && name.count <= 40
    }

    private func sanitize(_ name: String) -> String {
        var result = name.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "_")
            .filter { $0.isLetter || $0.isNumber || $0 == "_" }

        if let first = result.first, !first.isLetter {
            result = "event_" + result
        }

        return result.count > 40 ? String(result.prefix(40)) : result
    }

    private func sanitizeParameters(_ parameters: [String: Any]) -> [String: Any] {
        parameters.reduce(into: [:]) { result, pair in
            let key = sanitize(pair.key)
            if let value = convertValue(pair.value) {
                result[key] = value
            }
        }
    }

    private func convertValue(_ value: Any) -> Any? {
        switch value {
        case is String, is NSNumber, is Int, is Double, is Float, is Bool:
            return value
        case let convertible as CustomStringConvertible:
            return convertible.description
        default:
            return nil
        }
    }
}

// MARK: - 便捷方法

public extension FirebaseEventChannel {
    /// 建议先初始化 Firebase FirebaseApp.configure()
    static func `default`() -> FirebaseEventChannel {
        FirebaseEventChannel()
    }
}
#endif
