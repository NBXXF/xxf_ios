---
name: xxf-tracker-sentry
description: XXFTrackerSentry（XXFTracker 的 Sentry 实现）。当用户要接 Sentry 做错误 / 崩溃监控时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFTrackerSentry

Sentry 在 XXFTracker 体系下的 Provider，擅长崩溃 / 异常 / 性能追踪。

## 触发场景

- 崩溃 / 错误自动上报
- Release / Debug 模式区分
- 用户 session 追踪

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFTrackerSentry/**/*.swift
   Grep "public|Sentry" in Sources/XXFTrackerSentry/
   ```
2. 业务方自备 DSN（不在仓库里）
3. 启动期注册为 XXFTracker Provider

## 反模式

- DSN 硬编码在代码里（应走环境变量 / 配置文件）
- 上报堆栈含 PII（先脱敏）
- Debug 模式也上报（污染生产数据）

## 相关 skill

- `xxf-tracker` — 抽象层
