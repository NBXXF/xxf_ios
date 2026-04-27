---
name: xxf-compress
description: XXFCompress 图片压缩（Luban 风格）。当用户要在上传前压缩图片、平衡质量与体积、批量压缩时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFCompress

基于 Luban 风格的智能图片压缩，兼顾质量与体积。

## 触发场景

- 上传图片前压缩
- 大图转发
- 批量处理相册导出

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFCompress/**/*.swift
   Grep "public|compress" in Sources/XXFCompress/
   ```
2. 选压缩策略：文件大小上限 / 像素上限 / 质量百分比
3. 异步执行（主线程压大图会卡）

## 常见参数（以源码为准）

- 最大边长（如 1920）
- 最大体积（如 1MB）
- 质量系数（0.0-1.0）
- 输出格式（JPEG / HEIC / PNG）

## 反模式

- 上传原图（流量 + 存储双浪费）
- 在主线程同步压缩
- 对小图也强压（反而变大 / 劣化）
- 压缩后忘了清临时文件

## 相关 skill

- `xxf-image-loader` — 加载
- `xxf-photo-picker` — 选图后压缩
- `xxf-http` — 上传
