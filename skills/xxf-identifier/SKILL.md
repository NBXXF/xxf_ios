---
name: xxf-identifier
description: XXFIdentifier 唯一 ID 生成（UUID / 雪花 ID / 设备 ID）。当用户要生成对象 ID、离线同步 ID、跨设备唯一标识时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFIdentifier

唯一标识生成工具。

## 触发场景

- 数据库主键（离线可生成，不依赖后端）
- 事件 ID（埋点去重）
- 设备 ID（跨卸载保留，配合 `xxf-keychain`）

## 选型

| 场景 | 选 |
|:------|:------|
| 本地唯一即可 | `UUID` |
| 需要有序（按时间排序） | 雪花 ID |
| 跨设备跨卸载唯一 | 设备 ID + Keychain |

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFIdentifier/**/*.swift
   Grep "public|Identifier|UUID|Snowflake" in Sources/XXFIdentifier/
   ```
2. 按场景选 API

## 反模式

- 用自增 Int 做跨端 ID（离线同步冲突）
- UUID v4 作为数据库主键还做范围查询（随机分布，索引差）
- 设备 ID 存 UserDefaults（卸载即丢）

## 相关 skill

- `xxf-keychain` — 设备 ID 持久化
- `xxf-database` — 主键设计
