//
//  WebEventHandlerRegistry.swift
//  xxf_ios
//
//  Created by xxf on 5/13.
//

import Foundation
import XXFJson

open class WebEventHandlerRegistry: NSObject {
    private var handlers: [String: WebEventHandler] = [:]

    open var registeredEventNames: [String] {
        handlers.keys.sorted()
    }

    override public init() {
        super.init()
    }

    open func register(_ handler: WebEventHandler) {
        handlers[handler.eventName] = handler
    }

    open func register(eventName: String, handler: @escaping NamedWebEventHandler.Handler) {
        self.register(NamedWebEventHandler(eventName: eventName, handler: handler))
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
