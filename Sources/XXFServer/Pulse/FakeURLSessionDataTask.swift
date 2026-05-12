//
//  FakeURLSessionDataTask.swift
//  xxf_ios
//
//  Created by xxf on 7/16.
//

import Foundation
import XXFFoundation

/// 模拟 URLSessionDataTask，供 Pulse 记录使用
final class FakeURLSessionDataTask: URLSessionDataTask, @unchecked Sendable {
    private let _originalRequest: URLRequest
    var _response: URLResponse?

    init(request: URLRequest) {
        _originalRequest = request
    }

    override var originalRequest: URLRequest? {
        return _originalRequest
    }

    override var currentRequest: URLRequest? {
        return _originalRequest
    }

    override var response: URLResponse? {
        return _response
    }

    override var taskDescription: String? {
        get {
            if _originalRequest.url?.host == nil {
                return getFullURL(from: _originalRequest)
            } else {
                return _originalRequest.url?.absoluteString ?? ""
            }
        }
        set {}
    }

    override var taskIdentifier: Int {
        return ObjectIdentifier(self).hashValue
    }

    override var state: URLSessionTask.State {
        return .completed
    }

    override func resume() {
        // no-op
    }

    private func getFullURL(from request: URLRequest) -> String {
        let scheme = request.value(forHTTPHeaderField: "X-Forwarded-Proto") ?? "http"
        let host = request.value(forHTTPHeaderField: "Host") ?? LoopbackAddress.domain
        return "\(scheme)://\(host)\(request.url?.absoluteString ?? "")"
    }
}
