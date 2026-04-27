---
name: xxf-hud-ios
description: XXFHudiOS（XXFHud 的 iOS 实现）。当用户要定制 iOS 侧 HUD 样式、动画、遮罩效果时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFHudiOS

XXFHud 的 iOS 平台实现。业务层一般**不直接用**，除非做平台特定样式定制。

## 触发场景

- 定制 iOS HUD 主题 / 颜色 / 字体
- 改 loading 菊花样式 / 动画
- 手动注册为 XXFHud 的 Provider

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFHudiOS/**/*.swift
   Grep "public|theme|style" in Sources/XXFHudiOS/
   ```
2. 通过配置入口定制，不要改源码
3. 注册为 `XXFHud` Provider（以源码为准）

## 反模式

- 业务 VC 直接 import `XXFHudiOS`（破坏 `XXFHud` 抽象）
- 改 HUD 动画到不可读（>500ms 的渐入渐出）

## 相关 skill

- `xxf-hud` — 接口层
- `xxf-hud-mac` — macOS 版本
