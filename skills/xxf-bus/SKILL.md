---
name: xxf-bus
description: XXFBus 事件总线（RxBus 风格）。当用户要做跨模块事件广播、发布订阅、解耦通信，或询问"XXF 怎么做通知中心替代"、"RxBus 用法"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFBus

类型安全的事件总线，替代 `NotificationCenter` 在模块间做松耦合通信。

## 触发场景

- 跨 VC / 跨模块事件（登录成功、主题切换、购物车变化）
- 替换散落的 `NotificationCenter` 通知
- 解耦发送方与订阅方

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFBus/**/*.swift
   Grep "public|post|subscribe|BusEvent" in Sources/XXFBus/
   ```
2. 定义事件类型（推荐 `struct` 或 `enum`，禁止 `Any`）
3. 订阅时绑定生命周期（DisposeBag / 等价容器）
4. 发布方**不关心有谁订阅**

## 事件命名

- 结构化类型，禁止魔法字符串
- 集中声明，如 `App/Events/AuthEvents.swift`
- 粒度：一个事件 = 一个业务语义，不要"万能事件"

## 反模式

- 事件 payload 里塞整个 Model（只传 ID，拿到后自己查）
- 订阅者修改 payload 后重新发（易死循环）
- 在事件回调里同步做 IO（阻塞发布方）

## 相关 skill

- `xxf-flow` — Bus 本质上返回 Flow，订阅 / 释放语义一致
