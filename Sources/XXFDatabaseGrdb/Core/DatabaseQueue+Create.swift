//
//  DatabaseQueue+Create.swift
//  xxf_ios
//  简化api & 单例的数据库
//  Created by xxf on /6/5.
//

import Foundation
import GRDB

import Foundation
import GRDB

public extension DatabaseQueue {
    class Builder {
        private nonisolated(unsafe) static var cache: [String: DatabaseQueue] = [:]
        private static let defaultDbDir = "GRDB"

        private var dbNamed: String?
        private var path: String?
        private var memoryNamed: String?
        private var config: Configuration = .init()

        // MARK: - 构造函数

        /// 磁盘数据库
        public init(path: String) {
            self.path = path
        }

        /// 内存数据库
        public init(memoryNamed: String) {
            self.memoryNamed = memoryNamed
        }

        /// 磁盘数据库名称(自动存沙盒里面)
        public init(dbNamed: String) {
            self.dbNamed = dbNamed
        }

        // MARK: - 链式配置 Configuration 字段

        public func config(_ config: Configuration) -> Self {
            self.config = config
            return self
        }

        // MARK: - 创建数据库实例

        public func build() throws -> DatabaseQueue {
            try ensurePathed()
            if let memoryNamed {
                return try DatabaseQueue(named: memoryNamed, configuration: config)
            } else {
                return try DatabaseQueue(path: path!, configuration: config)
            }
        }

        /// 缓存实例
        public func buildSingle() throws -> DatabaseQueue {
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
                if #available(iOS 16, macOS 13, *) {
                    // iOS16+用不编码路径
                    path = dbURL.path(percentEncoded: false)
                } else {
                    // iOS16之前，path就是非编码路径
                    path = dbURL.path
                }
            }
        }

        private func getCacheKey() -> String {
            if let memoryNamed {
                return "named:\(memoryNamed)"
            } else {
                return "path:\(path ?? "")"
            }
        }
    }
}
