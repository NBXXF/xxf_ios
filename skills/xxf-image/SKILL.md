---
name: xxf-image
description: XXFImage 图片通用能力（基础抽象）。当用户要处理图片加载、显示、格式转换、占位符等通用场景时使用。具体加载 / 编辑 / 选择分别走对应子 skill。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFImage

图片模块的基础抽象层，定义图片加载 / 编辑 / 选择 / 压缩的通用协议。

## 触发场景

- 图片相关的入口决策（"我到底该用哪个 XXFImage* 模块"）
- 统一的图片数据结构（XXF 可能有自己的 Image 类型）

## 路由到具体实现

| 场景 | 走 |
|:------|:------|
| 网络图片加载 / 占位符 / 缓存 | `xxf-image-loader` |
| 用户裁剪 / 滤镜 / 编辑 | `xxf-image-editor` |
| 相册 / 拍照选图 | `xxf-photo-picker` |
| 压缩（体积、质量） | `xxf-compress` |

## 工作流

1. 读源码了解基础类型：
   ```
   Glob Sources/XXFImage/**/*.swift
   Grep "public|protocol" in Sources/XXFImage/
   ```
2. 业务层**尽量**用抽象类型而非具体实现，便于切换

## 反模式

- 直接用 `UIImage` 裸传，跳过 XXFImage 的抽象
- 多个图片模块混用（加载走 A、压缩走 B、编辑走 C 不协调）
