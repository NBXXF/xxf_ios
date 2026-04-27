---
name: xxf-appkit
description: XXFAppkit 对 AppKit（macOS）的增强封装。当用户要写 macOS 原生 UI、共享部分 iOS 逻辑，或询问"XXF macOS 侧 UI 能力"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFAppkit

XXFUIKit 的 macOS 对应物（基于 AppKit），iOS / macOS 跨平台时 UI 层的 macOS 分支。

## 触发场景

- macOS 侧 UI 封装
- iOS / macOS 共用 ViewModel，UI 层分平台
- Mac Catalyst 和 AppKit 的选择

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFAppkit/**/*.swift
   Grep "public" in Sources/XXFAppkit/
   ```
2. iOS 逻辑不要直接拷到 macOS，通过协议 / 公共 ViewModel 复用

## 反模式

- 用 `#if os(iOS)` 在 `XXFUIKit` 里塞 macOS 代码（应进 `XXFAppkit`）
- macOS 版本强行复用 iOS 的自适应方案

## 相关 skill

- `xxf-uikit` — iOS 对应物
- `xxf-hud-mac` — HUD 的 macOS 实现
