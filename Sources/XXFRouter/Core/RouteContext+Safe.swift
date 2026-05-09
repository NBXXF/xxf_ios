//
//  RouteContext+Safe.swift
//  xxf_ios
//
//  Created by xxf on 5/9.
//

public extension RouteContext {
    /// 读取必填 path 参数并保证为非空字符串（会自动 trim）。
    /// - Parameter name: path 参数名（不含 `path.` 前缀）
    /// - Returns: 去除首尾空白后的字符串
    /// - Throws: 参数缺失/为空时抛 `missingRequiredParameter`，类型不匹配抛 `invalidParameterType`
    func requiredPathNonEmptyString(_ name: String) throws -> String {
        guard let raw = pathParameters[name] else {
            throw RouteError.missingRequiredParameter(url: url, name: "path.\(name)")
        }
        guard let value = raw as? String else {
            throw RouteError.invalidParameterType(
                url: url,
                name: "path.\(name)",
                expected: "String",
                actual: String(describing: type(of: raw))
            )
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RouteError.missingRequiredParameter(url: url, name: "path.\(name)")
        }
        return trimmed
    }

    /// 读取必填 query 参数并保证为非空字符串（会自动 trim）。
    /// - Parameter name: query 参数名（不含 `query.` 前缀）
    /// - Returns: 去除首尾空白后的字符串
    /// - Throws: 参数缺失或为空时抛 `missingRequiredParameter`
    func requiredQueryNonEmptyString(_ name: String) throws -> String {
        guard let value = queryParameters[name] else {
            throw RouteError.missingRequiredParameter(url: url, name: "query.\(name)")
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RouteError.missingRequiredParameter(url: url, name: "query.\(name)")
        }
        return trimmed
    }

    /// 读取必填 extra 参数并校验类型。
    /// - Parameters:
    ///   - name: extra 参数名（不含 `extra.` 前缀）
    ///   - expectedType: 期望类型
    /// - Returns: 转型后的参数值
    /// - Throws: 参数缺失抛 `missingRequiredParameter`，类型不匹配抛 `invalidParameterType`
    func requiredExtraParameter<T>(_ name: String, as expectedType: T.Type) throws -> T {
        guard let raw = extraParameters[name] else {
            throw RouteError.missingRequiredParameter(url: url, name: "extra.\(name)")
        }
        guard let value = raw as? T else {
            throw RouteError.invalidParameterType(
                url: url,
                name: "extra.\(name)",
                expected: String(describing: expectedType),
                actual: String(describing: type(of: raw))
            )
        }
        return value
    }

    /// 读取可选 extra 参数并校验类型。
    /// - Parameters:
    ///   - name: extra 参数名（不含 `extra.` 前缀）
    ///   - expectedType: 期望类型
    /// - Returns: 参数不存在时返回 `nil`；存在且类型正确时返回值
    /// - Throws: 参数存在但类型不匹配时抛 `invalidParameterType`
    func optionalExtraParameter<T>(_ name: String, as expectedType: T.Type) throws -> T? {
        guard let raw = extraParameters[name] else { return nil }
        guard let value = raw as? T else {
            throw RouteError.invalidParameterType(
                url: url,
                name: "extra.\(name)",
                expected: String(describing: expectedType),
                actual: String(describing: type(of: raw))
            )
        }
        return value
    }

    /// 读取必填 extra 字符串参数并保证非空（会自动 trim）。
    /// - Parameter name: extra 参数名（不含 `extra.` 前缀）
    /// - Returns: 去除首尾空白后的字符串
    /// - Throws: 参数缺失/为空时抛 `missingRequiredParameter`，类型不匹配抛 `invalidParameterType`
    func requiredExtraNonEmptyString(_ name: String) throws -> String {
        let value: String = try requiredExtraParameter(name, as: String.self)
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw RouteError.missingRequiredParameter(url: url, name: "extra.\(name)")
        }
        return trimmed
    }

    /// 读取可选 extra 字符串参数并做空白归一化（trim 后为空视为 nil）。
    /// - Parameter name: extra 参数名（不含 `extra.` 前缀）
    /// - Returns: 参数不存在或仅空白时返回 `nil`；否则返回去除首尾空白后的字符串
    /// - Throws: 参数存在但类型不匹配时抛 `invalidParameterType`
    func optionalExtraNonEmptyString(_ name: String) throws -> String? {
        guard let value: String = try optionalExtraParameter(name, as: String.self) else {
            return nil
        }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
