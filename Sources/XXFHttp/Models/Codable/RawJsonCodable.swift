//
//  RawJsonCodable.swift
//  xxf_ios
//  解析原始json
//  Created by xxf on 7/10.
//

public struct RawJsonCodable: Codable, Equatable, Hashable, CustomStringConvertible {
    public let rawJson: String

    public init(rawJson: String) {
        self.rawJson = rawJson
    }

    // 方便从 Data 创建
    public init(data: Data) throws {
        guard let str = String(data: data, encoding: .utf8) else {
            throw NSError(domain: "RawJsonWrapper", code: -1, userInfo: [NSLocalizedDescriptionKey: "Data to String failed"])
        }
        rawJson = str
    }

    // 方便从任意 Codable 对象转 JSON 字符串
    public init<T: Codable>(codableValue: T) throws {
        let data = try JSONEncoder().encode(codableValue)
        try self.init(data: data)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        // 支持 null 解码为 ""
        rawJson = (try? container.decode(String.self)) ?? ""
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
