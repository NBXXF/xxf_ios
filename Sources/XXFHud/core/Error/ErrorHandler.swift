//
//  ErrorHandler.swift
//  xxf_ios
//
//  Created by trl on 2025/5/27.
//

public protocol ErrorHandler {
    func handle(error: Error, toastPosition: Int)
}
