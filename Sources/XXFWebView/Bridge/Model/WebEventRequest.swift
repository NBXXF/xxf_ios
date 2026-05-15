//
//  WebRequestEvent.swift
//  xxf_ios
//  native->h5 event body
//  Created by xxf on 5/13.
//

public struct WebEventRequest<T: Codable>: Codable {
    public let event: String
    public let data: T?

    public init(rawEvent: String, data: T? = nil) {
        self.event = rawEvent
        self.data = data
    }

    public init(event: String, direction: WebEventDirection, data: T? = nil) {
        let rawEvent = direction.makeEvent(event)
        self.event = rawEvent
        self.data = data
    }
}
