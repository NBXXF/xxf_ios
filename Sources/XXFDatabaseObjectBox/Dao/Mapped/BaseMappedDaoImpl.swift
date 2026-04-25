//
//  BaseMappedDaoImpl.swift
//  xxf_ios
//  ObjectBox 的只读 DAO 实现（对应 XXFDatabaseGrdb.BaseMappedDaoImpl）
//
//  ObjectBox 没有“视图”这一概念，`BaseMappedDaoImpl` 在此仅作为“只读 DAO”的统一入口，
//  内部复用 `BaseDaoImpl` 的读操作，写能力不对外暴露。
//
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase
import XXFFoundation

/// 只读 DAO，包装主 `BaseDaoImpl` 的读取能力
open class BaseMappedDaoImpl<PK: UntypedIdBase, Entity: BaseEntity>: XXFDatabase.ReadableDao {
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = OBQuery<Entity>
    public typealias QueryBlock = (Query) -> Query

    let proxy: StoreProxy
    let proxyDao: BaseDaoImpl<PK, Entity>

    public init(proxy: StoreProxy) {
        self.proxy = proxy
        proxyDao = BaseDaoImpl(proxy: proxy)
    }

    public init(store: Store, allowMainThread: Bool = false) {
        proxy = StoreProxy(store: store, allowMainThread: allowMainThread)
        proxyDao = BaseDaoImpl(proxy: proxy)
    }

    open func selectById(_ id: PK) throws -> Entity? {
        try proxyDao.selectById(id)
    }

    open func selectByIds(_ ids: [PK]) throws -> [Entity] {
        try proxyDao.selectByIds(ids)
    }

    public func selectAll() throws -> [Entity] {
        try proxyDao.selectAll()
    }

    public func selectOne(where block: QueryBlock) throws -> Entity? {
        try proxyDao.selectOne(where: block)
    }

    public func selectFirst(where block: QueryBlock) throws -> Entity? {
        try proxyDao.selectFirst(where: block)
    }

    public func selectList(where block: QueryBlock) throws -> [Entity] {
        try proxyDao.selectList(where: block)
    }

    public func selectPage(page: Int, pageSize: Int, where block: QueryBlock) throws -> BasePageInfoDTO<Entity> {
        try proxyDao.selectPage(page: page, pageSize: pageSize, where: block)
    }

    public func count(where block: QueryBlock) throws -> Int {
        try proxyDao.count(where: block)
    }

    public func contains(where block: QueryBlock) throws -> Bool {
        try proxyDao.contains(where: block)
    }
}
