//
//  BridgePayloadCodec.swift
//  xxf_ios
//

import Foundation

fileprivate enum BridgePayloadError: Swift.Error {
    case invalidJSONValue
}

func makeBridgeJSONData(from value: Any?) throws -> Data {
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

func makeBridgeJSONObject<T: Encodable>(from value: T) throws -> Any {
    let data = try JSONEncoder().encode(value)
    return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
}

func decodeBridgeJSON<T: Decodable>(
    _ value: Any?,
    as type: T.Type
) throws -> T {
    let data = try makeBridgeJSONData(from: value)
    return try Foundation.JSONDecoder().decode(T.self, from: data)
}
