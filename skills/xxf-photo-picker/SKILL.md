---
name: xxf-photo-picker
description: XXFPhotoPicker 图片 / 视频选择器抽象层。当用户要让用户从相册选图、拍照、选视频，或询问"XXF 选图怎么做"时使用。具体实现见 xxf-photo-picker-zl。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFPhotoPicker

图片 / 视频选择器的抽象层，底层可切换系统原生或第三方（如 ZLPhotoBrowser）。

## 触发场景

- 发帖 / 聊天选图
- 头像拍照
- 视频选择 + 裁剪

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFPhotoPicker/**/*.swift
   Grep "public|Picker|protocol" in Sources/XXFPhotoPicker/
   ```
2. 业务层调抽象接口
3. 启动期注册 Provider（如 `xxf-photo-picker-zl`）

## 配置项

- 最大选择数
- 是否支持视频
- 是否支持拍照入口
- 是否裁剪

## 反模式

- 直接调用 `PHPickerViewController` 跳过 XXF 抽象
- 选完不做压缩直接上传
- 权限申请不提前做（picker 弹出就卡住）

## 相关 skill

- `xxf-photo-picker-zl` — ZL 实现
- `xxf-compress` — 选完压缩
- `xxf-image-editor` — 选完编辑
