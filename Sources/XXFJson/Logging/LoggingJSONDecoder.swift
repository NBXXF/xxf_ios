//
//  LoggingJSONDecoder.swift
//  xxf_ios
//  支持遇到错误打印一下日志
//  Created by xxf on 6/29.
//
import Foundation
import XXFFoundation

open class LoggingJSONDecoder: JSONDecoder, @unchecked Sendable {
    /// 缓存的 Logger
    private static let loggingCachedLogger: Logger = {
        let logger = Logger(label: "com.xxf.json.log")
        return logger
    }()

    // 存储初始化位置
    private let creationFile: String
    private let creationFunction: String
    private let creationLine: Int

    public init(
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        creationFile = file
        creationFunction = function
        creationLine = line
        super.init() // 调用 JSONDecoder 的 init()
    }

    /// 日志打印方法，增加 type 参数
    private func logError(_ error: Error, data: Data, type: Any.Type) {
        Self.loggingCachedLogger.error("Error json decode for type '\(type)': \(error)", file: creationFile, function: creationFile, line: UInt(creationLine))
        if let s = String(data: data.prefix(1024), encoding: .utf8) {
            Self.loggingCachedLogger.error("Error json decode rawData (truncated): \(s)", file: creationFile, function: creationFile, line: UInt(creationLine))
        }
    }

    override open func decode<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable {
        do { return try super.decode(type, from: data) }
        catch { logError(error, data: data, type: type); throw error }
    }

    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    override open func decode<T>(_ type: T.Type, from data: Data, configuration: T.DecodingConfiguration) throws -> T where T: DecodableWithConfiguration {
        do { return try super.decode(type, from: data, configuration: configuration) }
        catch { logError(error, data: data, type: type); throw error }
    }

    @available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
    override open func decode<T, C>(_ type: T.Type, from data: Data, configuration: C.Type) throws -> T where T: DecodableWithConfiguration, C: DecodingConfigurationProviding, T.DecodingConfiguration == C.DecodingConfiguration {
        do { return try super.decode(type, from: data, configuration: configuration) }
        catch { logError(error, data: data, type: type); throw error }
    }
}
