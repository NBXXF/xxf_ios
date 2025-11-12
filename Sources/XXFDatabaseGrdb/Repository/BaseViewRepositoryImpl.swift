//
//  BaseRepositoryImpl.swift
//  xxf_ios
//  GRDB 实现的BaseRepositoryImpl 针对视图,视图是只读的
//  Created by xxf on /6/3.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

open class BaseViewRepositoryImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity,
    DAO: BaseViewDaoImpl<PK, Entity>>: BaseMappedRepositoryImpl<PK, Entity, DAO>
{
    @available(*, deprecated, message: "Views do not have the concept of primary keys")
    public override func selectById(_ id: PK) -> Entity? {
        return super.selectById(id)
    }

    @available(*, deprecated, message: "Views do not have the concept of primary keys")
    public override func selectByIds(_ ids: [PK]) -> [Entity] {
        return super.selectByIds(ids)
    }
}
