---
name: xxf-event-reporter-firebase
description: XXFEventReporterFirebase（XXFEventReporter 的 Firebase 实现）。当用户要把原子事件上报到 Firebase 时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFEventReporterFirebase

Firebase 作为 XXFEventReporter 的底层通道。

## 触发场景

- 选 Firebase 做原子事件上报
- 与 XXFTrackerFirebase 共存时的分工

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFEventReporterFirebase/**/*.swift
   Grep "public|Firebase" in Sources/XXFEventReporterFirebase/
   ```
2. 注册为 XXFEventReporter Provider
3. 与 `xxf-tracker-firebase` 分工：Tracker 走业务语义事件，EventReporter 走底层原子事件

## 反模式

- 两个 Provider 都上报同一事件（重复计数）
- 事件名前缀与 Tracker 冲突

## 相关 skill

- `xxf-event-reporter` — 抽象层
- `xxf-tracker-firebase` — 上层业务埋点
