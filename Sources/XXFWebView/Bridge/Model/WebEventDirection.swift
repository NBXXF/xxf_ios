//
//  WebEventDirection.swift
//  xxf_ios
//
//  Created by xxf on 5/13.
//
import XXFJson

public enum WebEventDirection: String, Codable, Sendable {
    /// native 向web 发送消息或者请求资源
    case nativeToWeb = "ntw:"
    /// web 向native 发送消息或者请求资源
    case webToNative = "wtn:"
    // 未知值兜底，不会解析失败,真实值为""
    case unknown = ""
}

/// 自定义枚举默认值
public enum WebEventDirectionDefaultProvider: CodingDefaultValueProvider {
    public static let defaultValue: WebEventDirection = .unknown
}

public extension WebEventDirection {
    func makeEvent(_ event: String) -> String {
        if event.hasDirectionPrefix {
            return event
        }
        switch self {
        case .nativeToWeb, .webToNative:
            return rawValue + event
        case .unknown:
            return event
        }
    }
}

private extension String {
    var hasDirectionPrefix: Bool {
        hasPrefix(WebEventDirection.nativeToWeb.rawValue) || hasPrefix(WebEventDirection.webToNative.rawValue)
    }
}
