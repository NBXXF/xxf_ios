---
name: xxf-image-editor-brightroom
description: XXFImageEditorBrightroom（XXFImageEditor 的 Brightroom 实现）。当用户要用 / 定制 Brightroom 作为图片编辑器后端时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFImageEditorBrightroom

[Brightroom](https://github.com/FluidGroup/Brightroom) 在 XXFImageEditor 体系下的 Provider。

## 触发场景

- 选 Brightroom 做默认编辑器
- 自定义 Brightroom 滤镜 / 裁剪比例 / 工具栏

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFImageEditorBrightroom/**/*.swift
   Grep "public|Brightroom" in Sources/XXFImageEditorBrightroom/
   ```
2. 启动期注册为 XXFImageEditor Provider
3. 定制 UI 选项（遵循 XXF 封装，不直接操作 Brightroom 类型）

## 反模式

- 业务层 `import BrightroomUI` 直接调
- 未经压缩就输出编辑后高清图

## 相关 skill

- `xxf-image-editor` — 抽象层
