---
name: xxf-foundation
description: XXFFoundation 基础设施工具。当用户需要基础扩展类型、公共协议、全局常量、线程工具、集合辅助等底层能力时使用，或询问"XXFFoundation 提供了什么"。
allowed-tools: Read, Glob, Grep
---

# XXFFoundation

几乎所有 XXF 模块的依赖基石，包含底层协议、类型别名、通用工具。

## 触发场景

- 定位某个公共协议 / 类型属于哪个模块
- 业务层想扩展 XXF 的基础 API
- 其他 skill 的工作流引用到 "基础类型" 时

## 工作流

1. 读源码定范围：
   ```
   Glob Sources/XXFFoundation/**/*.swift
   Grep "public protocol|public typealias|public enum" in Sources/XXFFoundation/
   ```
2. 定位具体类型所在文件
3. 引用时**只 import 需要的**，避免把 `XXFFoundation` 当成"万能工具袋"

## 反模式

- 业务侧大量 `import XXFFoundation` 绕过其他模块的公共 API
- 在 `XXFFoundation` 里加业务特定的常量 / 工具（应该留在业务层）

## 相关 skill

- 更上层的 `xxf-http` / `xxf-flow` / `xxf-cache` 等都基于此
