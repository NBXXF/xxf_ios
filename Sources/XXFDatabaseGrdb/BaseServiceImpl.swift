//
//  Untitled.swift
//  xxf_ios
//  GRDB 实现的BaseService
//  Created by trl on 2025/6/3.
//
import Foundation
import GRDB
import XXFDatabase
import XXFExtensions

open class BaseServiceImpl<PK: DatabaseValueConvertible,
    Entity: PersistableRecord & FetchableRecord & TableRecord>: XXFDatabase.BaseService
{
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = QueryInterfaceRequest<Entity>
    public typealias QueryBlock = (Query) -> Query
    public typealias ErrorConsumer = (Error) -> Void

    ///尽可能私有化,避免业务子类直接使用这个api
    private let dbQueue: DatabaseQueue
    private let errorConsumer: ErrorConsumer?
    init(dbQueue: DatabaseQueue, errorConsumer: ErrorConsumer?) {
        self.dbQueue = dbQueue
        self.errorConsumer = errorConsumer
    }

    public func insert(_ entity: Entity) {
        _ = runOperation({
            try! dbQueue.write { db in
                try entity.insert(db)
            }
        }, errorConsumer: errorConsumer)
    }

    public func insert(_ entities: [Entity]) {
        _ = runOperation({
            try! dbQueue.write { db in
                for e in entities {
                    try e.insert(db)
                }
            }
        }, errorConsumer: errorConsumer)
    }

    public func update(_ entity: Entity) {
        _ = runOperation({
            try! dbQueue.write { db in
                try entity.update(db)
            }
        }, errorConsumer: errorConsumer)
    }

    public func update(_ entities: [Entity]) {
        _ = runOperation({
            try! dbQueue.write { db in
                for e in entities {
                    try e.update(db)
                }
            }
        }, errorConsumer: errorConsumer)
    }

    public func delete(id: PK) {
        _ = runOperation({
            try! dbQueue.write { db in
                /// 效率稍低,主要是现在没办法知道pk 的名字,不想在模型上加更多协议
                if let entity = try Entity.fetchOne(db, key: id) {
                    try entity.delete(db)
                }
            }
        }, errorConsumer: errorConsumer)
    }

    public func delete(ids: [PK]) {
        _ = runOperation({
            try! dbQueue.write { db in
                for id in ids {
                    _ = try Entity.deleteOne(db, key: id)
                }
            }
        }, errorConsumer: errorConsumer)
    }

    public func selectById(_ id: PK) -> Entity? {
        try! dbQueue.read { db in
            try Entity.fetchOne(db, key: id)
        }
    }

    public func selectByIds(_ ids: [PK]) -> [Entity] {
        let result = runOperation({
            try! dbQueue.read { db in
                try Entity.fetchAll(db, keys: ids)
            }
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    public func selectAll() -> [Entity] {
        let result = runOperation({
            try! dbQueue.read { db in
                try Entity.fetchAll(db)
            }
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    public func selectOne(where block: QueryBlock) throws -> Entity? {
        let results = selectList(where: block)
        guard results.count <= 1 else {
            throw NSError(domain: "BaseService", code: 1001, userInfo: [NSLocalizedDescriptionKey: "Multiple results found"])
        }
        return results.first
    }

    public func selectFirst(where block: QueryBlock) -> Entity? {
        let result: Entity? = runOperation({
            try! dbQueue.read { db in
                let request = block(Entity.all())
                return try request.fetchOne(db)!
            }
        }, errorConsumer: errorConsumer).getOrNull()
        return result
    }

    public func selectList(where block: QueryBlock) -> [Entity] {
        let results: [Entity] = runOperation({
            try! dbQueue.read { db in
                let request = block(Entity.all())
                return try request.fetchAll(db)
            }
        }, errorConsumer: errorConsumer).getOrElse([])
        return results
    }

    public func count(where block: QueryBlock) -> Int {
        let result = runOperation({
            try! dbQueue.read { db in
                let request = block(Entity.all())
                return try request.fetchCount(db)
            }
        }, errorConsumer: errorConsumer).getOrElse(0)
        return result
    }

    public func contains(where block: QueryBlock) -> Bool {
        let result: Bool = runOperation({
            selectFirst(where: block) != nil
        }, errorConsumer: errorConsumer).getOrElse(false)
        return result
    }
}
