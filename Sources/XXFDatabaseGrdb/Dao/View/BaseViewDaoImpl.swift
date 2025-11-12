//
//  BaseDaoImpl.swift
//  xxf_ios
//  GRDB 实现的DAO 视图 层，数据库视图只是可读的
//  Created by xxf on /6/4.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

let viewNoPrimaryError: String = "Views do not have the concept of primary keys"
open class BaseViewDaoImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity>: BaseMappedDaoImpl<PK, Entity>
{
    @available(*, deprecated, message: "Views do not have the concept of primary keys")
    open override func selectById(_: PK) throws -> Entity? {
        throw DatabaseParamError(underlyingErrorMsg: viewNoPrimaryError)
    }

    @available(*, deprecated, message: "Views do not have the concept of primary keys")
    open override func selectByIds(_: [PK]) throws -> [Entity] {
        throw DatabaseParamError(underlyingErrorMsg: viewNoPrimaryError)
    }
}
