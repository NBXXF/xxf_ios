---
name: xxf-aaa-quickstart
description: XXF iOS 框架接入与模块选型助手。当用户说"新项目想用 XXF"、"怎么集成 XXF iOS"、"应该引入哪些模块"、"XXFArch 和单模块怎么选"、"最低系统版本要求"时使用。
allowed-tools: Read, Glob, Grep, Bash
---

# XXF iOS 接入助手

## 触发场景

- 从零开始集成 XXF iOS
- 在已有项目中决定引入哪些模块
- 回答"XXF 怎么开始用"类问题

## 工作流

### 1. 环境检查

```bash
swift --version     # 要求 ≥ 6.0
xcodebuild -version # 要求 iOS 15+ / macOS 13+
```

如低于要求，**停止并告知用户升级**，不要强行集成。

### 2. 收集需求（必问）

以 AskUserQuestion 方式问清以下问题，**禁止代用户决定**：

- 用途：业务 App / SDK / Demo？
- 已有架构：有无网络层、路由、数据库？若有，是否打算替换？
- 核心诉求：只要网络？要完整基础设施？
- 平台：iOS-only 还是需要 macOS 兼容？

### 3. 模块选型建议

根据需求推荐，**不要一把 `XXFArch` 梭哈**：

| 需求 | 推荐模块 | 备注 |
|:------|:------|:------|
| 只要网络 | `XXFHttp` + `XXFFoundation` | 最小集成 |
| 网络 + 响应式 | 加 `XXFFlow` | 替代 RxSwift |
| 加持久化 | 加 `XXFDatabase` + 选一个实现 | GRDB 或 ObjectBox |
| 加缓存 | 加 `XXFCache`（+ `XXFCacheMMKV` 若 Swift 6.2+） | MMKV 需更高 Swift 版本 |
| 全家桶 | `XXFArch` | 体积大，Demo / 内部工具可用 |

### 4. Package.swift 片段生成

仅示范结构，实际依赖版本让用户自己查 `git tag`：

```swift
dependencies: [
    .package(url: "https://github.com/NBXXF/xxf_ios.git", from: "<version>")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "XXFHttp", package: "xxf_ios"),
            .product(name: "XXFFlow", package: "xxf_ios"),
        ]
    )
]
```

### 5. 验证集成

让用户执行：

```bash
swift build 2>&1 | tail -20
```

若失败，路由到 `xxf-aaa-troubleshooting`。

## 约束

- **不要修改**用户项目中与 XXF 无关的文件。
- 模块列表以 `Sources/` 为准，可用 `Glob` 查看：`Sources/XXF*`。
- Provider 类模块（如 `XXFImageEditorBrightroom`）必须和基础模块（`XXFImageEditor`）一起引入。

## 相关模块关系

```
XXFFoundation  ← 几乎所有模块的基础
    ↓
XXFHttp / XXFFlow / XXFCache / XXFBus / XXFLog  ← 业务常用
    ↓
XXFDatabase → XXFDatabaseGrdb / XXFDatabaseObjectBox  ← 选一个实现
XXFImageEditor → XXFImageEditorBrightroom              ← Provider 模式
XXFTracker → XXFTrackerSentry / Firebase / Bugsnag     ← 埋点选型
XXFHud → XXFHudiOS / XXFHudMac                          ← 平台选型
```
