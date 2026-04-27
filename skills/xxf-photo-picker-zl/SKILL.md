---
name: xxf-photo-picker-zl
description: XXFPhotoPickerZl（XXFPhotoPicker 的 ZLPhotoBrowser 实现）。当用户要用 ZLPhotoBrowser 作为选图后端时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFPhotoPickerZl

[ZLPhotoBrowser](https://github.com/longitachi/ZLPhotoBrowser) 在 XXFPhotoPicker 体系下的 Provider。

## 触发场景

- 选定 ZL 作为 picker 后端
- 定制 ZL 的 UI 样式、多选行为

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFPhotoPickerZl/**/*.swift
   Grep "public|ZL" in Sources/XXFPhotoPickerZl/
   ```
2. 启动期注册为 XXFPhotoPicker Provider
3. 定制：主题色 / 多选上限 / 编辑入口

## 反模式

- 业务层 `import ZLPhotoBrowser` 跳过抽象
- 同时注册多个 picker Provider 导致冲突

## 相关 skill

- `xxf-photo-picker` — 抽象层
