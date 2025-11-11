//
//  BaseDaoImpl.swift
//  xxf_ios
//  GRDB 实现的DAO 映射表,特点: 只读,只读！！！
//  方式1: 自定义模型映射能提高查询效率，比如表里面有20个字段,你的模型只映射了一个2个字段,生成的sql 就是两个字段
//  方式2: 表创建的视图映射
//  Created by xxf on /6/4.
//
import Foundation
import GRDB
import XXFDatabase
import XXFFoundation

open class BaseMappedDaoImpl<PK: DatabaseValueConvertible,
    Entity: BaseEntity>: XXFDatabase.ReadableDao
{
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = QueryInterfaceRequest<Entity>
    public typealias QueryBlock = (Query) -> Query

    /// 尽可能私有化,避免业务子类直接使用这个api
    let proxy: DatabaseProxy
    let proxyDao: BaseDaoImpl<PK, Entity>
    public init(proxy: DatabaseProxy) {
        self.proxy = proxy
        proxyDao = BaseDaoImpl(proxy: proxy)
    }

    public init(database: DatabaseQueue, allowMainThread: Bool = false) {
        proxy = DatabaseProxy(database: database, allowMainThread: allowMainThread)
        proxyDao = BaseDaoImpl(proxy: proxy)
    }

    public init(database: DatabasePool, allowMainThread: Bool = false) {
        proxy = DatabaseProxy(database: database, allowMainThread: allowMainThread)
        proxyDao = BaseDaoImpl(proxy: proxy)
    }

    open func selectById(_ id: PK) throws -> Entity? {
        return try proxyDao.selectById(id)
    }

    open func selectByIds(_ ids: [PK]) throws -> [Entity] {
        return try proxyDao.selectByIds(ids)
    }

    public func selectAll() throws -> [Entity] {
        return try proxyDao.selectAll()
    }

    public func selectOne(where block: QueryBlock) throws -> Entity? {
        return try proxyDao.selectOne(where: block)
    }

    public func selectFirst(where block: QueryBlock) throws -> Entity? {
        return try proxyDao.selectFirst(where: block)
    }

    public func selectList(where block: QueryBlock) throws -> [Entity] {
        return try proxyDao.selectList(where: block)
    }

    public func selectPage(page: Int, pageSize: Int, where block: QueryBlock) throws -> BasePageInfoDTO<Entity> {
        return try proxyDao.selectPage(page: page, pageSize: pageSize, where: block)
    }

    public func count(where block: QueryBlock) throws -> Int {
        return try proxyDao.count(where: block)
    }

    public func contains(where block: QueryBlock) throws -> Bool {
        return try proxyDao.contains(where: block)
    }
}
