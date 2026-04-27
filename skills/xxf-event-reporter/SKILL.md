---
name: xxf-event-reporter
description: XXFEventReporter 原子事件上报层（比 Tracker 更底层）。当用户要做通用事件上报、自定义上报通道，或询问"XXFEventReporter 与 XXFTracker 区别"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFEventReporter

更底层的原子事件上报通道。`XXFTracker` 面向业务埋点语义（曝光 / 点击 / 崩溃），`XXFEventReporter` 面向通用事件传输（任何 key-value 事件都能发）。

## 何时用它而不是 XXFTracker

| 场景 | 选 |
|:------|:------|
| 业务行为埋点（曝光、点击） | `xxf-tracker` |
| 性能 / 诊断 / 网络原始事件 | `xxf-event-reporter` |
| 自定义上报通道（如自研后台） | `xxf-event-reporter` |

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFEventReporter/**/*.swift
   Grep "public|EventReporter|report" in Sources/XXFEventReporter/
   ```
2. 注册 Provider（如 `xxf-event-reporter-firebase`）
3. 上报时**结构化 schema**

## 反模式

- 把它当日志写（用 `xxf-log`）
- 高频事件不采样（流量爆炸）

## 相关 skill

- `xxf-tracker` — 上层业务埋点
- `xxf-event-reporter-firebase` — Firebase 实现
