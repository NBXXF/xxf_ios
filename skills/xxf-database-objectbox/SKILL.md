---
name: xxf-database-objectbox
description: XXFDatabaseObjectBox（ObjectBox 对象数据库实现）。当用户已选 ObjectBox，要写 Entity、Query、关系、Box 操作时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFDatabaseObjectBox

基于 ObjectBox 的对象数据库实现，写入密集型场景性能优于 SQLite。

## 触发场景

- 已通过 `xxf-database` 选定 ObjectBox
- 批量写入 / 实时同步场景
- 对象模型和业务强对齐（无复杂 join 需求）

## 前置

**先走 `xxf-database` 做好抽象层设计**，再进入本 skill 写实现。

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFDatabaseObjectBox/**/*.swift
   Grep "public|Entity|Box" in Sources/XXFDatabaseObjectBox/
   ```
2. 定位 XXF 的封装入口
3. 定义 Entity（遵守 ObjectBox 的 `EntityInspectable` / 代码生成约定）
4. 实现 `XxxRepositoryImpl`，通过 `Box<T>` 操作
5. 关系字段注意弱引用 / ToOne / ToMany 的选择

## Entity 约定

- 类型用 `class`，ObjectBox 要求
- `id` 字段类型 ObjectBox 管理（以源码为准）
- 非持久字段加 `@objectbox: transient`
- 命名对齐业务，**不要**带"Entity"后缀（冗余）

## 反模式

- 把 ObjectBox Entity 直接当 Domain Model 用（打破分层）
- 忽略 ObjectBox 的代码生成步骤（构建会失败）
- 跨线程传递 Box（线程封闭）

## 相关 skill

- `xxf-database` — 上游抽象层
