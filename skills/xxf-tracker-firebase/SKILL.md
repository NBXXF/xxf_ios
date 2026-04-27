---
name: xxf-tracker-firebase
description: XXFTrackerFirebase（XXFTracker 的 Firebase Analytics 实现）。当用户要接 Firebase、上报行为事件到 Firebase 时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFTrackerFirebase

Firebase Analytics 在 XXFTracker 体系下的 Provider。

## 触发场景

- 产品要求用 Firebase 做数据分析
- GA4 / Firebase Console 查看事件

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFTrackerFirebase/**/*.swift
   Grep "public|Firebase|Analytics" in Sources/XXFTrackerFirebase/
   ```
2. 配置 `GoogleService-Info.plist`（业务方自备）
3. 启动期注册为 XXFTracker Provider

## 反模式

- 业务层直接 `Analytics.logEvent(...)`（破坏抽象）
- `GoogleService-Info.plist` 放进 git 仓库（含敏感信息，应进 `.gitignore`）
- 事件名超过 Firebase 限制（40 字符）

## 相关 skill

- `xxf-tracker` — 抽象层
