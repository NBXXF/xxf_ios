//
//  LogEventType.swift
//  xxf_ios
//
//  Created by xxf on 6/30.
//

public enum LogEventType<Element> {
    case subscribed
    case next(Element)
    case error(Error)
    case completed
    case disposed

    /// 转换成不带泛型的标签
    public var tag: LogEventTypeTag {
        switch self {
            case .subscribed: return .subscribed
            case .next: return .next
            case .error: return .error
            case .completed: return .completed
            case .disposed: return .disposed
        }
    }
}

// 不带泛型的标签
public enum LogEventTypeTag: Hashable, CaseIterable {
    case subscribed, next, error, completed, disposed
}
