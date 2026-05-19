---
name: xxf-arch
description: XXFArch 聚合模块。当用户想"一站式"引入所有 XXF 功能、做 Demo / 内部工具、或询问 XXFArch 和单模块引入的区别时使用。
allowed-tools: Read, Glob, Grep
---

# XXFArch

一站式聚合 target，依赖了几乎所有 XXF 模块。**适合 Demo 和内部工具，生产 App 慎用**。

## 触发场景

- 新建 Demo / POC / 内部调试 App
- 用户明确说"全都要"
- 纠结于模块列表时想先跑起来再细化

## 决策（**必须问用户**）

1. 产物用途：Demo / 内部工具 / 生产 App？
2. 对包体积敏感吗？（`XXFArch` 会把埋点 / 图片编辑 / ZL 相册等全部拉进来）
3. 能接受自动引入所有 Provider 的依赖吗？

**生产 App 默认建议按模块按需引入**，见 `xxf-aaa-quickstart`。

## 工作流

1. 读源码确认 `XXFArch` 当前依赖清单：
   ```
   Read Package.swift
   Grep "XXFArch" in Package.swift
   ```
2. 如用户坚持用，Package.swift 加：
   ```swift
   .product(name: "XXFArch", package: "xxf_ios")
   ```
3. 提醒用户：后续换成按需引入时，import 仍然兼容，但包体积会下降

## 反模式

- 生产 App 无脑 `XXFArch` 而不审视依赖
- 引入 `XXFArch` 又同时单独引入子模块（冗余）

## 相关 skill

- `xxf-aaa-quickstart` — 模块选型决策树
