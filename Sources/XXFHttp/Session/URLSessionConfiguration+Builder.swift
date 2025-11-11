//
//  URLSessionConfiguration+Builder.swift
//  xxf_ios
//  支持建造者创建
//  Created by xxf on 9/2.
//

import Foundation

public extension URLSessionConfiguration {
    // 支持创建一个新的 不影响原来的
    func newBuilder() -> URLSessionConfigurationBuilder {
        // 直接copy一份 不要修改原来的那份
        return URLSessionConfigurationBuilder(configuration: copy() as! URLSessionConfiguration)
    }

    @available(macOS 10.9, *)
    class URLSessionConfigurationBuilder {
        private var configuration: URLSessionConfiguration

        // MARK: - 初始化

        fileprivate init(configuration: URLSessionConfiguration) {
            self.configuration = configuration
        }

        // MARK: - 链式方法

        @discardableResult
        public func timeoutIntervalForRequest(_ interval: TimeInterval) -> URLSessionConfigurationBuilder {
            configuration.timeoutIntervalForRequest = interval
            return self
        }

        @discardableResult
        public func timeoutIntervalForResource(_ interval: TimeInterval) -> URLSessionConfigurationBuilder {
            configuration.timeoutIntervalForResource = interval
            return self
        }

        @discardableResult
        public func allowsCellularAccess(_ allow: Bool) -> URLSessionConfigurationBuilder {
            configuration.allowsCellularAccess = allow
            return self
        }

        @available(macOS 10.15, *)
        @discardableResult
        public func allowsExpensiveNetworkAccess(_ allow: Bool) -> URLSessionConfigurationBuilder {
            configuration.allowsExpensiveNetworkAccess = allow
            return self
        }

        @available(macOS 10.15, *)
        @discardableResult
        public func allowsConstrainedNetworkAccess(_ allow: Bool) -> URLSessionConfigurationBuilder {
            configuration.allowsConstrainedNetworkAccess = allow
            return self
        }

        @discardableResult
        public func httpAdditionalHeaders(_ headers: [AnyHashable: Any]) -> URLSessionConfigurationBuilder {
            configuration.httpAdditionalHeaders = headers
            return self
        }

        @discardableResult
        public func httpShouldSetCookies(_ shouldSet: Bool) -> URLSessionConfigurationBuilder {
            configuration.httpShouldSetCookies = shouldSet
            return self
        }

        @discardableResult
        public func httpCookieAcceptPolicy(_ policy: HTTPCookie.AcceptPolicy) -> URLSessionConfigurationBuilder {
            configuration.httpCookieAcceptPolicy = policy
            return self
        }

        @discardableResult
        public func httpMaximumConnectionsPerHost(_ max: Int) -> URLSessionConfigurationBuilder {
            configuration.httpMaximumConnectionsPerHost = max
            return self
        }

        @discardableResult
        public func urlCache(_ cache: URLCache?) -> URLSessionConfigurationBuilder {
            configuration.urlCache = cache
            return self
        }

        @discardableResult
        public func urlCredentialStorage(_ storage: URLCredentialStorage?) -> URLSessionConfigurationBuilder {
            configuration.urlCredentialStorage = storage
            return self
        }

        @discardableResult
        public func protocolClasses(_ classes: [AnyClass]?) -> URLSessionConfigurationBuilder {
            configuration.protocolClasses = classes
            return self
        }

        // MARK: - 构建最终配置

        public func build() -> URLSessionConfiguration {
            return configuration.copy() as! URLSessionConfiguration
        }
    }
}
