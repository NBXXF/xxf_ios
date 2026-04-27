---
name: xxf-extensions
description: XXFExtensions 对系统类型的便捷扩展集合。当用户要用 XXF 提供的 String / Array / Date / UIView / UIColor 等扩展方法，或询问"XXF 给系统类型加了什么"时使用。
allowed-tools: Read, Glob, Grep
---

# XXFExtensions

对 Foundation / UIKit / AppKit 类型的扩展集合，减少业务重复造轮子。

## 触发场景

- 查某个 Apple 类型在 XXF 里有没有现成扩展
- 写业务代码前检查"这功能 XXF 是不是已提供"
- 避免与 XXF 扩展冲突

## 工作流

1. 读源码按类型查：
   ```
   Glob Sources/XXFExtensions/**/*.swift
   Grep "extension String|extension Array|extension UIView" in Sources/XXFExtensions/
   ```
2. 复用现成方法，**不要在业务层重写同名扩展**
3. 如需新增：先评估是否足够通用（否则应留在业务层）

## 反模式

- 业务层写与 `XXFExtensions` 命名冲突的扩展（运行时二义性）
- 把业务专属逻辑（如带 token 的请求封装）塞进 `XXFExtensions`

## 相关 skill

- 基础类型定义见 `xxf-foundation`
