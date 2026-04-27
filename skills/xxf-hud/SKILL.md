---
name: xxf-hud
description: XXFHud HUD / Loading / Toast 抽象层。当用户要展示 loading / toast / 进度条 / 错误提示，或询问"XXF 的 HUD 怎么用"时使用。具体平台实现见 xxf-hud-ios / xxf-hud-mac。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFHud

统一的 HUD / Loading / Toast 接口，底层按平台切换到 `XXFHudiOS` 或 `XXFHudMac`。

## 触发场景

- 请求中展示 loading
- 操作成功 / 失败 toast
- 下载进度条
- 统一的错误提示样式

## 工作流

1. 读源码确认接口：
   ```
   Glob Sources/XXFHud/**/*.swift
   Grep "public|show|hide|loading|toast" in Sources/XXFHud/
   ```
2. 业务层**只调 `XXFHud` 接口**，不直接用 `XXFHudiOS` / `Mac`
3. 样式定制走主题 / 配置入口（以源码为准）

## 交互约定

- Loading：默认遮罩 + 菊花，长时间（>3s）加文案
- Toast：顶部或底部，2s 后自动消失
- 错误：区分可恢复 vs 致命，致命用 Alert，不用 Toast

## 反模式

- ViewController 里 `UIAlertController` + Toast + loading 三种风格混用
- 在后台线程调 `show`（主线程）
- 多次叠加显示（需去重）

## 相关 skill

- `xxf-hud-ios` — iOS 实现
- `xxf-hud-mac` — macOS 实现
