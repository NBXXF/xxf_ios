//
//  BaseColumnCodingKey.swift
//  xxf_ios
//  列定义映射
//  Created by xxf on 6/21.
//
/**
 用法参考
 ```swift
 struct FileClosureEntity: BaseEntity {
     static let databaseTableName = "file_closure"

     // 避免重复插入
     static var persistenceConflictPolicy: PersistenceConflictPolicy {
         PersistenceConflictPolicy(insert: .replace, update: .replace)
     }

     // 自定义列名映射（请不要随便修改值！！！！）
     enum CodingKeys: String, BaseColumnCodingKey {
         case id
         case ancestorId = "ancestor_id"
         case descendantId = "descendant_id"
         case depth
     }

     /// 主键,框架需要
     var id: String
     /// 祖先节点ID
     var ancestorId: String
     /// 后代节点ID
     var descendantId: String
     /// 祖先到后代的距离（0 表示自己）
     var depth: Int

     init(ancestorId: String, descendantId: String, depth: Int) {
         self.id = String("\(ancestorId)-\(descendantId)".toXXH3())
         self.ancestorId = ancestorId
         self.descendantId = descendantId
         self.depth = depth
     }
 }
 */
public protocol BaseColumnCodingKey: CodingKey, CaseIterable, RawRepresentable where RawValue == String {}
