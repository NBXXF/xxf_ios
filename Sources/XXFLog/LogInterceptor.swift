//
//  LogInterceptor.swift
//  xxf_ios
//
//  Created by xxf on 2025/5/23.
//

/// 返回 true 表示该级别的日志会被拦截（不打印）
public typealias LogInterceptor = @Sendable (_ level: LogLevel) -> Bool
