---
name: xxf-tracker-bugsnag
description: XXFTrackerBugsnag（XXFTracker 的 Bugsnag 实现）。当用户要接 Bugsnag 做错误监控时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFTrackerBugsnag

Bugsnag 在 XXFTracker 体系下的 Provider。

## 触发场景

- 选 Bugsnag 做错误 / 崩溃监控
- 与 Sentry / Firebase 并存时指定路由

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFTrackerBugsnag/**/*.swift
   Grep "public|Bugsnag" in Sources/XXFTrackerBugsnag/
   ```
2. 业务方自备 API Key（不进仓库）
3. 启动期注册为 XXFTracker Provider

## 反模式

- API Key 硬编码
- 未脱敏的上下文上报

## 相关 skill

- `xxf-tracker` — 抽象层
