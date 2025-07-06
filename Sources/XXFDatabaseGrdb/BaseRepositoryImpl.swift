//
//  BaseRepositoryImpl.swift
//  xxf_ios
//  GRDB 实现的BaseRepositoryImpl
//  Created by xxfon /6/3.
//
import Foundation
import GRDB
import XXFDatabase
import XXFExtensions

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

    public func insert(_ entity: Entity) {
        _ = runOperation({
            try dao.insert(entity)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func insert(_ entities: [Entity]) {
        _ = runOperation({
            try dao.insert(entities)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func insertOrUpdate(_ entity: Entity) {
        _ = runOperation({
            try dao.insertOrUpdate(entity)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func insertOrUpdate(_ entities: [Entity]) {
        _ = runOperation({
            try dao.insertOrUpdate(entities)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func update(_ entity: Entity) {
        _ = runOperation({
            try dao.update(entity)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func update(_ entities: [Entity]) {
        _ = runOperation({
            try dao.update(entities)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func delete(id: PK) {
        _ = runOperation({
            try dao.delete(id: id)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func delete(where block: (GRDB.QueryInterfaceRequest<Entity>) -> GRDB.QueryInterfaceRequest<Entity>) {
        _ = runOperation({
            try dao.delete(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func delete(ids: [PK]) {
        _ = runOperation({
            try dao.delete(ids: ids)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func selectById(_ id: PK) -> Entity? {
        guard let result: Entity? = runOperation({
            try dao.selectById(id)
        }, errorConsumer: errorConsumer).getOrNull() else {
            return nil
        }
        return result
    }

    public func selectByIds(_ ids: [PK]) -> [Entity] {
        let result: [Entity] = runOperation({
            try dao.selectByIds(ids)
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    public func selectAll() -> [Entity] {
        let result: [Entity] = runOperation({
            try dao.selectAll()
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    public func selectOne(where block: (Query) -> Query) throws -> Entity? {
        try dao.selectOne(where: block)
    }

    public func selectFirst(where block: (Query) -> Query) -> Entity? {
        let result: Entity? = runOperation({
            try dao.selectFirst(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
        return result
    }

    public func selectList(where block: (Query) -> Query) -> [Entity] {
        let result: [Entity] = runOperation({
            try dao.selectList(where: block)
        }, errorConsumer: errorConsumer).getOrElse([])
        return result
    }

    public func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity> {
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

    public func count(where block: (Query) -> Query) -> Int {
        let result = runOperation({
            try dao.count(where: block)
        }, errorConsumer: errorConsumer).getOrElse(0)
        return result
    }

    public func contains(where block: (Query) -> Query) -> Bool {
        let result: Bool = runOperation({
            try dao.contains(where: block)
        }, errorConsumer: errorConsumer).getOrElse(false)
        return result
    }
}
