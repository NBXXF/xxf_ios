---
name: xxf-tracker
description: XXFTracker 埋点抽象层（用户行为埋点）。当用户要做行为埋点、页面曝光、点击事件，或询问"XXF 怎么做埋点"时使用。具体实现见 xxf-tracker-firebase / sentry / bugsnag。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFTracker

行为埋点抽象层。统一事件名 / 参数 schema，底层多路分发到 Firebase / Sentry / Bugsnag 等。

## 触发场景

- 页面曝光 / 停留时长
- 按钮点击 / 自定义事件
- 崩溃 / 异常上报
- 用户属性 / 用户 ID

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFTracker/**/*.swift
   Grep "public|Tracker|event|log" in Sources/XXFTracker/
   ```
2. 定义事件常量（集中管理，如 `Events/LoginEvents.swift`）
3. 启动期注册具体 Provider（`xxf-tracker-firebase` / `-sentry` / `-bugsnag`）
4. 业务只调抽象接口

## 事件约定

- 命名：`snake_case`，分类前缀（`login_success`、`order_pay_click`）
- 参数：扁平 dict，value 只用基础类型
- 事件常量集中声明，**不要写魔法字符串**
- PII（手机号、姓名、邮箱）**不要**作为埋点参数

## 反模式

- 每个 VC 自己 `import Firebase`
- 埋点里塞 token / 敏感字段
- 同一事件多个 Provider 重复发（去重交给抽象层）

## 相关 skill

- `xxf-tracker-firebase` / `xxf-tracker-sentry` / `xxf-tracker-bugsnag` — Provider
- `xxf-event-reporter` — 原子事件上报（更底层）
- `xxf-performance` — 性能事件
