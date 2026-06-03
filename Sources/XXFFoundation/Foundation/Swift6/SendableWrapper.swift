//
//  SendableWrapper.swift
//  xxf_ios
//  临时解决sendable 数据传输问题
//  Created by xxf on 6/3.
//

public struct SendableWrapper: @unchecked Sendable {
    public let value: Any?

    public init(_ value: Any?) {
        self.value = value
    }
}
