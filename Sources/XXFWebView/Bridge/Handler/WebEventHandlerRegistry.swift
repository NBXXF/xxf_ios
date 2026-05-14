//
//  WebEventHandlerRegistry.swift
//  xxf_ios
//
//  Created by xxf on 2026/5/13.
//

import Foundation
import XXFJson

open class WebEventHandlerRegistry: NSObject {
    private var handlers: [String: WebEventHandler] = [:]

    public override init() {
        super.init()
    }

    open func register(_ handler: WebEventHandler) {
        handlers[handler.eventName] = handler
    }

    open func unregister(eventName: String) {
        handlers.removeValue(forKey: eventName)
    }

    open func removeAll() {
        handlers.removeAll()
    }

    open func dispatch(
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
