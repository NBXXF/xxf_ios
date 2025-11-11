//
//  RawJsonCodable.swift
//  xxf_ios
//  解析原始json
//  Created by xxf on 7/10.
//
import Foundation

public struct RawJsonCodable: Codable, Equatable, Hashable, CustomStringConvertible {
    public let rawJson: String

    public init(rawJson: String) {
        self.rawJson = rawJson
    }

    // 方便从 Data 创建
    public init(data: Data) throws {
        guard let str = String(data: data, encoding: .utf8) else {
            throw NSError(
                domain: "RawJsonWrapper",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Data to String failed"]
            )
        }
        rawJson = str
    }

    // 方便从任意 Codable 对象转 JSON 字符串
    public init(codableValue: some Codable) throws {
        let data = try JSONEncoder().encode(codableValue)
        try self.init(data: data)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        // 先尝试解成 String 类型
        if let str = try? container.decode(String.self) {
            rawJson = str
            return
        }

        // 如果不是字符串，尝试解成字典或数组，然后转成 JSON 字符串
        if let dict = try? container.decode([String: AnyCodable].self) {
            let data = try JSONSerialization.data(withJSONObject: dict.mapValues { $0.value }, options: [.sortedKeys])
            rawJson = String(data: data, encoding: .utf8) ?? "{}"
            return
        }

        if let array = try? container.decode([AnyCodable].self) {
            let data = try JSONSerialization.data(withJSONObject: array.map(\.value), options: [.sortedKeys])
            rawJson = String(data: data, encoding: .utf8) ?? "[]"
            return
        }

        // 如果是null或者其他类型，赋空字符串
        rawJson = ""
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawJson)
    }

    public var description: String {
        return rawJson
    }

    // Equatable & Hashable 编译器自动合成即可
}
