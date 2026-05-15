//
//  URL+Builder.swift
//  xxf_ios
//
//  Created by xxf on 7/15.
//

import Foundation

public extension URL {
    /// 获取 URL query 参数，返回 [key: value] 字典
    var queryParameters: [String: String] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let items = components.queryItems
        else {
            return [:]
        }

        var params: [String: String] = [:]
        for item in items {
            if let value = item.value {
                params[item.name] = value
            }
        }
        return params
    }

    /// 获取 URL query 参数，返回 [key: value] 字典
    func queryParameter(for key: String) -> String? {
        return URLComponents(url: self, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == key })?.value
    }

    /// 返回一个新的 URL，增加 query 参数，不修改原 URL
    /// - Parameters:
    ///   - parameters: 要追加的 query 参数
    ///   - replace: 是否覆盖同名参数。`true` 时先移除同名 key 再追加，默认 `false`
    /// - Returns: 新的 URL，如果无法解析则返回原 URL
    func appendingQueryParameters(parameters: [String: String], replace: Bool = false) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var queryItems = components.queryItems ?? []
        if replace {
            queryItems.removeAll { parameters.keys.contains($0.name) }
        }
        for (key, value) in parameters {
            queryItems.append(URLQueryItem(name: key, value: value))
        }
        components.queryItems = queryItems
        return components.url ?? self
    }

    /// 返回一个新的 URL，增加 query 参数，已有同名 key 不覆盖
    func appendingQueryParametersIfAbsent(parameters: [String: String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        var queryItems = components.queryItems ?? []
        var existingKeys = Set(queryItems.map { $0.name })

        for (key, value) in parameters {
            if !existingKeys.contains(key) {
                queryItems.append(URLQueryItem(name: key, value: value))
                existingKeys.insert(key)
            }
        }

        components.queryItems = queryItems
        return components.url ?? self
    }

    /// 返回移除指定 query 参数后的 URL
    /// - Parameter key: 要移除的参数名
    /// - Returns: 新的 URL，如果无法解析则返回原 URL
    func removingParameter(key: String) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            return self
        }
        components.queryItems = queryItems.filter { $0.name != key }
        return components.url ?? self
    }

    /// 支持一次移除多个参数
    /// - Parameter keys: 要移除的参数名数组
    /// - Returns: 新的 URL，如果无法解析则返回原 URL
    func removingParameters(keys: [String]) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems
        else {
            return self
        }
        components.queryItems = queryItems.filter { !keys.contains($0.name) }
        return components.url ?? self
    }

    /// 返回一个新的 URL，移除所有 query 参数 问号也不保留
    func removingAllParameters() -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        // 移除所有 query
        components.query = nil

        return components.url ?? self
    }
}
