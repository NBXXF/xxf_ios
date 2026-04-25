//
//  BaseMappedRepositoryImpl.swift
//  xxf_ios
//  ObjectBox 的只读 Repository 实现（对齐 XXFDatabaseGrdb.BaseMappedRepositoryImpl）
//
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase
import XXFFoundation

/// 只读 Repository，基于只读 DAO 包装
open class BaseMappedRepositoryImpl<PK: UntypedIdBase,
    Entity: BaseEntity,
    DAO: BaseMappedDaoImpl<PK, Entity>>: XXFDatabase.ReadableRepository
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

    public func selectById(_ id: PK) -> Entity? {
        guard let result: Entity? = runOperation({
            try dao.selectById(id)
        }, errorConsumer: errorConsumer).getOrNull() else {
            return nil
        }
        return result
    }

    public func selectByIds(_ ids: [PK]) -> [Entity] {
        runOperation({
            try dao.selectByIds(ids)
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    public func selectAll() -> [Entity] {
        runOperation({
            try dao.selectAll()
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    public func selectOne(where block: (Query) -> Query) throws -> Entity? {
        try dao.selectOne(where: block)
    }

    public func selectFirst(where block: (Query) -> Query) -> Entity? {
        runOperation({
            try dao.selectFirst(where: block)
        }, errorConsumer: errorConsumer).getOrNull()
    }

    public func selectList(where block: (Query) -> Query) -> [Entity] {
        runOperation({
            try dao.selectList(where: block)
        }, errorConsumer: errorConsumer).getOrElse([])
    }

    public func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity> {
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

    public func count(where block: (Query) -> Query) -> Int {
        runOperation({
            try dao.count(where: block)
        }, errorConsumer: errorConsumer).getOrElse(0)
    }

    public func contains(where block: (Query) -> Query) -> Bool {
        runOperation({
            try dao.contains(where: block)
        }, errorConsumer: errorConsumer).getOrElse(false)
    }
}
