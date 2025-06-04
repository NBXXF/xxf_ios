//
//  BaseService.swift
//  xxf_ios
//  数据库通用service，无论底层数据库是objectbox 还是GRDB
//  Created by xxfon 2025/6/3.
//

public protocol BaseService {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    func insert(_ entity: Entity)
    func insert(_ entities: [Entity])

    func update(_ entity: Entity)
    func update(_ entities: [Entity])

    func delete(id: PK)
    func delete(ids: [PK])

    func selectById(_ id: PK) -> Entity?
    func selectByIds(_ ids: [PK]) -> [Entity]

    func selectAll() -> [Entity]

    /**
     * 如果重复将会抛出异常
     */
    func selectOne(where block: (Query) -> Query) throws -> Entity?
    func selectFirst(where block: (Query) -> Query) -> Entity?
    func selectList(where block: (Query) -> Query) -> [Entity]
    func selectPage(page: Int, pageSize: Int, where block: (Query) -> Query) -> BasePageInfoDTO<Entity>
    func count(where block: (Query) -> Query) -> Int
    func contains(where block: (Query) -> Query) -> Bool
}
