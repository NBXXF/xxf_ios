//
//  OBQuery.swift
//  xxf_ios
//  ObjectBox 的查询请求包装器（对齐 GRDB 的 `QueryInterfaceRequest<Entity>` 角色）
//
//  设计思路：
//  - 不可变值类型，通过链式调用累积 `QueryBuilder` 配置 & Query 层面的 offset/limit
//  - 只在真正执行时（find/count/...）才解析链条、实例化 `QueryBuilder`、构建 `Query`
//  - `where(_:)` 追加 AND 条件，多次调用将按声明顺序 AND 拼接
//
//  Created by xxf on 4/25.
//
import Foundation
import ObjectBox
import XXFDatabase

/// ObjectBox 查询请求（对应 GRDB 的 `QueryInterfaceRequest<Entity>`）
///
/// - Important: 值类型，链式调用每次返回新实例，原始对象不会被修改
public struct OBQuery<E: BaseEntity> {
    /// 条件闭包：由调用方基于生成的 `Property<...>` 构造 `QueryCondition<E>`
    public typealias ConditionBlock = () -> QueryCondition<E>
    /// `QueryBuilder` 配置闭包（用于 ordered 等无法通过 QueryCondition 表达的操作）
    public typealias BuilderConfigurator = (QueryBuilder<E>) -> Void

    internal let box: Box<E>
    internal let conditions: [ConditionBlock]
    internal let configurators: [BuilderConfigurator]
    /// Query 级别的 offset（在 find/findIds 阶段应用，而非 QueryBuilder 阶段）
    internal let offset: Int
    /// Query 级别的 limit（在 find/findIds 阶段应用，而非 QueryBuilder 阶段）
    internal let limit: Int

    internal init(
        box: Box<E>,
        conditions: [ConditionBlock] = [],
        configurators: [BuilderConfigurator] = [],
        offset: Int = 0,
        limit: Int = 0
    ) {
        self.box = box
        self.conditions = conditions
        self.configurators = configurators
        self.offset = offset
        self.limit = limit
    }

    // MARK: - 链式配置

    /// 追加一个 AND 条件
    public func `where`(_ condition: @escaping ConditionBlock) -> OBQuery<E> {
        OBQuery(
            box: box,
            conditions: conditions + [condition],
            configurators: configurators,
            offset: offset,
            limit: limit
        )
    }

    /// 追加 `QueryBuilder` 配置（例如 `$0.ordered(by: SomeEntity.name)`）
    public func configure(_ block: @escaping BuilderConfigurator) -> OBQuery<E> {
        OBQuery(
            box: box,
            conditions: conditions,
            configurators: configurators + [block],
            offset: offset,
            limit: limit
        )
    }

    /// 设置 offset（在 find/findIds 时生效）
    public func offset(_ value: Int) -> OBQuery<E> {
        OBQuery(
            box: box,
            conditions: conditions,
            configurators: configurators,
            offset: value,
            limit: limit
        )
    }

    /// 设置 limit（在 find/findIds 时生效）
    public func limit(_ value: Int) -> OBQuery<E> {
        OBQuery(
            box: box,
            conditions: conditions,
            configurators: configurators,
            offset: offset,
            limit: value
        )
    }

    // MARK: - 终结操作

    /// 查找全部匹配结果
    public func find() throws -> [E] {
        try buildQuery().find(offset: offset, limit: limit)
    }

    /// 查找第一条
    public func findFirst() throws -> E? {
        try buildQuery().findFirst()
    }

    /// 如果匹配结果不唯一，抛错
    public func findUnique() throws -> E? {
        try buildQuery().findUnique()
    }

    /// 计数
    public func count() throws -> Int {
        try buildQuery().count()
    }

    /// 按条件删除，返回被删除数量
    @discardableResult
    public func remove() throws -> UInt64 {
        try buildQuery().remove()
    }

    // MARK: - 内部：从链条构造 Query

    internal func buildQuery() throws -> Query<E> {
        // ObjectBox 的 `box.query(_:)` 需要一个返回 `QueryCondition<E>` 的闭包。
        // 我们将多个条件合成为一个 AND 表达式；没有条件时回落到空 QueryBuilder。
        let builder: QueryBuilder<E>
        if conditions.isEmpty {
            builder = box.query()
        } else {
            builder = box.query { [conditions] in
                // 按顺序 AND
                var iterator = conditions.makeIterator()
                guard let first = iterator.next() else {
                    // 不可能到达，上面已判空
                    fatalError("OBQuery: empty conditions after guard")
                }
                var combined: QueryCondition<E> = first()
                while let next = iterator.next() {
                    combined = combined && next()
                }
                return combined
            }
        }
        // 应用 QueryBuilder 层配置（order 等）
        for config in configurators {
            config(builder)
        }
        return try builder.build()
    }
}
