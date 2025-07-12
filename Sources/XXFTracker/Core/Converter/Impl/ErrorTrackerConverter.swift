//
//  ErrorTrackerConverter.swift
//  xxf_ios
//
//  Created by xxf on 7/12.
//
import Foundation

public class ErrorTrackerConverter: TrackerConverter {
    public static let KEY_ERROR_NAME = "error_name"

    public func convert(data: Any, extra: inout [AnyHashable: Any], chanel _: ChanelTracker) -> String? {
        // 判断 data 是否为 Error 类型（对应 Kotlin Throwable）
        if let error = data as? Error {
            let result = error.localizedDescription

//                // 判断是否为自定义 ResponseException 类型
//                if let responseException = error as? ResponseException {
//                    // 假设 Json.toJson 的功能用 JSONEncoder 或类似实现
//                    let bodyJson = try Json.toJson(responseException.body)
//                    result += " for body: \(bodyJson)"
//                }

            extra[ErrorTrackerConverter.KEY_ERROR_NAME] = String(describing: type(of: error))
            return result
        }
        return nil
    }
}
