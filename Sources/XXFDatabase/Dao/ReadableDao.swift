//
//  BaseDao.swift
//  xxf_ios
//  只读
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol ReadableDao: LocalDataSource {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    // MARK: 查询-简单

    func selectById(_ id: PK) throws -> Entity?
    func selectByIds(_ ids: [PK]) throws -> [Entity]
    func selectAll() throws -> [Entity]

    // MARK: 查询-复杂查询

    /**
     * 如果重复将会抛出异常
     */
    func selectOne(where block: (Query) -> Query) throws -> Entity?
    func selectFirst(where block: (Query) -> Query) throws -> Entity?
    func selectList(where block: (Query) -> Query) throws -> [Entity]
    func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) throws -> BasePageInfoDTO<Entity>
    func count(where block: (Query) -> Query) throws -> Int
    func contains(where block: (Query) -> Query) throws -> Bool
}
