---
name: xxf-database
description: XXFDatabase 持久化抽象层（接口规范）。当用户要定义 Repository 协议、设计 Model、规划分层、或询问"数据层怎么抽象"时使用。具体 ORM 实现见 xxf-database-grdb / xxf-database-objectbox。若属于普通编码任务中的实现环节，应先经过 `xxf-aaa-delivery-loop` 再落到本 skill。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFDatabase 持久化抽象层

**本 skill 只讲抽象层 / 接口规范。具体 ORM 操作见 `xxf-database-grdb` / `xxf-database-objectbox`。**

## 触发场景

- 设计 Repository 协议
- 规划数据层分层
- 定义 Model 结构
- ORM 选型（但具体用法不在此 skill）

## 选型决策（**必问用户**）

| 维度 | GRDB (SQLite) | ObjectBox |
|:------|:------|:------|
| 查询能力 | SQL 全功能 | 对象查询，复杂查询受限 |
| 性能 | 中等 | 高（批量写入） |
| 迁移 | 手写 SQL migration | 框架自动 |
| 学习成本 | 低 | 中 |
| 包体积 | 小 | 较大 |

**规则**：复杂 join / 聚合 → GRDB；数据量大写入密集 → ObjectBox；不确定 → GRDB。

选完后路由到 `xxf-database-grdb` 或 `xxf-database-objectbox` 继续。

## 分层（**强制**）

```
DomainLayer         ← 只认 Repository 协议
    ↑
RepositoryLayer     ← Protocol + Impl
    ↑
DatabaseLayer       ← XXFDatabase + GRDB / ObjectBox
```

业务**只依赖 Repository 协议**，不 import ORM。

## Model 设计约定

- 字段用 `let`
- 时间戳用 `Date` 或 `Int64`（与现有风格一致，先 Grep）
- 枚举映射 `rawValue: String`（不用 Int，改动不易出错）
- `id` 用 `UUID` 或雪花 ID，不用自增（便于离线同步）

## 工作流

1. 读源码定抽象：
   ```
   Glob Sources/XXFDatabase/**/*.swift
   Grep "public protocol|Repository" in Sources/XXFDatabase/
   ```
2. 根据业务场景设计 `XxxRepositoryProtocol`
3. 交给对应 ORM skill 写 Impl

## 反模式

- Repository 接口暴露 ORM 类型（如 `GRDB.Row`）
- Model 字段 `Any` / `AnyCodable` 绕过类型系统
- 跳过接口层直接让 ViewModel 依赖 GRDB

## 相关 skill

- `xxf-database-grdb` — GRDB 具体用法
- `xxf-database-objectbox` — ObjectBox 具体用法
- `xxf-cache` — KV 场景（不需要关系型表）
