---
name: xxf-uikit
description: XXFUIKit 对 UIKit 的增强封装。当用户要用 XXF 提供的 View / Controller / 手势 / 布局工具（iOS 侧），或询问"XXFUIKit 有什么"时使用。若属于普通编码任务中的实现环节，应先经过 `xxf-aaa-delivery-loop` 再落到本 skill。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFUIKit

对 UIKit 的通用封装（仅 iOS），业务 UI 代码的基石。

## 触发场景

- 写自定义 View / VC 前查有无现成基类
- 手势、布局、转场的通用工具
- 跨业务复用的 UI 组件

## 工作流

1. 读源码按类别查：
   ```
   Glob Sources/XXFUIKit/**/*.swift
   Grep "public class|public struct" in Sources/XXFUIKit/
   ```
2. 复用已有基类，避免自建重复基类
3. 新增通用组件前评估是否足够通用（否则留业务层）

## 反模式

- 业务特定的 UI 塞进 `XXFUIKit`
- 与 `XXFExtensions` 的 UIView 扩展职责重叠

## 相关 skill

- `xxf-appkit` — macOS 对应物
- `xxf-extensions` — 类型级扩展
- `xxf-reusable` — Cell 注册
