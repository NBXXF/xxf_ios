//
//  Task+Builder.swift
//  xxf_ios
//
//  Created by xxf on 11/17.
//

import Alamofire
import Foundation
import Moya

public extension Moya.Task {
    /// 请求体类型枚举，用于互斥不同的 body 类型
    enum BodyType {
        /// json 字典
        case json(dict: [String: Any])
        /// json 模型
        case jsonEncodable(model: Encodable, encoder: JSONEncoder)
        /// 表单
        case urlEncoded(dict: [String: Any])
        /// 带文件的表单
        case multipart(parts: [Moya.MultipartFormData])
        /// 原始数据
        case raw(data: Data)
        /// 没有body
        case none
    }

    /// 用于构建 Moya.Task 对象的链式构建器
    ///
    /// 支持多种请求体类型：JSON、表单、Encodable 模型、原始 Data、Multipart。
    /// 支持 query 参数叠加。
    struct Builder {
        // MARK: - 内部存储

        /// 当前请求体类型
        private var bodyType: BodyType = .none

        /// URL query 参数
        private var urlParameters: [String: Any]?

        public init(urlParameters: [String: Any]? = nil) {
            self.urlParameters = urlParameters
        }

        // MARK: - 链式方法

        /// 设置 JSON body（Content-Type 默认 application/json）
        /// - Parameter parameters: 字典 body
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func jsonBody(_ parameters: [String: Any]) -> Self {
            self.bodyType = .json(dict: parameters)
            return self
        }

        /// 设置 Encodable 模型作为 JSON body,
        /// ⚠️无法识别自动设置content-type; 如果服务器不能自动判断,  需要业务复写header增加 ["Content-Type": "application/json"]
        /// - Parameters:
        ///   - model: Encodable 模型
        ///   - encoder: JSONEncoder，可自定义
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func jsonBody<T: Encodable>(_ model: T, encoder: JSONEncoder = JSONEncoder()) -> Self {
            self.bodyType = .jsonEncodable(model: model, encoder: encoder)
            return self
        }

        /// 设置表单 body（Content-Type 默认 application/x-www-form-urlencoded）
        /// - Parameter parameters: 字典 body
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func urlEncodedBody(_ parameters: [String: Any]) -> Self {
            self.bodyType = .urlEncoded(dict: parameters)
            return self
        }

        /// 添加 Multipart 文件上传数据（multipart/form-data）
        /// - Parameter parts: MultipartFormData 数组
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func multipartBody(_ parts: [Moya.MultipartFormData]) -> Self {
            self.bodyType = .multipart(parts: parts)
            return self
        }

        /// 设置原始 Data body
        /// - Parameter data: 请求体 Data
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func rawBody(_ data: Data) -> Self {
            self.bodyType = .raw(data: data)
            return self
        }

        /// 添加 URL query 参数，会和已有 query 合并，新值优先
        /// - Parameter parameters: query 字典
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func query(_ parameters: [String: Any]) -> Self {
            if self.urlParameters == nil {
                self.urlParameters = parameters
            } else {
                self.urlParameters = self.urlParameters!.merging(parameters) { _, new in new }
            }
            return self
        }

        /// 清空所有 body / query 数据
        /// - Returns: Self，可链式调用
        @discardableResult
        public mutating func clear() -> Self {
            self.bodyType = .none
            self.urlParameters = nil
            return self
        }

        // MARK: - 构建 Task

        /// 构建 Moya.Task 对象
        /// - Returns: Moya.Task，根据 Builder 内部存储自动生成对应 Task 类型
        public func build() -> Moya.Task {
            switch bodyType {
            case .json(let dict):
                if let query = urlParameters {
                    return .requestCompositeParameters(bodyParameters: dict, bodyEncoding: JSONEncoding.default, urlParameters: query)
                } else {
                    return .requestParameters(parameters: dict, encoding: JSONEncoding.default)
                }
            case .jsonEncodable(let model, let encoder):
                guard let data = try? encoder.encode(model) else { return .requestPlain }
                if let query = urlParameters {
                    return .requestCompositeData(bodyData: data, urlParameters: query)
                } else {
                    return .requestData(data)
                }
            case .urlEncoded(let dict):
                if let query = urlParameters {
                    return .requestCompositeParameters(bodyParameters: dict, bodyEncoding: URLEncoding.httpBody, urlParameters: query)
                } else {
                    return .requestParameters(parameters: dict, encoding: URLEncoding.httpBody)
                }
            case .multipart(let parts):
                if let query = urlParameters {
                    return .uploadCompositeMultipart(parts, urlParameters: query)
                } else {
                    return .uploadMultipart(parts)
                }
            case .raw(let data):
                if let query = urlParameters {
                    return .requestCompositeData(bodyData: data, urlParameters: query)
                } else {
                    return .requestData(data)
                }
            case .none:
                if let query = urlParameters {
                    return .requestParameters(parameters: query, encoding: URLEncoding.default)
                } else {
                    return .requestPlain
                }
            }
        }
    }
}
