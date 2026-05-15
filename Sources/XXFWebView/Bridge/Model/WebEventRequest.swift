//
//  WebRequestEvent.swift
//  xxf_ios
//  native->h5 event body
//  Created by xxf on 5/13.
//

public struct WebEventRequest<T: Codable>: Codable {
    /// 为了兼容以前的,暂时不要声明direction字段,用url组合的方式
    public let event: String
    public let data: T?

    public init(name: String, direction: WebEventDirection, data: T? = nil) {
        let rawEvent = direction.makeEvent(name)
        self.event = rawEvent
        self.data = data
    }
}
