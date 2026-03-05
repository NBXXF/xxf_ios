//
//  RestApiService+Cache.swift
//  xxf_ios
//
//  RestApiService 缓存配置扩展
//
//  功能说明:
//  为 RestApiService 提供缓存相关的默认实现和缓存 Key 生成逻辑。
//
//  默认配置:
//  ┌───────────────────┬────────────────────────────────────────────┐
//  │ 配置项             │ 默认值                                      │
//  ├───────────────────┼────────────────────────────────────────────┤
//  │ cacheInterceptor  │ DefaultCacheInterceptor (200 + JSON)       │
//  │ httpCache         │ HttpCache.shared (全局共享实例)             │
//  │ cachePolicy       │ .onlyRemote (不使用缓存)                    │
//  └───────────────────┴────────────────────────────────────────────┘
//
//  Created by xxf on 2025/3/4.
//

import Foundation
import Moya
import XXFJson
import XXFSpeed

// MARK: - 缓存配置默认实现

public extension RestApiService {
    /// 缓存拦截器，默认使用 DefaultCacheInterceptor
    ///
    /// 仅缓存 HTTP 200 且 Content-Type 为 JSON 的响应。
    /// 业务方可重写此属性以自定义缓存条件。
    static var cacheInterceptor: any CacheInterceptor { DefaultCacheInterceptor() }

    /// HTTP 缓存实例，默认使用全局共享实例
    ///
    /// 业务方可重写此属性以使用独立的缓存实例，实现缓存隔离。
    ///
    /// ## 使用示例
    /// ```swift
    /// enum MyApiService: RestApiService {
    ///     // 使用独立的缓存实例
    ///     static var httpCache: HttpCache {
    ///         MyBusinessCache.shared  // 自定义缓存单例
    ///     }
    /// }
    /// ```
    static var httpCache: HttpCache { .shared }

    /// 缓存策略，默认不使用缓存
    var cachePolicy: CacheType { .onlyRemote }

    /// 获取最终的缓存 key
    /// 如果 cachePolicy 中指定了自定义 key 则使用，否则自动生成
    var cacheKey: String {
        cachePolicy.customKey ?? generateCacheKey()
    }

    /// 生成缓存 key
    /// 基于 baseURL + path + method + task 参数生成唯一标识
    func generateCacheKey() -> String {
        var components: [String] = [
            baseURL.absoluteString,
            path,
            method.rawValue,
        ]

        // 添加 task 参数
        switch task {
        case .requestPlain:
            break
        case let .requestData(data):
            components.append(data.base64EncodedString())
        case let .requestJSONEncodable(encodable):
            if let data = try? JSONEncoder().encode(AnyEncodable(encodable)) {
                components.append(data.base64EncodedString())
            }
        case let .requestCustomJSONEncodable(encodable, encoder):
            if let data = try? encoder.encode(AnyEncodable(encodable)) {
                components.append(data.base64EncodedString())
            }
        case let .requestParameters(parameters, _):
            components.append(sortedParametersString(parameters))
        case let .requestCompositeData(bodyData, urlParameters):
            components.append(bodyData.base64EncodedString())
            components.append(sortedParametersString(urlParameters))
        case let .requestCompositeParameters(bodyParameters, _, urlParameters):
            components.append(sortedParametersString(bodyParameters))
            components.append(sortedParametersString(urlParameters))
        case let .uploadFile(url):
            components.append(url.absoluteString)
        case let .uploadMultipart(multipartData):
            for part in multipartData {
                components.append(part.name)
                components.append(part.fileName ?? "")
            }
        case let .uploadCompositeMultipart(multipartData, urlParameters):
            for part in multipartData {
                components.append(part.name)
            }
            components.append(sortedParametersString(urlParameters))
        case let .downloadDestination(destination):
            let url = destination(URL(fileURLWithPath: ""), .init()).destinationURL
            components.append(url.absoluteString)
        case let .downloadParameters(parameters, _, destination):
            components.append(sortedParametersString(parameters))
            let url = destination(URL(fileURLWithPath: ""), .init()).destinationURL
            components.append(url.absoluteString)
        @unknown default:
            break
        }

        let combined = components.joined(separator: "|")
        return combined.toXXH3String()
    }
}

// MARK: - Private Helpers

private extension RestApiService {
    /// 参数直接 hash（避免 Data -> String 转换）
    func sortedParametersString(_ parameters: [String: Any]) -> String {
        guard let data = try? JSONSerialization.data(withJSONObject: parameters, options: .sortedKeys) else {
            return ""
        }
        return String(ThreadLocalXXH3.hash(data), radix: 16)
    }
}
