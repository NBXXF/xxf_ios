//
//  WebEventHandlerRegistry.swift
//  xxf_ios
//
//  Created by xxf on 2026/5/13.
//

import Foundation
import XXFJson

public final class WebEventHandlerRegistry {
    private var handlers: [String: WebEventHandler] = [:]

    public init() {}

    public func register(_ handler: WebEventHandler) {
        handlers[handler.eventName] = handler
    }

    public func unregister(eventName: String) {
        handlers.removeValue(forKey: eventName)
    }

    public func removeAll() {
        handlers.removeAll()
    }

    public func dispatch(
        event: WebEventRequest<AnyCodable>,
        completion: @escaping (WebEventResponse<AnyCodable>) -> Void
    ) {
        let eventName = event.event
        guard let handler = handlers[eventName] else {
            completion(
                WebEventResponse.webviewNotHandle(eventName: eventName)
            )
            return
        }

        handler.handle(event: event, completion: completion)
    }
}
