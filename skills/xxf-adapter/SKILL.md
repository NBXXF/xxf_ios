---
name: xxf-adapter
description: XXFAdapter 适配器模式基座。当用户要在可替换实现之间切换（如图片编辑器、HUD、Tracker 等 Provider），或询问 XXF 的适配器模式 / 协议注入机制时使用。
allowed-tools: Read, Glob, Grep
---

# XXFAdapter

XXF 统一的"可替换实现"机制。`XXFImageEditorBrightroom`、`XXFTrackerFirebase`、`XXFHudiOS` 等 Provider 都基于此规范。

## 触发场景

- 自定义一个 Provider（如接入新埋点 SDK）
- 在多个 Provider 之间切换或并存
- 读懂 XXF 源码里 `Adapter` / `Provider` 相关命名

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFAdapter/**/*.swift
   Grep "protocol|register|provider" in Sources/XXFAdapter/
   ```
2. 找到注册入口（启动期 vs 懒加载）
3. 实现目标协议 → 注册 → 业务层只依赖协议

## 反模式

- 业务代码直接 import 具体 Provider 实现（破坏解耦）
- 运行时切换 Provider 不清理旧实例（泄漏）

## 相关 skill

- `xxf-tracker` / `xxf-image-editor` / `xxf-hud` 等都是此模式的具体应用
