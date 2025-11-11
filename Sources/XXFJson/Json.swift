//
//  Json.swift
//  xxf_ios
//  高效,安全,复用,处理解析
//  Created by xxf on 6/29.
//

import Foundation
import XXFFoundation

/// 取一个别名,无论编译器怎么匹配都是这个类
public typealias JSON = Json

public enum Json {
    private static let decoderKey = "com.xxf.json.ThreadLocalDecoderWrapper"
    private static let encoderKey = "com.xxf.json.ThreadLocalEncoderWrapper"

    // MARK: - 全局默认配置，允许外部修改（带锁）

    private nonisolated(unsafe) static var _defaultDecoder: JSONDecoder = LoggingJSONDecoder()
    private nonisolated(unsafe) static var _defaultEncoder: JSONEncoder = .init()
    private static let lock = NSLock()

    // 配置版本号，用于检测缓存是否过期
    private nonisolated(unsafe) static var configVersion: Int = 0

    public static var defaultDecoder: JSONDecoder {
        get {
            synchronized(lock) {
                _defaultDecoder
            }
        }
        set {
            synchronized(lock) {
                _defaultDecoder = newValue
                configVersion += 1
            }
        }
    }

    public static var defaultEncoder: JSONEncoder {
        get { synchronized(lock) { _defaultEncoder } }
        set {
            synchronized(lock) {
                _defaultEncoder = newValue
                configVersion += 1
            }
        }
    }

    // MARK: - 复制全局配置（用于初始化线程局部实例）

    private static func makeDecoder() -> JSONDecoder {
        synchronized(lock) {
            let copy = LoggingJSONDecoder()
            copy.dateDecodingStrategy = _defaultDecoder.dateDecodingStrategy
            copy.keyDecodingStrategy = _defaultDecoder.keyDecodingStrategy
            copy.userInfo = _defaultDecoder.userInfo
            return copy
        }
    }

    private static func makeEncoder() -> JSONEncoder {
        synchronized(lock) {
            let copy = JSONEncoder()
            copy.dateEncodingStrategy = _defaultEncoder.dateEncodingStrategy
            copy.keyEncodingStrategy = _defaultEncoder.keyEncodingStrategy
            copy.outputFormatting = _defaultEncoder.outputFormatting
            copy.userInfo = _defaultEncoder.userInfo
            return copy
        }
    }

    // MARK: - 线程局部缓存包装类型，保存版本号和实例

    private struct ThreadLocalDecoderWrapper {
        let version: Int
        let decoder: JSONDecoder
    }

    private struct ThreadLocalEncoderWrapper {
        let version: Int
        let encoder: JSONEncoder
    }

    // MARK: - 线程局部 JSONDecoder

    private static var threadLocalDecoder: JSONDecoder {
        let threadDict = Thread.current.threadDictionary
        if
            let wrapper = threadDict[decoderKey] as? ThreadLocalDecoderWrapper,
            wrapper.version == configVersion
        {
            return wrapper.decoder
        } else {
            let decoder = makeDecoder()
            threadDict[decoderKey] = ThreadLocalDecoderWrapper(version: configVersion, decoder: decoder)
            return decoder
        }
    }

    // MARK: - 线程局部 JSONEncoder

    private static var threadLocalEncoder: JSONEncoder {
        let threadDict = Thread.current.threadDictionary
        if
            let wrapper = threadDict[encoderKey] as? ThreadLocalEncoderWrapper,
            wrapper.version == configVersion
        {
            return wrapper.encoder
        } else {
            let encoder = makeEncoder()
            threadDict[encoderKey] = ThreadLocalEncoderWrapper(version: configVersion, encoder: encoder)
            return encoder
        }
    }

    // MARK: - fromJson

    public static func fromJson<T: Decodable>(
        _ json: String,
        decoderBuilder: (JSONDecoder) -> JSONDecoder = { $0 }
    ) throws -> T {
        let data = Data(json.utf8)
        let decoder = decoderBuilder(threadLocalDecoder)
        return try decoder.decode(T.self, from: data)
    }

    public static func fromJson<T: Decodable>(
        _ data: Data,
        decoderBuilder: (JSONDecoder) -> JSONDecoder = { $0 }
    ) throws -> T {
        let decoder = decoderBuilder(threadLocalDecoder)
        return try decoder.decode(T.self, from: data)
    }

    public static func fromJson<T: Decodable>(
        _ jsonObject: Any,
        decoderBuilder: (JSONDecoder) -> JSONDecoder = { $0 }
    ) throws -> T {
        guard JSONSerialization.isValidJSONObject(jsonObject) else {
            throw JsonError.invalidJSONObject(originalObjectDescription: String(describing: jsonObject))
        }
        let data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
        return try fromJson(data, decoderBuilder: decoderBuilder)
    }

    // MARK: - toJson

    public static func toJson<T: Encodable>(
        _ obj: T,
        encoderBuilder: (JSONEncoder) -> JSONEncoder = { $0 }
    ) throws -> String {
        let encoder = encoderBuilder(threadLocalEncoder)
        let data = try encoder.encode(obj)
        guard let string = String(data: data, encoding: .utf8) else {
            throw JsonError.failedToEncodeToUTF8(originalDataDescription: "<non-UTF8 data>")
        }
        return string
    }

    public static func toJsonTree<T: Encodable>(
        _ obj: T,
        encoderBuilder: (JSONEncoder) -> JSONEncoder = { $0 }
    ) throws -> Any {
        let encoder = encoderBuilder(threadLocalEncoder)
        let data = try encoder.encode(obj)
        return try JSONSerialization.jsonObject(with: data, options: [])
    }

    public static func toJsonData<T: Encodable>(
        _ obj: T,
        encoderBuilder: (JSONEncoder) -> JSONEncoder = { $0 }
    ) throws -> Data {
        let encoder = encoderBuilder(threadLocalEncoder)
        return try encoder.encode(obj)
    }

    // MARK: - Copy

    public static func copy<IN: Encodable, OUT: Decodable>(
        _ obj: IN,
        encoderBuilder: (JSONEncoder) -> JSONEncoder = { $0 },
        decoderBuilder: (JSONDecoder) -> JSONDecoder = { $0 }
    ) throws -> OUT {
        let encoder = encoderBuilder(threadLocalEncoder)
        let decoder = decoderBuilder(threadLocalDecoder)
        let jsonData = try encoder.encode(obj)
        return try decoder.decode(OUT.self, from: jsonData)
    }
}
