//
//  WebEventResponse.swift
//  xxf_ios
//  h5->native event body
//  Created by xxf on 5/13.
//

public struct WebEventResponse<T: Codable>: Codable {
    public let code: Int
    public let message: String?
    public let data: T
}
