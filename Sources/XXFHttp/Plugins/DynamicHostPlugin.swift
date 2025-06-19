//
//  HostDynamicPlugin.swift
//  xxf_ios
//  动态切换baseUrl
//  Created by xxf on 6/19.
//
import Foundation

public final class DynamicHostPlugin: PluginType {
    let newHost: String
    let newPort: Int?
    let newScheme: String?

    public init(newHost: String, newPort: Int? = nil, newScheme: String? = nil) {
        self.newHost = newHost
        self.newPort = newPort
        self.newScheme = newScheme
    }

    public convenience init?(baseURLString: String) {
        guard
            let url = URL(string: baseURLString),
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = components.host,
            ["http", "https"].contains(components.scheme ?? "")
        else {
            return nil
        }

        self.init(
            newHost: host,
            newPort: components.port,
            newScheme: components.scheme
        )
    }

    public func prepare(_ request: URLRequest, target _: TargetType) -> URLRequest {
        guard
            let originalURL = request.url,
            var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: false)
        else {
            return request
        }

        components.host = newHost
        if let port = newPort { components.port = port }
        if let scheme = newScheme { components.scheme = scheme }

        var modifiedRequest = request
        if let newURL = components.url {
            modifiedRequest.url = newURL
        } else {
            #if DEBUG
                print("⚠️ HostReplacingPlugin: Failed to build new URL from components: \(components)")
            #endif
        }

        return modifiedRequest
    }
}
