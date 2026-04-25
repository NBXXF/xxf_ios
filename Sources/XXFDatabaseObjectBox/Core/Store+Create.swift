//
//  Store+Create.swift
//  xxf_ios
//  简化 Store 构建流程 & 单例缓存（对齐 XXFDatabaseGrdb 的 DatabaseQueue.Builder 风格）
//
//  说明：ObjectBox 的 `Store` 初始化器由代码生成插件生成，签名与业务模型强耦合（例如
//  `try Store(directoryPath:)`），因此此处仅提供统一的“自动目录路径”解析及单例缓存能力，
//  具体构造动作必须由业务侧传入闭包完成。
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase
import XXFFoundation

public extension ObjectBox.Store {
    /// Store 构造器
    ///
    /// - 支持三种路径策略（磁盘绝对路径 / 沙盒相对路径 / 内存数据库）
    /// - 支持单例缓存，避免重复打开同一数据库（ObjectBox 对同目录同时打开多个 Store 行为未定义）
    final class Builder {
        private nonisolated(unsafe) static var cache = ConcurrentDictionary<String, Store>()
        private static let defaultDbDir = "ObjectBox"

        /// 闭包：根据计算后的路径创建 `Store`，由业务侧传入（因为 Store 初始化器由代码生成器生成）
        public typealias StoreFactory = (_ directoryPath: String) throws -> Store

        private var dbNamed: String?
        private var path: String?
        private var memoryNamed: String?

        // MARK: - 构造函数

        /// 磁盘数据库（自定义绝对目录路径）
        public init(path: String) {
            self.path = path
        }

        /// 磁盘数据库（自动路径，存储在 App Support/ObjectBox）
        public init(dbNamed: String) {
            self.dbNamed = dbNamed
        }

        /// 内存数据库（ObjectBox Store 5.x 支持 `memory:<name>` 前缀）
        public init(memoryNamed: String) {
            self.memoryNamed = memoryNamed
        }

        // MARK: - 创建 Store 实例

        /// 根据配置解析出最终 `directoryPath` 后，调用 `factory` 实例化业务侧的 Store
        public func build(factory: StoreFactory) throws -> Store {
            let directoryPath = try resolveDirectoryPath()
            return try factory(directoryPath)
        }

        /// 单例缓存：相同 `directoryPath` 只构造一次
        public func buildSingle(factory: StoreFactory) throws -> Store {
            let directoryPath = try resolveDirectoryPath()
            let key = "path:\(directoryPath)"
            if let cached = Self.cache[key] {
                return cached
            }
            let willCache = try factory(directoryPath)
            Self.cache[key] = willCache
            return willCache
        }

        // MARK: - 内部路径处理逻辑

        private func resolveDirectoryPath() throws -> String {
            if let memoryNamed {
                return Store.inMemoryPrefix + memoryNamed
            }
            if let dbNamed {
                let dbURL = FileManager.default.applicationSupportDirectory()
                    .appendingPathComponent(Self.defaultDbDir)
                    .appendingPathComponent(dbNamed)
                try FileManager.default.createDirectory(at: dbURL, withIntermediateDirectories: true)
                return dbURL.decodedPath
            }
            guard let path else {
                throw DatabaseParamError(underlyingErrorMsg: "StoreBuilder: no path/dbNamed/memoryNamed provided")
            }
            /// 用户自定义 path 场景：目录存在与否由调用方保证（与 GRDB `DatabaseQueue.Builder` 语义一致）
            return path
        }
    }
}
