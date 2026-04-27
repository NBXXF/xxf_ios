---
name: xxf-image-editor
description: XXFImageEditor 图片编辑抽象层（裁剪 / 滤镜 / 涂鸦）。当用户要做图片裁剪、滤镜、涂鸦、文字叠加，或询问"XXF 图片编辑器"时使用。具体实现见 xxf-image-editor-brightroom。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFImageEditor

图片编辑抽象层，底层可切换 Brightroom 或其他实现。

## 触发场景

- 用户上传头像前裁剪
- 帖子图片编辑（滤镜、涂鸦、文字）
- 图片水印 / 马赛克

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFImageEditor/**/*.swift
   Grep "public|Editor|protocol" in Sources/XXFImageEditor/
   ```
2. 业务层调抽象接口（`present(image, options)` 风格，以源码为准）
3. 启动期注册具体 Provider（`xxf-image-editor-brightroom`）

## 反模式

- 直接 import 具体实现（破坏解耦）
- 编辑后的高清原图直接上传（先 `xxf-compress`）
- 编辑中间态存内存（大图容易爆，应临时文件）

## 相关 skill

- `xxf-image-editor-brightroom` — 默认实现
- `xxf-compress` — 编辑后压缩
- `xxf-photo-picker` — 选图入口
