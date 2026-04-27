---
name: xxf-database-grdb
description: XXFDatabaseGrdb（SQLite / GRDB 实现）。当用户已选 GRDB，要写具体的 Repository Impl、建表、Migration、原生 SQL、事务、WAL 配置时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFDatabaseGrdb

基于 [GRDB.swift](https://github.com/groue/GRDB.swift) 的 SQLite 实现。

## 触发场景

- 已通过 `xxf-database` 选定 GRDB
- 写具体的 Repository Impl
- Schema 迁移
- 复杂 SQL 查询

## 前置

**先走 `xxf-database` 做好抽象层设计**，再进入本 skill 写实现。

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFDatabaseGrdb/**/*.swift
   Grep "public|DatabasePool|Migration" in Sources/XXFDatabaseGrdb/
   ```
2. 定位 XXF 的封装入口（对 `DatabasePool` / `DatabaseQueue` 的包装）
3. 实现 `XxxRepositoryImpl`，持有 DB 连接
4. 写 Migration 块（每次 schema 改动新增一个，不回头改旧的）
5. 单测：用内存库 `DatabaseQueue()` 不依赖真实文件

## Migration 铁律

- **不可修改**已发布的 migration
- 每次改动追加一个新 migration
- 真机测试旧版升级到新版
- Migration 内**不要**跨 migration 引用（每个要自包含）

## 并发

- 写：`db.write { ... }`，进入串行队列
- 读：`db.read { ... }`，可并发
- **不要**混用 `DatabaseQueue` 和 `DatabasePool` 指向同一文件

## 反模式

- 在 Repository Impl 里直接返回 `GRDB.Row`（要转成 Domain Model）
- Migration 里做数据清洗（应该放到应用层后台任务）
- WAL 关闭（默认开，除非明确需要）

## 相关 skill

- `xxf-database` — 上游抽象层
