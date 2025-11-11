//
//  Config.swift
//  xxf_ios
//
//  Created by xxf on 5/23.
//

public struct Config: Sendable {
    public var logInterceptor: LogInterceptor
    public init(logInterceptor: @escaping LogInterceptor) {
        self.logInterceptor = logInterceptor
    }
}
