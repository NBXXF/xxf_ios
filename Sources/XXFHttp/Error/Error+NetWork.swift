//
//  Error+NetWork.swift
//  xxf_ios
//
//  Created by xxf on 6/23.
//
import Alamofire
import Foundation
import Moya

public extension Error {
    /// 判断是否为无法连接服务器 / 网络错误
    var isNetworkConnectionError: Bool {
        // 递归处理
        func check(_ error: Error) -> Bool {
            // MoyaError
            if let moyaError = error as? MoyaError {
                switch moyaError {
                case let .underlying(underlyingError, _):
                    return check(underlyingError)
                default:
                    return false
                }
            }

            // AFError
            if let afError = error as? AFError {
                switch afError {
                case let .sessionTaskFailed(underlyingError):
                    return check(underlyingError)
                default:
                    return false
                }
            }

            // URLError
            if let urlError = error as? URLError {
                let codes: [URLError.Code] = [.cannotConnectToHost, .timedOut, .notConnectedToInternet]
                return codes.contains(urlError.code)
            }

            // NSError 兼容（有些底层可能是 NSError）
            if let nsError = error as NSError? {
                if nsError.domain == NSURLErrorDomain {
                    let codes: [Int] = [
                        NSURLErrorCannotConnectToHost,
                        NSURLErrorTimedOut,
                        NSURLErrorNotConnectedToInternet,
                    ]
                    return codes.contains(nsError.code)
                }
            }

            return false
        }

        return check(self)
    }

    /// 判断这个错误是否属于网络层错误（设备无网、连接中断、超时等）
    var isNetworkError: Bool {
        // 1. Alamofire 封装的 AFError
        if let afError = self as? AFError,
           let urlError = afError.underlyingError as? URLError
        {
            return urlError.isURLErrorNetwork
        }

        // 2. 直接 URLSession / URLError
        if let urlError = self as? URLError {
            return urlError.isURLErrorNetwork
        }

        // 3. 其他情况认为不是网络错误
        return false
    }
}

private extension URLError {
    /// 判断是否是网络错误
    var isURLErrorNetwork: Bool {
        switch code {
        case .notConnectedToInternet, // -1009 设备无网
             .networkConnectionLost, // -1005 网络中断
             .timedOut, // -1001 请求超时
             .cannotFindHost, // -1003 无法找到服务器
             .cannotConnectToHost, // -1004 服务器拒绝连接
             .dnsLookupFailed: // -1006 DNS 解析失败
            return true
        default:
            return false
        }
    }
}
