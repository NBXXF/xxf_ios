//
//  BaseDaoImpl.swift
//  xxf_ios
//  ObjectBox 实现的 DAO 层（对齐 XXFDatabaseGrdb.BaseDaoImpl）
//
//  说明：
//  - ObjectBox 主键类型固定为 `Id`（UInt64），因此 PK 泛型参数被约束为 `UntypedIdBase`
//    （`Id` 与 `Int64` 均自动满足），避免业务侧额外定义
//  - Query 类型统一用 `OBQuery<Entity>`（见 Query/OBQuery.swift）
//  - ObjectBox 不支持 SQL，因此不实现 `SqlDao`（上层 Dao 协议只包含 `BaseDao`）
//
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase
import XXFFoundation

/// ObjectBox 版本的通用 DAO 实现
open class BaseDaoImpl<PK: UntypedIdBase, Entity: BaseEntity>: XXFDatabase.BaseDao {
    public typealias PK = PK
    public typealias Entity = Entity
    public typealias Query = OBQuery<Entity>
    public typealias QueryBlock = (Query) -> Query

    /// 尽可能私有化，避免业务子类绕过主线程检查直接使用底层 API
    let proxy: StoreProxy

    public init(proxy: StoreProxy) {
        self.proxy = proxy
    }

    public init(store: Store, allowMainThread: Bool = false) {
        proxy = StoreProxy(store: store, allowMainThread: allowMainThread)
    }

    /// 统一拿 box（内部使用，子类按需开放）
    internal func box() -> Box<Entity> {
        proxy.box(for: Entity.self)
    }

    /// 构造一个空的查询请求（供子类 / 扩展使用）
    public func queryRequest() -> OBQuery<Entity> {
        OBQuery(box: box())
    }

    // MARK: - 插入/更新

    public func insertOrUpdate(_ entity: Entity) throws {
        try proxy.write { _ in
            _ = try box().put(entity, mode: .put)
        }
    }

    public func insertOrUpdate(_ entities: [Entity]) throws {
        try proxy.write { _ in
            try box().put(entities, mode: .put)
        }
    }

    public func insertOrUpdate(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity) throws {
        let willInsert = beforeInsert(entity, queryRequest())
        try proxy.write { _ in
            _ = try box().put(willInsert, mode: .put)
        }
    }

    public func insertOrUpdate(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) throws {
        let willInsert = beforeInsert(entities, queryRequest())
        try proxy.write { _ in
            try box().put(willInsert, mode: .put)
        }
    }

    public func insertOrIgnore(_ entity: Entity) throws {
        try proxy.write { _ in
            let b = box()
            // id == 0 表示新实体，ObjectBox 会自动分配 id，直接 put 即可；
            // id != 0 且已存在则跳过，符合 GRDB `.ignore` 的静默冲突语义
            let id = entity._id.value
            if id != 0, try b.get(id) != nil {
                return
            }
            _ = try b.put(entity, mode: .put)
        }
    }

    public func insertOrIgnore(_ entities: [Entity]) throws {
        try proxy.write { _ in
            let b = box()
            let toInsert = try entities.filter { entity in
                let id = entity._id.value
                if id == 0 { return true }
                return try b.get(id) == nil
            }
            try b.put(toInsert, mode: .put)
        }
    }

    public func insertOrIgnore(_ entity: Entity, beforeInsert: (Entity, Query) -> Entity?) throws {
        guard let willInsert = beforeInsert(entity, queryRequest()) else { return }
        try proxy.write { _ in
            let b = box()
            let id = willInsert._id.value
            if id != 0, try b.get(id) != nil {
                return
            }
            _ = try b.put(willInsert, mode: .put)
        }
    }

    public func insertOrIgnore(_ entities: [Entity], beforeInsert: ([Entity], Query) -> [Entity]) throws {
        let willInsert = beforeInsert(entities, queryRequest())
        try proxy.write { _ in
            let b = box()
            let toInsert = try willInsert.filter { entity in
                let id = entity._id.value
                if id == 0 { return true }
                return try b.get(id) == nil
            }
            try b.put(toInsert, mode: .put)
        }
    }

    // MARK: - 删除

    public func delete(id: PK) throws {
        try proxy.write { _ in
            _ = try box().remove(id)
        }
    }

    public func delete(ids: [PK]) throws {
        try proxy.write { _ in
            _ = try box().remove(ids)
        }
    }

    public func delete(where block: QueryBlock) throws {
        try proxy.write { _ in
            _ = try block(queryRequest()).remove()
        }
    }

    // MARK: - 查询

    open func selectById(_ id: PK) throws -> Entity? {
        try proxy.read { _ in
            try box().get(id)
        }
    }

    open func selectByIds(_ ids: [PK]) throws -> [Entity] {
        try proxy.read { _ in
            try box().get(ids)
        }
    }

    public func selectAll() throws -> [Entity] {
        try proxy.read { _ in
            try box().all()
        }
    }

    public func selectOne(where block: QueryBlock) throws -> Entity? {
        let result = try selectList(where: block)
        guard result.count <= 1 else {
            throw DatabaseParamError(underlyingErrorMsg: "Multiple results found")
        }
        return result.first
    }

    public func selectFirst(where block: QueryBlock) throws -> Entity? {
        try proxy.read { _ in
            try block(queryRequest()).findFirst()
        }
    }

    public func selectList(where block: QueryBlock) throws -> [Entity] {
        try proxy.read { _ in
            try block(queryRequest()).find()
        }
    }

    public func selectPage(page: Int, pageSize: Int, where block: QueryBlock) throws -> BasePageInfoDTO<Entity> {
        try proxy.read { _ in
            let base = block(queryRequest())
            let total = try base.count()
            let offset = (page - 1) * pageSize
            let list = try base.offset(offset).limit(pageSize).find()
            let hasNextPage = (page * pageSize) < total
            return BasePageInfoDTO(
                pageNum: page,
                pageSize: pageSize,
                hasNextPage: hasNextPage,
                total: total,
                list: list
            )
        }
    }

    public func count(where block: QueryBlock) throws -> Int {
        try proxy.read { _ in
            try block(queryRequest()).count()
        }
    }

    public func contains(where block: QueryBlock) throws -> Bool {
        try selectFirst(where: block) != nil
    }
}
