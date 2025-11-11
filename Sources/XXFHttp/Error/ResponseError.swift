//
//  ResponseError.swift
//  xxf_ios
//  网络异常
//  Created by xxf on /6/10.
//

import Foundation
import XXFFoundation

public class ResponseError: AppError, @unchecked Sendable {
    public init(statusCode: Int, message: String) {
        super.init(message, code: statusCode)
    }
}
