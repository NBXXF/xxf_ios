---
name: xxf-hud-mac
description: XXFHudMac（XXFHud 的 macOS 实现）。当用户要定制 macOS 侧 HUD 样式、注册 macOS Provider 时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFHudMac

XXFHud 的 macOS 平台实现。

## 触发场景

- macOS App 的 HUD 定制
- 注册为 XXFHud macOS Provider

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFHudMac/**/*.swift
   Grep "public" in Sources/XXFHudMac/
   ```
2. 通过配置入口定制，不要改源码

## 反模式

- 业务代码直接 import `XXFHudMac`
- 复用 iOS HUD 视觉（macOS 有独立 HIG）

## 相关 skill

- `xxf-hud` — 接口层
- `xxf-hud-ios` — iOS 版本
- `xxf-appkit` — macOS UI 层
