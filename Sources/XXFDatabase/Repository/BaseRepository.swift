//
//  BaseRepository.swift
//  xxf_ios
//  数据库通用Repository，无论底层数据库是objectbox 还是GRDB
//  Created by xxfon /6/3.
//

public protocol BaseRepository {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    func insert(_ entity: Entity)
    func insert(_ entities: [Entity])

    func insertOrUpdate(_ entity: Entity)
    func insertOrUpdate(_ entities: [Entity])

    func update(_ entity: Entity)
    func update(_ entities: [Entity])

    func delete(id: PK)
    func delete(ids: [PK])
    func delete(where block: (Query) -> Query)

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
