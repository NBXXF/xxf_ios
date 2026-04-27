---
name: xxf-speed
description: XXFSpeed 速率限制 / 防抖 / 节流（推测，以源码为准）。当用户要限频、去抖、节流，或询问 XXFSpeed 是什么时使用；先读源码确认职责。
allowed-tools: Read, Glob, Grep
---

# XXFSpeed

**职责以源码为准**。可能是：
- 限流 / 节流（`throttle`）
- 防抖（`debounce`）
- 网络速率统计
- 帧率 / 性能相关

## 工作流

**第一步必做**：读源码。

```
Glob Sources/XXFSpeed/**/*.swift
Grep "public|throttle|debounce|rate" in Sources/XXFSpeed/
```

## 常见触发场景（假设是限流 / 防抖）

- 搜索框输入防抖
- 按钮点击节流
- 请求限频

## 反模式

- 未读源码就按名字猜测用法
- 搜索防抖直接用 `XXFSpeed` 而不是 `xxf-flow` 的 `debounce`（应先用 Flow 自带的）

## 相关 skill

- `xxf-flow` — 响应式的 throttle / debounce 操作符
- `xxf-performance` — 性能相关
