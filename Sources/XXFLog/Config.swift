//
//  Config.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/23.
//

public struct Config: Sendable {
    var logInterceptor: LogInterceptor
    init(logInterceptor: @escaping LogInterceptor) {
        self.logInterceptor = logInterceptor
    }
}
