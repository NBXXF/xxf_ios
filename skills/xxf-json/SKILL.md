---
name: xxf-json
description: XXFJson JSON 解析 / 序列化工具。当用户要处理 JSON、Codable 辅助、动态键、兼容字段，或询问"XXF 的 JSON 工具"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFJson

JSON 解析 / 序列化的通用工具，对 Swift Codable 的增强。

## 触发场景

- 字段名与接口不一致（驼峰 / 下划线）
- 字段类型宽容（服务端时返回 `"1"`，时而返回 `1`）
- 动态 key / 嵌套路径取值
- JSON 片段原样保留（不解析）

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFJson/**/*.swift
   Grep "public|decode|encode|Codable" in Sources/XXFJson/
   ```
2. 业务 Model 优先用 Codable，再用 XXFJson 做辅助
3. 兼容字段集中处理，不要每个 Model 各写各的

## 反模式

- 手写大量 `init(from decoder:)` 套路代码
- 用 `Any` / `[String: Any]` 到处传（失去类型）
- JSON 解析错误吞掉（应冒泡 + 日志）

## 相关 skill

- `xxf-http` — 请求 / 响应解析
