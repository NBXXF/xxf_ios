//
//  ActionTypeEvent.swift
//  xxf_ios
//
//  Created by xxf on 6/29.
//

public struct ActionTypeEvent<T> {
    public let action: String
    public let data: T?

    public init(action: String, data: T?) {
        self.action = action
        self.data = data
    }

    public static func create(action: String, data: T?) -> ActionTypeEvent<T> {
        return ActionTypeEvent(action: action, data: data)
    }
}
