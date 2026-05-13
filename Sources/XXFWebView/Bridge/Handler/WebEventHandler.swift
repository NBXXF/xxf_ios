//
//  WebEventHandler.swift
//  xxf_ios
//
//  Created by xxf on 5/13.
//

import XXFJson

public protocol WebEventHandler: AnyObject {
    var eventName: String { get }
    func handle(event: WebEventRequest<AnyCodable>, completion: @escaping (WebEventResponse<AnyCodable>) -> Void)
}
