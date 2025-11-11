//
//  BaseDao.swift
//  xxf_ios
//  可写的dao
//  Created by xxf on /6/4.
//
import XXFDataSource

public protocol WritableDao: LocalDataSource {
    associatedtype PK // 主键类型
    associatedtype Entity // 模型
    associatedtype Query // 查询条件构造器类型（这里简单用闭包）

    // MARK: 插入或者更新(按主键来判断)

    func insertOrUpdate(_ entity: Entity) throws
    func insertOrUpdate(_ entities: [Entity]) throws

    // MARK: 插入或者更新(支持自定义beforeInsert合并)

    func insertOrUpdate(_ entity: Entity,
                        beforeInsert: (Entity, Query) -> Entity) throws
    func insertOrUpdate(
        _ entities: [Entity],
        beforeInsert: ([Entity], Query) -> [Entity]
    ) throws

    // MARK: 插入或忽略（默认按主键判断）

    func insertOrIgnore(_ entity: Entity) throws
    func insertOrIgnore(_ entities: [Entity]) throws

    // MARK: 插入或忽略（按指定beforeInsert忽略)

    func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity?) throws
    func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) throws

    // MARK: 更新,先不封装,容易报错,建议insertXXX

    // MARK: 删除

    func delete(id: PK) throws
    func delete(ids: [PK]) throws
    func delete(where block: (Query) -> Query) throws
}
