//
//  WebRequestEvent.swift
//  xxf_ios
//  native->h5 event body
//  Created by xxf on 5/13.
//

public struct WebEventRequest<T: Codable>: Codable {
    public let event: String
    public let data: T
}
