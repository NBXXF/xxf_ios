//
//  BaseRepositoryImpl.swift
//  xxf_ios
//  ObjectBox 实现的 Repository 层（对齐 XXFDatabaseGrdb.BaseRepositoryImpl）
//
//  - 在 DAO throws 之上做了一层安全性包装（`runOperation`），吞掉异常并通过 `errorConsumer` 上报
//  - 返回值改为 Optional / 数组默认值 / Result 等，便于业务层直接调用而不必到处 try?
//
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase
import XXFFoundation

/// ObjectBox 版本的通用 Repository 实现
open class BaseRepositoryImpl<PK: UntypedIdBase,
    Entity: BaseEntity,
    DAO: BaseDaoImpl<PK, Entity>>: XXFDatabase.BaseRepository
{
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = OBQuery<Entity>
    public typealias ErrorConsumer = (Error) -> Void

    public let dao: DAO
    private let errorConsumer: ErrorConsumer?

    public init(dao: DAO, errorConsumer: ErrorConsumer?) {
        self.dao = dao
        self.errorConsumer = errorConsumer
    }

    open func insertOrUpdate(_ entity: Entity) {
        _ = runOperation({
            try dao.insertOrUpdate(entity)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrUpdate(_ entities: [Entity]) {
        _ = runOperation({
            try dao.insertOrUpdate(entities)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrUpdate(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity) {
        _ = runOperation({
            try dao.insertOrUpdate(entity, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrUpdate(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) {
        _ = runOperation({
            try dao.insertOrUpdate(entities, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrIgnore(_ entity: Entity) {
        _ = runOperation({
            try dao.insertOrIgnore(entity)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrIgnore(_ entities: [Entity]) {
        _ = runOperation({
            try dao.insertOrIgnore(entities)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity?) {
        _ = runOperation({
            try dao.insertOrIgnore(entity, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) {
        _ = runOperation({
            try dao.insertOrIgnore(entities, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(id: PK) {
        _ = runOperation({
            try dao.delete(id: id)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(ids: [PK]) {
        _ = runOperation({
            try dao.delete(ids: ids)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(where block: (Query) -> Query) {
        _ = runOperation({
            try dao.delete(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func selectById(_ id: PK) -> Entity? {
        guard let result: Entity? = runOperation({
            try dao.selectById(id)
        }, errorConsumer: errorConsumer).getOrNull() else {
            return nil
        }
        return result
    }

    open func selectByIds(_ ids: [PK]) -> [Entity] {
        runOperation({
            try dao.selectByIds(ids)
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    open func selectAll() -> [Entity] {
        runOperation({
            try dao.selectAll()
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    open func selectOne(where block: (Query) -> Query) throws -> Entity? {
        try dao.selectOne(where: block)
    }

    open func selectFirst(where block: (Query) -> Query) -> Entity? {
        runOperation({
            try dao.selectFirst(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func selectList(where block: (Query) -> Query) -> [Entity] {
        runOperation({
            try dao.selectList(where: block)
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    open func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity> {
        runOperation({
            try dao.selectPage(page: page, pageSize: pageSize, where: block)
        }, errorConsumer: errorConsumer).getOrElse(BasePageInfoDTO(
            pageNum: page,
            pageSize: pageSize,
            hasNextPage: false,
            total: 0,
            list: []
        ))
    }

    open func count(where block: (Query) -> Query) -> Int {
        runOperation({
            try dao.count(where: block)
        }, errorConsumer: errorConsumer).getOrElse(0)
    }

    open func contains(where block: (Query) -> Query) -> Bool {
        runOperation({
            try dao.contains(where: block)
        }, errorConsumer: errorConsumer).getOrElse(false)
    }
}
