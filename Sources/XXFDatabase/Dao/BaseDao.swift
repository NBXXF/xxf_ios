//
//  BaseDao.swift
//  xxf_ios
//  提供通用的dao层
//  Created by xxf on /6/4.
//

public protocol BaseDao {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    func insert(_ entity: Entity) throws
    func insert(_ entities: [Entity]) throws

    func insertOrUpdate(_ entity: Entity) throws
    func insertOrUpdate(_ entities: [Entity]) throws

    func update(_ entity: Entity) throws
    func update(_ entities: [Entity]) throws

    func delete(id: PK) throws
    func delete(ids: [PK]) throws

    func selectById(_ id: PK) throws -> Entity?
    func selectByIds(_ ids: [PK]) throws -> [Entity]

    func selectAll() throws -> [Entity]

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
