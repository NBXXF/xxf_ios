//
//  Container.swift
//  xxf_ios
//
//  Created by xxf on 2026/3/23.
//

import Foundation

// MARK: - Multi-key Decoding

public extension KeyedDecodingContainer {

    /// Decode value by trying multiple keys in priority order
    /// - Parameters:
    ///   - type: Target decoding type
    ///   - firstKey: First priority key
    ///   - otherKeys: Fallback keys
    /// - Returns: Successfully decoded value
    /// - Throws: Decoding error if all keys fail or not found
    ///
    /// Usage: API compatibility for field name changes (e.g., "user_id"/"userId")
    ///
    /// Example:
    /// ```swift
    /// let userID = try container.decode(Int.self, forKey: "user_id", "userId", "id")
    /// ```
    func decode<T: Decodable>(_ type: T.Type, forKey firstKey: String, _ otherKeys: String...) throws -> T {
        return try decode(type, forKeys: [firstKey] + otherKeys)
    }

    /// Decode value by trying multiple keys in priority order
    /// - Parameters:
    ///   - type: Target decoding type
    ///   - keys: Candidate keys in priority order
    /// - Returns: Successfully decoded value
    /// - Throws: Decoding error if all keys fail or not found
    func decode<T: Decodable>(_ type: T.Type, forKeys keys: [String]) throws -> T {
        guard !keys.isEmpty else {
            throw DecodingError.keyNotFound(
                AnyKey(stringValue: "<empty-keys>"),
                .init(
                    codingPath: codingPath,
                    debugDescription: "\(type) decoding key list is empty, provide at least one candidate key"
                )
            )
        }

        // Build lookup table O(m), query O(1)
        let keyMap = allKeys.reduce(into: [:]) { $0[$1.stringValue] = $1 }

        for keyString in keys {
            guard let matchedKey = keyMap[keyString] else { continue }
            return try decode(type, forKey: matchedKey)
        }

        throw DecodingError.keyNotFound(
            AnyKey(stringValue: keys.first!),
            .init(codingPath: codingPath, debugDescription: "No valid key found in: \(keys), available: \(allKeys.map(\.stringValue))")
        )
    }

    // MARK: - Optional Decoding

    /// Decode optional value by trying multiple keys
    /// - Parameters:
    ///   - type: Target decoding type
    ///   - firstKey: First priority key
    ///   - otherKeys: Fallback keys
    /// - Returns: Decoded value or nil if no key exists
    /// - Throws: Decoding error if key exists but type mismatch
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKey firstKey: String, _ otherKeys: String...) throws -> T? {
        return try decodeIfPresent(type, forKeys: [firstKey] + otherKeys)
    }

    /// Decode optional value by trying multiple keys
    /// - Parameters:
    ///   - type: Target decoding type
    ///   - keys: Candidate keys in priority order
    /// - Returns: Decoded value or nil if no key exists
    /// - Throws: Decoding error if key exists but type mismatch
    func decodeIfPresent<T: Decodable>(_ type: T.Type, forKeys keys: [String]) throws -> T? {
        guard !keys.isEmpty else { return nil }

        let keyMap = allKeys.reduce(into: [:]) { $0[$1.stringValue] = $1 }

        for keyString in keys {
            guard let matchedKey = keyMap[keyString] else { continue }
            return try decodeIfPresent(type, forKey: matchedKey)
        }

        return nil
    }
}
