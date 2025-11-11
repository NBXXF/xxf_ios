//
//  WritableRepository.swift
//  xxf_ios
//  可写的数据库层
//  Created by xxf on 6/3.
//

public protocol WritableRepository {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    // MARK: 插入或者更新(按主键来判断)

    func insertOrUpdate(_ entity: Entity)
    func insertOrUpdate(_ entities: [Entity])

    // MARK: 插入或者更新(支持自定义beforeInsert合并)

    func insertOrUpdate(_ entity: Entity,
                        beforeInsert: (Entity, Query) -> Entity)
    func insertOrUpdate(
        _ entities: [Entity],
        beforeInsert: ([Entity], Query) -> [Entity]
    ) throws

    // MARK: 插入或忽略（默认按主键判断）

    func insertOrIgnore(_ entity: Entity)
    func insertOrIgnore(_ entities: [Entity])

    // MARK: 插入或忽略（按指定beforeInsert忽略)

    func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity?)
    func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity])

    func delete(id: PK)
    func delete(ids: [PK])
    func delete(where block: (Query) -> Query)
}
