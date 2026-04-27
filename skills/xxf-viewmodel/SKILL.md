---
name: xxf-viewmodel
description: XXFViewModel MVVM 的 VM 基类与生命周期。当用户要写 ViewModel、绑定 View、处理输入输出流，或询问"XXF 的 MVVM 怎么用"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFViewModel

MVVM 的 ViewModel 基类，管理生命周期、状态、输入输出。

## 触发场景

- 新建一个页面的 ViewModel
- VM 与 View 的绑定模式
- VM 的依赖注入（配合 `xxf-di`）

## 架构约定

```
View / VC (thin)
    ↕ bind (通过 XXFFlow)
ViewModel (hold state, expose outputs)
    ↕ 调用
Repository / Service
```

- VM **不持有** View（避免循环引用）
- VM 输入：Action / Intent；输出：State / Event
- VM 构造期注入依赖，不在内部 `new`

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFViewModel/**/*.swift
   Grep "public|ViewModel" in Sources/XXFViewModel/
   ```
2. 继承 / 遵守 VM 基类
3. 用 Flow 暴露 outputs，VC 订阅

## 反模式

- VM 里 `import UIKit` 做 UI 决策（UI 决策留给 View）
- VM 单例化（除非真的是全局状态）
- 业务逻辑写在 VC，VM 只做转发

## 相关 skill

- `xxf-flow` — 输入输出流
- `xxf-di` — 依赖注入
- `xxf-datasource` — 列表数据源
