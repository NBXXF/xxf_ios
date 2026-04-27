---
name: xxf-image-loader
description: XXFImageLoader 图片加载抽象层。当用户要做网络图片加载、占位符、失败重试、磁盘/内存缓存，或询问"XXF 图片加载怎么用"时使用。具体实现见 xxf-image-nuke-loader。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFImageLoader

图片加载抽象层。业务层**只依赖协议**，底层可切换 Nuke / SDWebImage / Kingfisher 等。

## 触发场景

- `imageView.xxf_load(url:)` 类语法
- 占位符 / 错误图 / 淡入动画
- 磁盘 + 内存缓存
- 图片处理链（圆角、模糊、尺寸）

## 工作流

1. 读源码确认接口：
   ```
   Glob Sources/XXFImageLoader/**/*.swift
   Grep "public|ImageLoader" in Sources/XXFImageLoader/
   ```
2. 业务层**只用抽象**，不 import 具体实现
3. 启动期注册 Provider（如 `XXFImageNukeLoader`）

## 约定

- URL 相同的图片 **不要** 写业务层缓存，Provider 已做
- 列表 Cell 复用时取消旧加载（Provider 通常自动，但复杂 Cell 需手动）
- 优先用内置的圆角 / 尺寸处理，而非加载完再 `UIImage` 二次处理（浪费内存）

## 反模式

- 直接 import Nuke 跳过抽象
- 每张图都 force download（破坏缓存）
- 加载超大图不降采样

## 相关 skill

- `xxf-image-nuke-loader` — 默认实现
- `xxf-compress` — 本地压缩
