---
name: xxf-module-scaffold
description: 为 XXF iOS 框架本身新增一个模块（面向框架维护者，不是业务方）。当用户说"给 XXF 加个新模块"、"贡献代码到 xxf_ios"、"新建 XXFXxx target"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# XXF 模块脚手架

**适用对象**：XXF 框架维护者 / Contributor。  
**不适用**：业务方。业务方请使用其他 `xxf-*` skill。

## 触发场景

- 往 `xxf_ios` 仓库新增一个模块（如 `XXFAnalyticsFoo`）
- 把现有模块拆分成主模块 + Provider 实现
- 为已有模块增加平台变体（如 macOS 版）

## 工作流

### 1. 确认选型（**必问**）

- 模块类型：独立（如 `XXFLog`）/ 可替换实现（如 `XXFImageEditorBrightroom`）/ 平台变体（如 `XXFHudiOS`）？
- 是否依赖第三方库？
- 最低 Swift 版本要求？（可能需要条件编译，参考 `XXFCacheMMKV` 的 `#if swift(>=6.2)`）

### 2. 命名

- 前缀：必须 `XXF`
- 功能词：`PascalCase`，如 `XXFAnalytics`
- 实现后缀：对外库名，如 `XXFAnalyticsFirebase`、`XXFImageEditorBrightroom`
- 平台后缀：`iOS` / `Mac`，如 `XXFHudiOS`

### 3. 目录结构

```
Sources/XXFAnalytics/
├── XXFAnalytics.swift           # 公共入口 / namespace
├── Protocols/
│   └── AnalyticsProvider.swift  # 对外协议
├── Models/
│   └── AnalyticsEvent.swift
└── Impl/
    └── DefaultAnalyticsImpl.swift
```

测试目录：

```
Tests/XXFAnalyticsTests/
└── XXFAnalyticsTests.swift
```

### 4. 修改 Package.swift

**步骤**：

1. 读 `Package.swift` 理解现有约定
2. 在 `products` 中加 `.library(name: "XXFAnalytics", targets: ["XXFAnalytics"])`
3. 在 `targets` 中加 `.target` 和 `.testTarget`
4. 如依赖第三方库，加到 `dependencies`
5. 如有条件编译（Swift 版本），参考 `mmkvProducts` / `mmkvDependencies` / `mmkvTargets` 的三段式模板

**不要**：
- 把新模块塞进 `XXFArch` 而不更新文档
- 绕过 Package.swift 的条件编译保护

### 5. 聚合到 XXFArch（可选）

如果模块是"基础设施级"（业务方大概率都需要），加入 `XXFArch` 的依赖。否则保持独立。

判断标准：**这个模块是否会让 XXFArch 膨胀超过 10%？** 是则不加。

### 6. 验证

```bash
swift build --target XXFAnalytics
swift test --filter XXFAnalyticsTests
```

### 7. 文档

- 更新仓库根 `README.md` 的模块清单
- 如果业务侧有使用范式，**同步更新 `skills/`**，或新增一个 `xxf-<module>` skill

## 反模式

- 在主模块 `XXFAnalytics` 里 hard-code 第三方实现
- 把实现代码塞进 `Impl/` 还同时 `import Firebase`（应拆成 `XXFAnalyticsFirebase` 独立 target）
- 跨模块循环依赖
