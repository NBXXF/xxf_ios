//
//  NamedWebEventHandler.swift
//  xxf_ios
//  支持key value 形式注册
//  Created by xxf on 5/13.
//

import Foundation
import XXFJson

open class NamedWebEventHandler: NSObject, WebEventHandler {
    public typealias Handler = (
        WebEventRequest<AnyCodable>,
        @escaping (WebEventResponse<AnyCodable>) -> Void
    ) -> Void

    public let eventName: String
    private let handler: Handler

    public init(eventName: String, handler: @escaping Handler) {
        self.eventName = eventName
        self.handler = handler
        super.init()
    }

    open func handle(
        event: WebEventRequest<AnyCodable>,
        completion: @escaping (WebEventResponse<AnyCodable>) -> Void
    ) {
        handler(event, completion)
    }
}
