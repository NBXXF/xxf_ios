---
name: xxf-reusable
description: XXFReusable Cell / Header 自动注册与类型安全出队。当用户要写 TableView / CollectionView 的 Cell 注册、`dequeueReusableCell` 样板代码、或询问"XXF Cell 注册怎么用"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFReusable

对 UITableView / UICollectionView 的 Cell 注册 + 类型安全出队封装。

## 触发场景

- 写列表页前避免样板 register / dequeue 代码
- 消除魔法字符串 `reuseIdentifier`
- 类型安全的 Cell 泛型

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFReusable/**/*.swift
   Grep "public|Reusable|register|dequeue" in Sources/XXFReusable/
   ```
2. 让自定义 Cell 遵守 XXFReusable 的协议（以源码为准）
3. `dequeueReusable<Cell>(for: indexPath)` 直接返回具体类型

## 反模式

- 业务层仍手写 `register(CellType.self, forCellReuseIdentifier: "...")`
- 用魔法字符串当 identifier
- 同一 identifier 复用不同 Cell 类型

## 相关 skill

- `xxf-uikit` — 列表 / VC 基类
- `xxf-refreshable` — 下拉刷新
