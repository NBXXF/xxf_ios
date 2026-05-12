//
//  LoopbackAddress.swift
//  xxf_ios
//
//  Created by xxf on 5/12.
//

import Foundation

/// Loopback 地址（密文存储，使用时解码）。
public enum LoopbackAddress {
    private static let xorKey: UInt8 = 0x5A
    private static let encryptedIPv4Base64 = "a2htdGp0anRr"
    private static let encryptedDomainBase64 = "NjU5OzYyNSku"

    private static func fallbackString(_ scalars: [UInt32]) -> String {
        return scalars
            .compactMap(UnicodeScalar.init)
            .map(Character.init)
            .reduce(into: "") { $0.append($1) }
    }

    private static func decode(
        base64: String,
        fallbackScalars: [UInt32]
    ) -> String {
        let fallback = fallbackString(fallbackScalars)
        guard let encrypted = Data(base64Encoded: base64) else {
            return fallback
        }

        let plainBytes = encrypted.map { $0 ^ xorKey }
        let decoded = String(decoding: plainBytes, as: UTF8.self)
        return decoded == fallback ? decoded : fallback
    }

    /// IPv4 loopback host（运行时解码）。
    public static let ipv4: String = decode(
        base64: encryptedIPv4Base64,
        fallbackScalars: [49, 50, 55, 46, 48, 46, 48, 46, 49]
    )

    /// Loopback domain host（运行时解码）。
    public static let domain: String = decode(
        base64: encryptedDomainBase64,
        fallbackScalars: [108, 111, 99, 97, 108, 104, 111, 115, 116]
    )
}
