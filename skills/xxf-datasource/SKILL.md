---
name: xxf-datasource
description: XXFDataSource 列表 / 分页数据源抽象。当用户要做分页列表、数据源驱动 UI、多数据源合并，或询问"XXF 列表数据源怎么设计"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFDataSource

列表数据源抽象，统一分页、加载态、空态、错误态。

## 触发场景

- 分页列表业务
- 多数据源合并（缓存 + 网络 + 推送）
- 列表 UI 与数据解耦

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFDataSource/**/*.swift
   Grep "public|DataSource|Page" in Sources/XXFDataSource/
   ```
2. 按业务定义数据源（通常泛型化 `DataSource<Item>`）
3. ViewModel 持有数据源，VC 订阅变化

## 典型场景

- **分页**：每次拉下一页追加
- **增量**：Bus 推送的新条目插到顶部
- **缓存优先**：先吐本地 → 再拉网络覆盖
- **跨数据源合并**：多个 Repository 输出合并去重

## 反模式

- VC 直接持 `[Item]` 数组，手动管分页 / 去重 / 合并
- 数据源内部起 UI 副作用（刷新 UI 是订阅方的事）
- 分页状态散落（用 `XXFRefreshable` 的状态机）

## 相关 skill

- `xxf-refreshable` — 刷新状态
- `xxf-flow` — 订阅机制
- `xxf-viewmodel` — 持有方
