//
//  Pasteboard.swift
//  xxf_ios
//
//  Created by xxf
//

// MARK: - Shared helpers

private func makeJSONOptions(pretty: Bool) -> JSONSerialization.WritingOptions {
    var options: JSONSerialization.WritingOptions = pretty ? [.prettyPrinted] : []
    if #available(iOS 11.0, macOS 10.13, *) { options.insert(.sortedKeys) }
    return options
}

private func makeEncoderFormatting(pretty: Bool) -> JSONEncoder.OutputFormatting {
    var formatting: JSONEncoder.OutputFormatting = []
    if pretty { formatting.insert(.prettyPrinted) }
    if #available(iOS 11.0, macOS 10.13, *) { formatting.insert(.sortedKeys) }
    return formatting
}

// MARK: - iOS / tvOS / watchOS

#if canImport(UIKit)
import UIKit

@MainActor
public extension UIPasteboard {
    // MARK: Set

    /// 复制 JSON（支持 Dictionary / Array）
    @discardableResult
    func setJSON(_ object: Any, pretty: Bool = true) -> Bool {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: makeJSONOptions(pretty: pretty)),
              let str = String(data: data, encoding: .utf8) else { return false }
        string = str.replacingOccurrences(of: "\\/", with: "/")
        return true
    }

    /// 复制 Codable 模型
    @discardableResult
    func setModel<T: Encodable>(_ model: T, pretty: Bool = true) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = makeEncoderFormatting(pretty: pretty)
        guard let data = try? encoder.encode(model),
              let str = String(data: data, encoding: .utf8) else { return false }
        string = str.replacingOccurrences(of: "\\/", with: "/")
        return true
    }

    /// 复制任意值（String → Codable模型 → JSON → CustomStringConvertible → fallback）
    @discardableResult
    func setAuto(_ value: Any) -> Bool {
        // 1. String 直接设置
        if let str = value as? String {
            string = str
            return true
        }

        // 2. Encodable 模型（优先尝试编码为 JSON）
        if let encodable = value as? Encodable {
            return setModel(encodable)
        }

        // 3. 标准 JSON 对象（Dictionary/Array）
        if JSONSerialization.isValidJSONObject(value) {
            return setJSON(value)
        }

        // 4. 兜底：使用 CustomStringConvertible 或描述字符串
        string = (value as? CustomStringConvertible)?.description ?? String(describing: value)
        return true
    }

    // MARK: Get

    /// 获取并解析 JSON 对象（Dictionary 或 Array）
    func getJSON() -> Any? {
        guard let str = string, let data = str.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }

    /// 获取并解析为 JSON 字典
    func getJSONDictionary() -> [String: Any]? { getJSON() as? [String: Any] }

    /// 获取并解析为 JSON 数组
    func getJSONArray() -> [Any]? { getJSON() as? [Any] }

    /// 获取并解码 Codable 模型
    func getModel<T: Decodable>(_ type: T.Type) -> T? {
        guard let str = string, let data = str.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }
}

// MARK: - macOS

#elseif canImport(AppKit)
import AppKit

@MainActor
public extension NSPasteboard {
    // MARK: Set

    /// 复制 JSON（支持 Dictionary / Array）
    @discardableResult
    func setJSON(_ object: Any, pretty: Bool = true) -> Bool {
        guard JSONSerialization.isValidJSONObject(object),
              let data = try? JSONSerialization.data(withJSONObject: object, options: makeJSONOptions(pretty: pretty)),
              let str = String(data: data, encoding: .utf8) else { return false }
        return writeString(str)
    }

    /// 复制 Codable 模型
    @discardableResult
    func setModel<T: Encodable>(_ model: T, pretty: Bool = true) -> Bool {
        let encoder = JSONEncoder()
        encoder.outputFormatting = makeEncoderFormatting(pretty: pretty)
        guard let data = try? encoder.encode(model),
              let str = String(data: data, encoding: .utf8) else { return false }
        return writeString(str)
    }

    /// 复制任意值（String → Codable模型 → JSON → CustomStringConvertible → fallback）
    @discardableResult
    func setAuto(_ value: Any) -> Bool {
        // 1. String 直接设置
        if let str = value as? String {
            return writeString(str)
        }

        // 2. Encodable 模型（优先尝试编码为 JSON）
        if let encodable = value as? Encodable {
            return setModel(encodable)
        }

        // 3. 标准 JSON 对象（Dictionary/Array）
        if JSONSerialization.isValidJSONObject(value) {
            return setJSON(value)
        }

        // 4. 兜底：使用 CustomStringConvertible 或描述字符串
        let str = (value as? CustomStringConvertible)?.description ?? String(describing: value)
        return writeString(str)
    }

    // MARK: Get

    /// 获取并解析 JSON 对象（Dictionary 或 Array）
    func getJSON() -> Any? {
        guard let str = string(forType: .string), let data = str.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data)
    }

    /// 获取并解析为 JSON 字典
    func getJSONDictionary() -> [String: Any]? { getJSON() as? [String: Any] }

    /// 获取并解析为 JSON 数组
    func getJSONArray() -> [Any]? { getJSON() as? [Any] }

    /// 获取并解码 Codable 模型
    func getModel<T: Decodable>(_ type: T.Type) -> T? {
        guard let str = string(forType: .string), let data = str.data(using: .utf8) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    // MARK: Private

    /// NSPasteboard 写入字符串：先清空再写入
    @discardableResult
    private func writeString(_ str: String) -> Bool {
        clearContents()
        return setString(str, forType: .string)
    }
}

#endif
