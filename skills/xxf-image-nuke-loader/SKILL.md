---
name: xxf-image-nuke-loader
description: XXFImageNukeLoader（XXFImageLoader 的 Nuke 实现）。当用户要使用 / 定制 Nuke 作为图片加载后端，或询问"XXF 默认图片加载实现"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFImageNukeLoader

[Nuke](https://github.com/kean/Nuke) 在 XXFImageLoader 体系下的 Provider 实现。

## 触发场景

- 已引入 `XXFImageLoader`，选 Nuke 作为后端
- 定制 Nuke 的 `ImagePipeline` / 缓存策略
- 调优图片解码 / 预加载

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFImageNukeLoader/**/*.swift
   Grep "public|Nuke|ImagePipeline" in Sources/XXFImageNukeLoader/
   ```
2. 启动期注册为 XXFImageLoader Provider
3. 定制 pipeline（内存 / 磁盘缓存大小、压缩质量）

## 反模式

- 业务层 `import Nuke` 直接调（破坏抽象）
- 不限内存缓存上限（大图场景易爆）
- Prefetch 开得过猛，浪费流量

## 相关 skill

- `xxf-image-loader` — 抽象层
