//
//  DatabasePool+Create.swift
//  xxf_ios
//  支持多线程
//  Created by xxf on 6/05.
//

import Foundation
import GRDB

import Foundation
import GRDB
import XXFFoundation

public extension DatabasePool {
    class Builder {
        private nonisolated(unsafe) static var cache = ConcurrentDictionary<String, DatabasePool>()
        private static let defaultDbDir = "GRDB"

        private var dbNamed: String?
        private var path: String?
        private var config: Configuration = .init()

        // MARK: - 构造函数

        /// 磁盘数据库（自定义路径）
        public init(path: String) {
            self.path = path
        }

        /// 磁盘数据库（自动路径，存储在 App Support/GRDB）
        public init(dbNamed: String) {
            self.dbNamed = dbNamed
        }

        // MARK: - 链式配置 Configuration 字段

        public func config(_ config: Configuration) -> Self {
            self.config = config
            return self
        }

        // MARK: - 创建数据库实例

        public func build() throws -> DatabasePool {
            try ensurePathed()
            return try DatabasePool(path: path!, configuration: config)
        }

        /// 缓存实例（单例模式）
        public func buildSingle() throws -> DatabasePool {
            try ensurePathed()
            let rawKey = getCacheKey()
            if let cached = Self.cache[rawKey] {
                return cached
            } else {
                let willCache = try build()
                Self.cache[rawKey] = willCache
                return willCache
            }
        }

        // MARK: - 内部路径处理逻辑

        private func ensurePathed() throws {
            if let dbNamed {
                let dbURL = FileManager.default.applicationSupportDirectory()
                    .appendingPathComponent(Self.defaultDbDir)
                    .appendingPathComponent(dbNamed)
                try FileManager.default.createDirectory(at: dbURL.deletingLastPathComponent(), withIntermediateDirectories: true)
                path = dbURL.decodedPath
            }
        }

        private func getCacheKey() -> String {
            return "path:\(path ?? "")"
        }
    }
}
