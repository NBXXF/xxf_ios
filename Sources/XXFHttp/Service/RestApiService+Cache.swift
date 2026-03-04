//
//  RestApiService+Cache.swift
//  xxf_ios
//  RestApiService 缓存 Key 生成扩展
//  Created by xxf on 2025/3/4.
//

import Foundation
import Moya
import XXFJson
import XXFSpeed

// MARK: - 缓存 Key 生成

public extension RestApiService {
    /// 缓存拦截器，默认使用 DefaultCacheInterceptor
    static var cacheInterceptor: any CacheInterceptor { DefaultCacheInterceptor() }

    /// 缓存配置，默认不使用缓存
    var cacheConfig: CacheType { .onlyRemote }

    /// 获取最终的缓存 key
    /// 如果 cacheConfig 中指定了自定义 key 则使用，否则自动生成
    var cacheKey: String {
        cacheConfig.customKey ?? generateCacheKey()
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
