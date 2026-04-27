---
name: xxf-refreshable
description: XXFRefreshable 下拉刷新 / 上拉加载。当用户要给列表加下拉刷新、分页加载、刷新状态机，或询问"XXF 怎么做下拉刷新"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFRefreshable

下拉刷新 + 上拉加载 + 刷新状态机 + 响应式集成。

## 触发场景

- 列表页下拉刷新
- 分页加载（上拉加更多）
- 刷新与错误态 / 空态的切换
- 与 XXFFlow 联动

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFRefreshable/**/*.swift
   Grep "public|refresh|Refreshable|state" in Sources/XXFRefreshable/
   ```
2. 定位刷新状态枚举 / Flow 输出
3. 业务层订阅状态变化，驱动 UI

## 状态机约束

典型：`idle → refreshing → success / error → idle`  
上拉加载：加 `loadingMore` / `noMore` 状态

- 每个 tick 一个明确状态，**禁止"半成品"过渡态**
- 用户重复下拉要去抖 / 防重入

## 反模式

- 自己管 `isRefreshing` / `hasMore` / `page` 三个布尔 + 整数（用框架状态机）
- 刷新完成不 `endRefreshing`（菊花转到天荒地老）
- 上拉触底不加防抖（短时间触发多次）

## 相关 skill

- `xxf-flow` — 响应式集成
- `xxf-reusable` — Cell 注册
- `xxf-datasource` — 列表数据源
