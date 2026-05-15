---
name: xxf-observability
description: 建立可观测性规范，统一日志字段、埋点命名、错误码、性能指标与告警阈值，提升排障效率与数据一致性。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# 可观测性技能

## 目标

- 日志、埋点、性能指标口径统一
- 跨模块可关联（traceId/requestId）
- 告警可执行（阈值 + owner）

## 统一字段建议

- traceId / module / action / result / costMs / errorCode

## 产物

- 事件字典
- 日志规范
- 告警规则

## 反模式

- 日志和埋点各自命名，无法关联。
- 只有采集，没有告警动作。
