//
//  Base64DataAdapter.swift
//  xxf_ios
//
//  Base64 字符串 ↔ Data 适配器
//
//  Created by xxf
//

import Foundation

/// Base64 Data 适配器
///
/// 后端 Data 字段常以 base64 字符串传输，本适配器双向转换。
///
/// ## 使用
///
/// ```swift
/// struct Attachment: Codable {
///     @CodingBy<Base64DataAdapter> var payload: Data
/// }
/// ```
///
/// ## 对比
///
/// `JSONDecoder` 默认 `dataDecodingStrategy` 是 `.base64`，所以**如果你用的是原生 JSONDecoder
/// 且没改过策略**，普通 `var payload: Data` 字段已能正常工作。
///
/// 使用本适配器的场景：
/// - 自定义了 decoder 策略（如 `.deferredToData`），需要强制 base64
/// - 想要更宽松解析：允许 URL-safe base64、带 padding / 不带 padding
/// - 显式声明字段编码格式，和使用方统一约定
public struct Base64DataAdapter: CodingAdapter {

    public typealias Value = Data

    public static func decode(from decoder: Decoder) throws -> Data {
        let c = try decoder.singleValueContainer()

        // 1. 字符串形式的 base64
        if let s = try? c.decode(String.self) {
            // 尝试标准 base64
            if let d = Data(base64Encoded: s) { return d }
            // 尝试放宽选项：忽略换行 + 空白
            if let d = Data(base64Encoded: s, options: [.ignoreUnknownCharacters]) { return d }
            // 尝试 URL-safe base64（把 '-' '_' 替换回 '+' '/'，再补 padding）
            if let d = _decodeBase64URL(s) { return d }
            throw DecodingError.dataCorruptedError(in: c,
                debugDescription: "Base64DataAdapter failed to decode string as base64: \(s)")
        }

        // 2. 原生 Data（如果 decoder 已配置好策略）
        if let d = try? c.decode(Data.self) { return d }

        throw DecodingError.typeMismatch(Data.self, .init(
            codingPath: decoder.codingPath,
            debugDescription: "Base64DataAdapter failed to decode JSON value as Data"
        ))
    }

    public static func encode(_ value: Data, to encoder: Encoder) throws {
        var c = encoder.singleValueContainer()
        try c.encode(value.base64EncodedString())
    }

    // MARK: - URL-safe base64

    private static func _decodeBase64URL(_ s: String) -> Data? {
        var str = s
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        // 补 padding 到 4 的倍数
        let padding = (4 - str.count % 4) % 4
        if padding > 0 { str += String(repeating: "=", count: padding) }
        return Data(base64Encoded: str, options: [.ignoreUnknownCharacters])
    }
}
