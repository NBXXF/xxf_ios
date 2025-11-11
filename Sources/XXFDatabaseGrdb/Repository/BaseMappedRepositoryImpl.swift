//
//  BaseRepositoryImpl.swift
//  xxf_ios
//  GRDB 实现的DAO 映射表,特点: 只读,只读！！！
//  方式1: 自定义模型映射能提高查询效率，比如表里面有20个字段,你的模型只映射了一个2个字段,生成的sql 就是两个字段
//  方式2: 表创建的视图映射
//  Created by xxf on /6/3.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

open class BaseMappedRepositoryImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity,
    DAO: BaseMappedDaoImpl<PK, Entity>>: XXFDatabase.ReadableRepository
{
    public typealias Query = QueryInterfaceRequest<Entity>
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
