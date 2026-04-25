//
//  BaseEntity.swift
//  xxf_ios
//  ObjectBox 实现的实体约束
//
//  一个完整的业务实体需要：
//  - BaseTable: 平台中立约束（Codable），保持跨实现一致
//  - ObjectBox.Entity: 作为 ObjectBox 数据模型的标记协议（也可用 // objectbox: entity 注解替代）
//  - ObjectBox.EntityInspectable / __EntityRelatable: 代码生成器生成的元数据协议
//  - Self == Self.EntityBindingType.EntityType: Box<E> 的硬性约束
//
//  用法（由 ObjectBox 代码生成插件生成绑定代码）：
//  ```swift
//  // objectbox: entity
//  class PersonEntity: BaseEntity {
//      var id: Id = 0
//      var name: String = ""
//      required init() {}
//  }
//  ```
//  Created by xxf on 4/25.
//
import ObjectBox
import XXFDatabase

/// ObjectBox 通用实体约束
///
/// - 写入/读取均通过 `Box<Entity>` 完成，因此必须满足 Box 的泛型约束
/// - 继续保留 `BaseTable`，使得不同实现之间的业务模型定义保持对齐
public protocol BaseEntity: BaseTable, ObjectBox.Entity, EntityInspectable, __EntityRelatable
    where Self == Self.EntityBindingType.EntityType {}
