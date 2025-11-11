//
//  BaseDaoImpl.swift
//  xxf_ios
//  GRDB 实现的DAO 层
//  Created by xxf on /6/4.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

let entityTypeError: String = "entity type  param is error"

open class BaseDaoImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity>: XXFDatabase.BaseDao
{
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = QueryInterfaceRequest<Entity>
    public typealias QueryBlock = (Query) -> Query

    /// 尽可能私有化,避免业务子类直接使用这个api
    let proxy: DatabaseProxy
    public init(proxy: DatabaseProxy) {
        self.proxy = proxy
    }

    public init(database: DatabaseQueue, allowMainThread: Bool = false) {
        proxy = DatabaseProxy(database: database, allowMainThread: allowMainThread)
    }

    public init(database: DatabasePool, allowMainThread: Bool = false) {
        proxy = DatabaseProxy(database: database, allowMainThread: allowMainThread)
    }

    // MARK: 插入

    public func insertOrUpdate(_ entity: Entity) throws {
        try proxy.write { db in
            /// 自增主键 会变
            try entity.insert(db, onConflict: .replace)
        }
    }

    public func insertOrUpdate(_ entities: [Entity]) throws {
        try proxy.write { db in
            /// 自增主键 会变
            for e in entities {
                try e.insert(db, onConflict: .replace)
            }
        }
    }

    public func insertOrUpdate(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity) throws {
        let willInsert = beforeInsert(entity, Entity.all())
        try proxy.write { db in
            try willInsert.insert(db, onConflict: .replace)
        }
    }

    public func insertOrUpdate(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) throws {
        let willInsert = beforeInsert(entities, Entity.all())
        try proxy.write { db in
            for e in willInsert {
                try e.insert(db, onConflict: .replace)
            }
        }
    }

    public func insertOrIgnore(_ entity: Entity) throws {
        try proxy.write { db in
            try entity.insert(db, onConflict: .ignore)
        }
    }

    public func insertOrIgnore(_ entities: [Entity]) throws {
        try proxy.write { db in
            for e in entities {
                try e.insert(db, onConflict: .ignore)
            }
        }
    }

    public func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity?) throws {
        if let willInsert = beforeInsert(entity, Entity.all()) {
            try proxy.write { db in
                try willInsert.insert(db, onConflict: .ignore)
            }
        }
    }

    public func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) throws {
        let willInsert = beforeInsert(entities, Entity.all())
        try proxy.write { db in
            for e in willInsert {
                try e.insert(db, onConflict: .ignore)
            }
        }
    }

    // MARK: 删除

    public func delete(id: PK) throws {
        try proxy.write { db in
            /// 效率稍低,主要是现在没办法知道pk 的名字,不想在模型上加更多协议
            if let entity = try Entity.fetchOne(db, key: id) {
                try entity.delete(db)
            }
        }
    }

    public func delete(ids: [PK]) throws {
        try proxy.write { db in
            for id in ids {
                _ = try Entity.deleteOne(db, key: id)
            }
        }
    }

    public func delete(where block: QueryBlock) throws {
        try proxy.write { db in
            let request = block(Entity.all())
            try request.deleteAll(db)
        }
    }

    open func selectById(_ id: PK) throws -> Entity? {
        let result: Entity? = try proxy.read { db in
            try Entity.fetchOne(db, key: id)
        }
        return result
    }

    open func selectByIds(_ ids: [PK]) throws -> [Entity] {
        let result: [Entity] = try proxy.read { db in
            try Entity.fetchAll(db, keys: ids)
        }
        return result
    }

    public func selectAll() throws -> [Entity] {
        let result: [Entity] = try proxy.read { db in
            try Entity.fetchAll(db)
        }
        return result
    }

    public func selectOne(where block: QueryBlock) throws -> Entity? {
        let result = try selectList(where: block)
        guard result.count <= 1 else {
            throw DatabaseParamError(underlyingErrorMsg: "Multiple results found")
        }
        return result.first
    }

    public func selectFirst(where block: QueryBlock) throws -> Entity? {
        let result: Entity? = try proxy.read { db in
            let request = block(Entity.all())
            return try request.fetchOne(db)
        }
        return result
    }

    public func selectList(where block: QueryBlock) throws -> [Entity] {
        let result: [Entity] = try proxy.read { db in
            let request = block(Entity.all())
            return try request.fetchAll(db)
        }
        return result
    }

    public func selectPage(page: Int, pageSize: Int, where block: QueryBlock) throws -> BasePageInfoDTO<Entity> {
        return try proxy.read { db in
            let request = block(Entity.all())
            let total = try request.fetchCount(db)
            let pagedRequest = request.limit(pageSize, offset: (page - 1) * pageSize)
            let list = try pagedRequest.fetchAll(db)
            let hasNextPage = (page * pageSize) < total
            return BasePageInfoDTO(
                pageNum: page,
                pageSize: pageSize,
                hasNextPage: hasNextPage,
                total: total,
                list: list
            )
        }
    }

    public func count(where block: QueryBlock) throws -> Int {
        let result = try proxy.read { db in
            let request = block(Entity.all())
            return try request.fetchCount(db)
        }
        return result
    }

    public func contains(where block: QueryBlock) throws -> Bool {
        let result: Bool = try selectFirst(where: block) != nil
        return result
    }
}
