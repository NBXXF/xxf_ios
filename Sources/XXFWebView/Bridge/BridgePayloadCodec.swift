//
//  BridgePayloadCodec.swift
//  xxf_ios
//

import Foundation
import XXFJson

private enum BridgePayloadError: Swift.Error {
    case invalidJSONValue
}

enum BridgePayloadCodec {
    static func makeJSONData(from value: Any?) throws -> Data {
        guard let value else {
            throw BridgePayloadError.invalidJSONValue
        }

        if let data = value as? Data {
            return data
        }

        if let string = value as? String, let data = string.data(using: .utf8) {
            return data
        }

        guard JSONSerialization.isValidJSONObject(value) else {
            throw BridgePayloadError.invalidJSONValue
        }

        return try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
    }

    static func makeJSONObject<T: Encodable>(from value: T) throws -> Any {
        try JSON.toJsonTree(value)
    }

    static func decodeJSON<T: Decodable>(
        _ value: Any?,
        as type: T.Type
    ) throws -> T {
        let data = try makeJSONData(from: value)
        return try JSON.fromJson(data)
    }
}
