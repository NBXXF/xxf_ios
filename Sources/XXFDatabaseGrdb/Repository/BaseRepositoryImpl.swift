//
//  BaseRepositoryImpl.swift
//  xxf_ios
//  GRDB 实现的BaseRepositoryImpl
//  Created by xxf on 6/3.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

open class BaseRepositoryImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity,
    DAO: BaseDaoImpl<PK, Entity>>: XXFDatabase.BaseRepository
{
    public typealias Query = QueryInterfaceRequest<Entity>
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

    open func insertOrUpdate(_ entity: Entity, beforeInsert: (Entity, GRDB.QueryInterfaceRequest<Entity>) -> Entity) {
        _ = runOperation({
            try dao.insertOrUpdate(entity, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrUpdate(_ entities: [Entity], beforeInsert: ([Entity], GRDB.QueryInterfaceRequest<Entity>) -> [Entity]) {
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

    open func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, GRDB.QueryInterfaceRequest<Entity>) -> Entity?) {
        _ = runOperation({
            try dao.insertOrIgnore(entity, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], GRDB.QueryInterfaceRequest<Entity>) -> [Entity]) {
        _ = runOperation({
            try dao.insertOrIgnore(entities, beforeInsert: beforeInsert)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(id: PK) {
        _ = runOperation({
            try dao.delete(id: id)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(where block: (GRDB.QueryInterfaceRequest<Entity>) -> GRDB.QueryInterfaceRequest<Entity>) {
        _ = runOperation({
            try dao.delete(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    open func delete(ids: [PK]) {
        _ = runOperation({
            try dao.delete(ids: ids)
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
        let result: [Entity] = runOperation({
            try dao.selectByIds(ids)
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    open func selectAll() -> [Entity] {
        let result: [Entity] = runOperation({
            try dao.selectAll()
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    open func selectOne(where block: (Query) -> Query) throws -> Entity? {
        try dao.selectOne(where: block)
    }

    open func selectFirst(where block: (Query) -> Query) -> Entity? {
        let result: Entity? = runOperation({
            try dao.selectFirst(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
        return result
    }

    open func selectList(where block: (Query) -> Query) -> [Entity] {
        let result: [Entity] = runOperation({
            try dao.selectList(where: block)
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    open func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity> {
        let result: BasePageInfoDTO<Entity> = runOperation({
            try dao.selectPage(page: page, pageSize: pageSize, where: block)
        }, errorConsumer: errorConsumer).getOrElse(BasePageInfoDTO(
            pageNum: page,
            pageSize: pageSize,
            hasNextPage: false,
            total: 0,
            list: []
        ))

        return result
    }

    open func count(where block: (Query) -> Query) -> Int {
        let result = runOperation({
            try dao.count(where: block)
        }, errorConsumer: errorConsumer).getOrElse(0)
        return result
    }

    open func contains(where block: (Query) -> Query) -> Bool {
        let result: Bool = runOperation({
            try dao.contains(where: block)
        }, errorConsumer: errorConsumer).getOrElse(false)
        return result
    }
}
