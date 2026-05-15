# XXF iOS 企业级基础架构框架

<p align="center">
  <strong>一套功能完备、性能卓越、设计精良的 iOS/macOS 跨平台基础架构库</strong>
</p>

<p align="center">
  <em>"Write Less, Do More" — 让开发者专注业务逻辑，而非重复造轮子</em>
</p>

<p align="center">
  <a href="https://swift.org"><img src="https://img.shields.io/badge/Swift-6.0+-orange.svg" alt="Swift"></a>
  <a href="https://developer.apple.com"><img src="https://img.shields.io/badge/Platform-iOS%2015%2B%20%7C%20macOS%2013%2B-blue.svg" alt="Platform"></a>
  <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/SPM-Compatible-green.svg" alt="SPM"></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-lightgrey.svg" alt="License"></a>
  <img src="https://img.shields.io/badge/Modules-36+-purple.svg" alt="Modules">
</p>

---

## 为什么选择 XXF iOS？

### 痛点解决

| 传统开发痛点 | XXF iOS 解决方案 |
|-------------|-----------------|
| 每个项目重复封装网络层 | **XXFHttp** - 开箱即用，一行代码发起请求 |
| RxSwift 学习曲线陡峭 | **XXFFlow** - 64+ 简化操作符，降低使用门槛 |
| 线程切换代码冗长 | `subscribeOnIO().observeOnMain()` 两行搞定 |
| 数据库操作繁琐 | **Repository 模式** - CRUD 一行代码 |
| 日志散落各处难以追踪 | **XXFLog** - 统一管理 + Pulse 可视化 |
| 缓存实现不统一 | **@PreferenceWrapper** - 声明式存储 |
| 组件通信耦合严重 | **RxBus** - 类型安全的事件总线 |
| 性能问题难以定位 | **XXFPerformance** - 主线程卡顿检测 + FPS/CPU/内存实时监控悬浮窗 |
| 页面跳转逻辑混乱 | **XXFRouter** - 企业级路由框架，拦截器+降级 |
| Cell 注册繁琐易错 | **XXFReusable** - 自动注册，类型安全出队 |
| 下拉刷新状态混乱 | **XXFRefreshable** - 状态机+RxSwift 集成 |
| AI 流式响应难处理 | **SSE 支持** - 标准 Server-Sent Events 解析 |
| 图片选择器功能单一 | **XXFPhotoPicker** - 图片/视频/相机 + 裁剪，可替换 Provider |
| 图片压缩质量难平衡 | **XXFCompress** - Luban 智能压缩算法 |
| 自动布局代码冗长 | **SnapKit** - 声明式约束语法 |

### 核心优势

```
┌─────────────────────────────────────────────────────────────────────┐
│                         XXF iOS 核心优势                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ⚡ 极致性能        │  🧩 模块化设计      │  🛡️ 生产级质量          │
│  ─────────────     │  ─────────────     │  ─────────────          │
│  • XXH3 31.5GB/s  │  • 36+独立模块     │  • 线程安全保证          │
│  • LRU O(1) 操作  │  • 按需引入        │  • 完善错误处理          │
│  • 双层缓存系统    │  • 零耦合设计      │  • 内存泄漏防护          │
│  • 零拷贝优化      │  • 协议驱动        │  • 崩溃恢复机制          │
│                                                                      │
│  📱 跨平台支持      │  🔧 开发者友好      │  📈 可扩展架构          │
│  ─────────────     │  ─────────────     │  ─────────────          │
│  • iOS 15+        │  • 链式 API        │  • 插件系统             │
│  • macOS 13+      │  • 丰富的 Demo     │  • 适配器模式           │
│  • 统一 API       │  • 完整文档        │  • 策略可替换           │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 目录

- [版本状态与兼容性](#版本状态与兼容性)
- [快速开始](#快速开始)
- [本地开发与验证](#本地开发与验证)
- [模块选型建议](#模块选型建议)
- [架构设计](#架构设计)
- [模块详解](#模块详解)
  - [XXFFoundation - 基础设施层](#1-xxffoundation---基础设施层)
  - [XXFFlow - 响应式流处理引擎](#2-xxfflow---响应式流处理引擎)
  - [XXFHttp - 网络请求框架](#3-xxfhttp---网络请求框架)
  - [XXFRouter - 企业级路由框架](#4-xxfrouter---企业级路由框架)
  - [XXFDatabase - 数据库抽象层](#5-xxfdatabase---数据库抽象层)
  - [XXFBus - 事件总线](#6-xxfbus---事件总线)
  - [XXFCache - 缓存系统](#7-xxfcache---缓存系统)
  - [XXFLog - 日志系统](#8-xxflog---日志系统)
  - [XXFJson - JSON处理](#9-xxfjson---json处理)
  - [XXFSpeed - 高性能工具](#10-xxfspeed---高性能工具)
  - [XXFReusable - Cell复用系统](#11-xxfreusable---cell复用系统)
  - [XXFRefreshable - 下拉刷新组件](#12-xxfrefreshable---下拉刷新组件)
  - [XXFAdapter - DiffableDataSource适配器](#13-xxfadapter---diffabledatasource适配器)
  - [XXFSwiftFormat - 代码格式化](#14-xxfswiftformat---代码格式化)
  - [XXFImageEditor - 图片编辑/裁切](#15-xxfimageeditor---图片编辑裁切)
  - [XXFPhotoPicker - 图片视频选择器](#16-xxfphotopicker---图片视频选择器)
  - [XXFKeyboard - 键盘适配组件](#17-xxfkeyboard---键盘适配组件)
    - [KeyboardResizeContainer](#keyboardresizecontainer---自适应容器)
    - [KeyboardPanelContainer](#keyboardpanelcontainer---面板容器)
    - [KeyboardHeightProvider](#keyboardheightprovider---全局键盘高度缓存)
  - [XXFPerformance - 性能监控](#18-xxfperformance---性能监控)
  - [XXFCompress - 图片压缩（Luban）](#19-xxfcompress---图片压缩luban)
  - [其他模块](#20-其他模块)
- [设计模式](#设计模式)
- [最佳实践](#最佳实践)
- [依赖关系](#依赖关系)
- [深度规范（跨模块）](#深度规范跨模块)
- [常见问题（FAQ）](#常见问题faq)

---

## 版本状态与兼容性

| 维度 | 当前状态 |
|------|---------|
| Swift | `6.0+` |
| 平台 | `iOS 15+` / `macOS 13+` |
| 包管理 | Swift Package Manager |
| 推荐接入方式 | `XXFArch` 一站式聚合模块 |
| 最低接入建议 | 新项目优先按需模块化接入，历史项目优先保持稳定后再逐步替换 |

> 说明：如需精确依赖版本，请以项目根目录 `Package.swift` 与 `Package.resolved` 为准。

---

## 快速开始

### 安装

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/NBXXF/xxf_ios.git", from: "1.0.0")
]

// 引入方式
import XXFArch      // 完整架构层（推荐，包含所有模块）
// 或按需引入
import XXFHttp      // 仅网络
import XXFRouter    // 仅路由
import XXFDatabase  // 仅数据库
```

### 30 秒上手

```swift
// 1️⃣ 初始化（AppDelegate 或 @main）
LogUtils.initialize(enableCacheFile: true, enableMemoryCache: true)
let _ = BlockWatcher(threshold: 0.4)  // 卡顿监控

// 2️⃣ 配置路由
Router.shared.register(ProfileViewController.self)
Router.shared.registerInterceptor(LoginCheckInterceptor(
    loginURL: "app://login",
    isLoggedIn: { UserManager.shared.isLoggedIn }
))

// 3️⃣ 定义 API
enum UserAPI: RestApiService {
    case getUser(id: String)
    // ... Moya TargetType 实现
}

// 4️⃣ 发起请求 - 就这么简单！
UserAPI.apiService
    .request(.getUser(id: "123"))
    .mapHttpResponse(User.self)
    .subscribeOnIO()
    .observeOnMain()
    .subscribe(onNext: { user in
        print("Hello, \(user.name)!")
    })
    .disposed(by: disposeBag)

// 5️⃣ 路由导航
Router.shared.navigate(to: "app://profile/123")
```

---

## 本地开发与验证

### 常用命令

```bash
# 解析依赖
swift package resolve

# 全量构建
swift build

# 运行测试
swift test
```

### Xcode 工程集成建议

1. 在 Xcode 中通过 `Add Package Dependencies` 引入仓库地址。
2. 默认优先引入 `XXFArch`，再按业务拆分替换成按需模块。
3. 开启 CI 后，建议至少执行一次 `swift build` + `swift test` 作为合入门槛。

---

## 模块选型建议

| 场景 | 推荐模块组合 |
|------|-------------|
| 需要最快落地（中后台/企业应用） | `XXFArch` |
| 仅网络与接口治理 | `XXFHttp + XXFFlow + XXFLog` |
| 强状态管理与页面解耦 | `XXFRouter + XXFViewModel + XXFBus` |
| 本地数据密集型业务 | `XXFDatabase + XXFCache (+ XXFCacheMMKV)` |
| 复杂列表与交互 UI | `XXFAdapter + XXFReusable + XXFRefreshable` |
| 媒体类业务（图像处理） | `XXFPhotoPicker + XXFImageEditor + XXFCompress + XXFImageNukeLoader` |
| 线上稳定性治理 | `XXFPerformance + XXFTracker + XXFLog` |

---

## 架构设计

### 分层架构

```
┌─────────────────────────────────────────────────────────────────────┐
│                        应用层 (Application)                          │
│           XXFAppkit · XXFViewModel · XXFHud · XXFRouter              │
│        ┌─────────────────────────────────────────────────┐          │
│        │  UI 组件、ViewModel、HUD、路由导航、生命周期管理   │          │
│        └─────────────────────────────────────────────────┘          │
├─────────────────────────────────────────────────────────────────────┤
│                        集成层 (Integration)                          │
│                            XXFArch                                   │
│        ┌─────────────────────────────────────────────────┐          │
│        │    一站式引入所有模块，统一版本管理，简化依赖配置    │          │
│        └─────────────────────────────────────────────────┘          │
├─────────────────────────────────────────────────────────────────────┤
│                       业务逻辑层 (Business)                          │
│        XXFHttp · XXFDatabase · XXFBus · XXFCache · XXFRouter         │
│        ┌─────────────────────────────────────────────────┐          │
│        │  网络请求(含SSE)、数据持久化、事件通信、路由导航    │          │
│        └─────────────────────────────────────────────────┘          │
├─────────────────────────────────────────────────────────────────────┤
│                      基础设施层 (Infrastructure)                     │
│         XXFFoundation · XXFLog · XXFJson · XXFFlow · XXFSpeed        │
│        ┌─────────────────────────────────────────────────┐          │
│        │    基础类型、日志系统、JSON 处理、响应式流扩展       │          │
│        └─────────────────────────────────────────────────┘          │
├─────────────────────────────────────────────────────────────────────┤
│                        UI工具层 (UI Utilities)                       │
│  XXFReusable · XXFRefreshable · XXFAdapter · XXFImageEditor ·        │
│  XXFPhotoPicker · KeyboardPanelContainer · SnapKit · MJRefresh       │
│        ┌─────────────────────────────────────────────────┐          │
│        │  Cell复用、下拉刷新、数据源适配、图片编辑、键盘面板   │          │
│        └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
```

### 设计原则（提炼）

| 原则 | 说明 | 落地方式 |
|------|------|---------|
| 单向依赖 | 上层可依赖下层，下层不反向依赖上层 | `Application -> Business -> Infrastructure` |
| 抽象优先 | 先定义协议，再接具体实现 | `XXFDatabase` + `XXFDatabaseGrdb/ObjectBox` |
| 可替换实现 | 能按业务替换 provider | `XXFImageEditor/PhotoPicker/Tracker/Hud` |
| 横切关注点集中 | 日志、监控、错误追踪集中治理 | `XXFLog + XXFPerformance + XXFTracker` |
| 默认安全 | 线程、生命周期、错误处理有兜底 | 并发容器、`bindLifecycle`、统一异常处理 |

### 依赖方向（必须遵守）

1. 业务模块不要直接依赖三方实现包，优先依赖 XXF 抽象层。
2. UI 层不要直接持有数据库/网络实现细节，统一经服务或仓储访问。
3. Provider 实现模块（如 `XXFPhotoPickerZl`）只做实现，不承载业务逻辑。

### 典型调用链（端到端）

`ViewModel/ViewController -> XXFHttp -> XXFFlow 调度 -> XXFDatabase/XXFCache 回填 -> XXFLog/XXFTracker 观测`

---

## 模块详解

---

## 模块总览（按层提取）

| 分层 | 模块 | 角色定位 |
|------|------|---------|
| 集成层 | `XXFArch` | 一站式聚合入口，统一版本与依赖面 |
| 应用层 | `XXFAppkit` `XXFViewModel` `XXFHud` `XXFRouter` | 页面组织、生命周期、导航、用户反馈 |
| 业务层 | `XXFHttp` `XXFDatabase` `XXFCache` `XXFBus` | 网络、存储、缓存、事件通信 |
| 基础层 | `XXFFoundation` `XXFFlow` `XXFJson` `XXFLog` `XXFSpeed` | 基础类型、响应式扩展、序列化、日志、性能工具 |
| UI工具层 | `XXFReusable` `XXFAdapter` `XXFRefreshable` `XXFKeyboard` `XXFPhotoPicker` `XXFImageEditor` `XXFCompress` | 列表、刷新、键盘、媒体与图片处理能力 |
| 扩展实现层 | `XXFDatabaseGrdb/ObjectBox` `XXFCacheMMKV` `XXFPhotoPickerZl` `XXFImageEditorBrightroom` `XXFTrackerSentry/Bugsnag` | 面向具体三方库的实现模块，可按需替换 |

### 模块选型速查（推荐组合）

| 目标 | 最小组合 | 可选增强 |
|------|---------|---------|
| 快速搭建新项目 | `XXFArch` | 按需替换为拆分模块 |
| 强网络治理 | `XXFHttp + XXFFlow + XXFLog` | `XXFTracker` |
| 数据密集业务 | `XXFDatabase + XXFCache` | `XXFDatabaseGrdb/ObjectBox` |
| 重交互列表页 | `XXFAdapter + XXFReusable + XXFRefreshable` | `XXFKeyboard` |
| 媒体编辑链路 | `XXFPhotoPicker + XXFImageEditor + XXFCompress` | `XXFImageNukeLoader` |
| 线上稳定性治理 | `XXFPerformance + XXFLog + XXFTracker` | `XXFBus` |

---

## 模块索引（统一模板版）

> 本节用于快速理解各模块职责；后续各章节保留完整示例与 API 细节。

### 1) XXFFoundation
- 定位：基础类型与线程安全工具集合。
- 何时使用：需要并发容器、容错工具、基础函数扩展时。
- 核心能力：`Result` 扩展、`tryOr*`、并发集合、事件节流防抖。
- 注意事项：作为底层依赖，避免在上层重复实现类似工具。

### 2) XXFFlow
- 定位：RxSwift 增强层，统一线程切换与生命周期绑定。
- 何时使用：项目采用 RxSwift 且希望降低样板代码时。
- 核心能力：`subscribeOnIO()`、`observeOnMain()`、`bindLifecycle()`、调试日志。
- 注意事项：团队需统一流式风格，避免原生 Rx 与扩展混用失控。

### 3) XXFHttp
- 定位：企业级网络层（请求、缓存、SSE、拦截、监控）。
- 何时使用：需要统一 API 管理、缓存策略和流式响应支持时。
- 核心能力：服务池、六类缓存策略、SSE 解析、请求拦截链。
- 注意事项：缓存策略要按接口业务语义选择，避免全局默认导致脏读。

### 4) XXFRouter
- 定位：统一路由与导航治理中心。
- 何时使用：页面复杂、需要登录/VIP/参数校验拦截时。
- 核心能力：路由注册、拦截器链、降级处理、SPI 服务发现。
- 注意事项：路由协议与 URL 规范建议在团队内冻结版本管理。

### 5) XXFDatabase
- 定位：Repository 抽象层，屏蔽具体数据库实现。
- 何时使用：希望业务代码不感知 GRDB/ObjectBox 差异时。
- 核心能力：统一 CRUD、分页、查询扩展、实现可替换。
- 注意事项：SQL 强需求选 GRDB；对象图和吞吐优先可选 ObjectBox。

### 6) XXFBus
- 定位：进程内事件总线。
- 何时使用：跨页面/跨组件松耦合通信时。
- 核心能力：普通事件、黏性事件、类型安全订阅。
- 注意事项：事件名与载荷结构需规范，避免“总线滥用”。

### 7) XXFCache
- 定位：声明式偏好与轻量持久化能力。
- 何时使用：本地配置、登录态、开关类数据存取时。
- 核心能力：`@PreferenceWrapper`、可切换 UserDefaults/MMKV。
- 注意事项：切换 MMKV 时建议带迁移标记和回滚开关。

### 8) XXFLog
- 定位：统一日志采集与查看入口。
- 何时使用：需要本地持久化日志、故障复盘、分级输出时。
- 核心能力：多 Handler、文件缓存、Pulse 可视化。
- 注意事项：生产环境注意日志脱敏与体积控制。

### 9) XXFJson
- 定位：高容错 JSON 编解码层。
- 何时使用：后端字段不稳定、类型漂移、默认值需求多时。
- 核心能力：线程优化编解码、`@CodingDefault/@CodingLenient/@CodingBy`。
- 注意事项：装饰器单字段仅一个，复杂组合建议写自定义 Adapter。

### 10) XXFSpeed
- 定位：高性能基础组件（哈希与缓存）。
- 何时使用：大规模哈希计算或热点内存缓存时。
- 核心能力：XXH3、LRU O(1) 读写。
- 注意事项：缓存上限应按设备内存分级配置。

### 11) XXFReusable
- 定位：列表复用自动化工具。
- 何时使用：Table/Collection Cell 注册与出队样板代码多时。
- 核心能力：自动注册、泛型安全出队、NIB 支持。
- 注意事项：统一 Cell 命名与 NIB 约定可降低踩坑率。

### 12) XXFRefreshable
- 定位：刷新/加载状态机封装。
- 何时使用：列表存在下拉刷新和上拉分页时。
- 核心能力：状态互斥、防冲突、Rx 绑定状态流。
- 注意事项：分页终止条件应和后端分页协议严格对齐。

### 13) XXFAdapter
- 定位：DiffableDataSource 统一适配层。
- 何时使用：需要稳定、可动画更新的列表数据源时。
- 核心能力：统一 CRUD、主线程安全应用 snapshot。
- 注意事项：Item 标识必须稳定且唯一。

### 14) XXFSwiftFormat
- 定位：代码风格统一配置出口。
- 何时使用：团队协作和 CI 自动格式化时。
- 核心能力：统一配置路径、规则治理。
- 注意事项：规则变更需通过 PR 公告，避免大面积无效 diff。

### 15) XXFImageEditor
- 定位：图片编辑抽象门面。
- 何时使用：需要裁切/编辑且避免直接耦合三方库时。
- 核心能力：Provider 协议、可替换 Brightroom 实现。
- 注意事项：App 启动时完成 provider 注册，避免运行期空实现。

### 16) XXFPhotoPicker
- 定位：图片/视频选择器抽象门面。
- 何时使用：相册、拍摄、裁切能力需要统一接入时。
- 核心能力：单选多选、拍照摄像、裁切、主题定制。
- 注意事项：权限申请与失败兜底页面需要业务侧补齐。

### 17) XXFKeyboard
- 定位：键盘联动适配组件。
- 何时使用：输入页、聊天页、面板联动场景。
- 核心能力：`KeyboardResizeContainer`、`KeyboardPanelContainer`、高度缓存。
- 注意事项：首屏键盘高度预测依赖缓存，建议启动即监听。

### 18) XXFPerformance
- 定位：运行时性能观测能力。
- 何时使用：性能压测、线上卡顿排查阶段。
- 核心能力：BlockWatcher、FPS/CPU/内存悬浮监控。
- 注意事项：线上默认关闭高频可视化，仅保留必要采样。

### 19) XXFCompress
- 定位：图片压缩能力层。
- 何时使用：上传前压缩、聊天/动态图片优化。
- 核心能力：Luban 策略、同步/异步/链式 API。
- 注意事项：压缩质量需按业务（头像/内容图）分策略。

### 20) 其他扩展模块
- 定位：具体生态实现与平台扩展。
- 何时使用：需要接入具体 SDK（Sentry/Bugsnag/MMKV/ZL/Brightroom）时。
- 核心能力：保持抽象层稳定前提下替换底层实现。
- 注意事项：扩展模块升级要与抽象层版本联测。

---

## 1. XXFFoundation - 基础设施层

### 工程边界
- 上游依赖：标准库
- 下游服务对象：所有模块
- 边界与不负责：不承载业务语义与页面流程

### 定位
基础类型、并发安全容器、错误处理与通用工具。

### 何时使用
需要线程安全集合、统一容错写法、基础能力复用时。

### 核心能力
- `Result` 链式扩展（`fold/getOrDefault/onSuccess`）
- `tryOrLog/tryOrNil/tryOrDefault`
- `ConcurrentDictionary/ConcurrentArray`
- `EventLimiter.debounce/throttle`

### 最小示例
```swift
let user = result.getOrDefault(.guest)
let cache = ConcurrentDictionary<String, Data>()
cache["token"] = data
```

### 注意事项
底层模块应保持稳定，避免在业务层重复造同类工具。
典型反模式：在业务模块里再实现一套并发容器和错误工具，导致语义分裂。

---

## 2. XXFFlow - 响应式流处理引擎

### 工程边界
- 上游依赖：RxSwift/RxCocoa
- 下游服务对象：网络、数据库、UI 绑定链路
- 边界与不负责：不替代业务状态机设计

### 定位
RxSwift 增强层，减少线程切换与生命周期管理样板代码。

### 何时使用
项目采用 RxSwift，且希望统一流式编码规范时。

### 核心能力
- `subscribeOnIO()` / `observeOnMain()`
- `bindLifecycle(to:)`
- 快速降级与调试日志

### 最小示例
```swift
api.fetchData()
  .subscribeOnIO()
  .observeOnMain()
  .bindLifecycle(to: self)
  .subscribe(onNext: render)
  .disposed(by: bag)
```

### 注意事项
统一团队操作符用法，避免原生与扩展风格混杂。
典型反模式：同一链路混用多套线程切换约定，出现回调线程不可预测。

---

## 3. XXFHttp - 网络请求框架

### 工程边界
- 上游依赖：Moya/RxMoya/URLSession
- 下游服务对象：Repository、ViewModel、Service
- 边界与不负责：不承载页面业务编排

### 定位
企业级网络层：请求、缓存、SSE、拦截、监控统一治理。

### 何时使用
需要可配置缓存策略、流式响应、统一日志观测时。

### 核心能力
- API 服务池与请求链路封装
- 六类缓存策略（`firstCache/onlyRemote/...`）
- SSE 事件解析与流式消费

### 最小示例
```swift
UserAPI.apiService
  .request(.profile(id: "123"))
  .mapHttpResponse(User.self)
  .subscribeOnIO()
  .observeOnMain()
  .subscribe(onNext: updateUI)
  .disposed(by: bag)
```

### 注意事项
缓存策略按接口语义设置，避免错误复用导致数据陈旧。
典型反模式：所有接口统一 `firstCache`，把强实时接口也缓存。

---

## 4. XXFRouter - 企业级路由框架

### 工程边界
- 上游依赖：URLNavigator
- 下游服务对象：页面导航与跨模块跳转
- 边界与不负责：不管理页面内部状态

### 定位
统一页面导航、拦截器链与降级策略。

### 何时使用
页面多、权限规则复杂、跨模块跳转频繁时。

### 核心能力
- 路由注册与批量注册
- 拦截器链（登录/VIP/参数校验）
- 降级与回调结果统一

### 最小示例
```swift
Router.shared.register(ProfileViewController.self)
Router.shared.registerInterceptor(LoginCheckInterceptor(...))
Router.shared.navigate(to: "app://profile/123")
```

### 注意事项
维护统一 URL 规范与路由命名约定。
典型反模式：直接在业务代码硬编码跳转逻辑而不经过路由中心。

---

## 5. XXFDatabase - 数据库抽象层

### 工程边界
- 上游依赖：GRDB 或 ObjectBox
- 下游服务对象：Repository、本地数据域
- 边界与不负责：不处理远端同步策略

### 定位
Repository 抽象层，屏蔽 GRDB/ObjectBox 差异。

### 何时使用
希望业务代码与底层数据库实现解耦时。

### 核心能力
- 统一 CRUD / 分页 / 查询扩展
- 可替换实现：`XXFDatabaseGrdb` / `XXFDatabaseObjectBox`

### 最小示例
```swift
repo.insertOrUpdate(user)
let user = repo.selectById("123")
let page = repo.selectPage(page: 1, pageSize: 20) { $0 }
```

### 注意事项
关系型复杂查询优先 GRDB；对象图与吞吐优先 ObjectBox。
典型反模式：业务层直接依赖底层 ORM API，绕过 Repository 抽象。

---

## 6. XXFBus - 事件总线

### 工程边界
- 上游依赖：RxSwift
- 下游服务对象：跨组件广播场景
- 边界与不负责：不替代明确的函数调用链

### 定位
基于 RxSwift 的进程内事件通信。

### 何时使用
跨组件解耦通信、状态广播、弱依赖通知时。

### 核心能力
- 类型安全事件订阅
- Sticky 事件支持

### 最小示例
```swift
RxBus.shared.post(UserLoginEvent(user: user))
RxBus.shared.observe(UserLoginEvent.self)
  .observeOnMain()
  .subscribe(onNext: handle)
  .disposed(by: bag)
```

### 注意事项
控制事件数量与命名规范，避免“全局总线污染”。
典型反模式：把总线当函数调用替代品，所有模块都靠广播通信。

---

## 7. XXFCache - 缓存系统

### 工程边界
- 上游依赖：UserDefaults/MMKV
- 下游服务对象：偏好设置与轻量状态
- 边界与不负责：不替代结构化数据库

### 定位
声明式偏好存储与轻量持久化。

### 何时使用
保存登录态、配置项、轻量业务数据时。

### 核心能力
- `@PreferenceWrapper` 声明式读写
- Provider 可切换（UserDefaults/MMKV）

### 最小示例
```swift
class Prefs {
  @PreferenceWrapper(nil, "access_token") var token: String?
}
```

### 注意事项
切换 MMKV 时应提供一次性迁移与回滚开关。
典型反模式：直接切换存储实现却不做迁移，导致线上用户状态丢失。

---

## 8. XXFLog - 日志系统

### 工程边界
- 上游依赖：swift-log/Pulse
- 下游服务对象：调试、排障、审计链路
- 边界与不负责：不做业务埋点统计聚合

### 定位
统一日志采集、持久化与可视化。

### 何时使用
需要线上排障、调试追踪、链路复盘时。

### 核心能力
- 多 Handler 输出
- 文件/内存缓存
- Pulse 集成

### 最小示例
```swift
LogUtils.initialize(enableCacheFile: true, enableMemoryCache: true)
logI { "app started" }
logE { "request failed: \(error)" }
```

### 注意事项
生产环境需做日志脱敏与大小控制。
典型反模式：把完整用户隐私和 token 明文写入持久化日志。

---

## 9. XXFJson - JSON处理

### 工程边界
- 上游依赖：Codable
- 下游服务对象：网络模型、本地序列化
- 边界与不负责：不约束接口版本管理策略

### 定位
高容错 JSON 编解码层。

### 何时使用
后端字段不稳定、类型漂移、默认值需求高时。

### 核心能力
- 线程优化 JSON 编解码
- Wrapper：`@CodingDefault/@CodingLenient/@CodingBy/@CodingDate`

### 最小示例
```swift
struct User: Codable {
  @CodingDefault<EmptyString> var name: String
  @CodingLenient var age: Int = 0
}
```

### 注意事项
复杂组合逻辑建议自定义 Adapter。
典型反模式：在模型层堆叠大量临时转换逻辑，污染业务字段语义。

---

## 10. XXFSpeed - 高性能工具

### 工程边界
- 上游依赖：XXHash 等
- 下游服务对象：缓存键计算与热点存储
- 边界与不负责：不替代完整性能治理体系

### 定位
高性能哈希与缓存能力。

### 何时使用
高频哈希计算或热点数据缓存时。

### 核心能力
- XXH3 哈希
- LRU O(1) 读写

### 最小示例
```swift
let h = XXH3.hash(data)
let cache = LRUCache<String, Data>(maxCount: 100)
```

### 注意事项
根据设备内存设置缓存上限。
典型反模式：缓存无上限，长会话后触发内存抖动和回收风暴。

---

## 11. XXFReusable - Cell复用系统

### 工程边界
- 上游依赖：UIKit
- 下游服务对象：Table/Collection 列表渲染
- 边界与不负责：不管理业务数据源正确性

### 定位
Table/Collection 复用自动注册与类型安全出队。

### 何时使用
列表页面多、复用样板代码多时。

### 核心能力
- 自动注册
- 泛型安全出队
- NIB 支持

### 最小示例
```swift
let cell: MyCell = tableView.dequeueReusableCell(for: indexPath)
```

### 注意事项
Cell 与 NIB 命名保持一致。
典型反模式：手写字符串复用 ID 且跨文件复制，最终出现错配崩溃。

---

## 12. XXFRefreshable - 下拉刷新组件

### 工程边界
- 上游依赖：MJRefresh/RxSwift
- 下游服务对象：列表刷新与分页加载
- 边界与不负责：不决定分页接口语义

### 定位
刷新与加载状态机封装。

### 何时使用
列表场景有下拉刷新和分页加载时。

### 核心能力
- 刷新/加载互斥
- Rx 状态绑定

### 最小示例
```swift
refreshState.bind(to: tableView.rx.refreshableState).disposed(by: bag)
tableView.addRefreshing { [weak self] in self?.refresh() }
```

### 注意事项
分页状态必须和后端分页协议一致。
典型反模式：前端盲目自增页码，不校验是否到底导致重复请求。

---

## 13. XXFAdapter - DiffableDataSource适配器

### 工程边界
- 上游依赖：UIKit DiffableDataSource
- 下游服务对象：列表快照更新场景
- 边界与不负责：不保证 item 标识稳定性

### 定位
DiffableDataSource 的统一抽象层。

### 何时使用
需要稳定动画更新和安全数据快照时。

### 核心能力
- 统一 CRUD 接口
- 主线程安全应用快照

### 最小示例
```swift
dataSource?.appendItems(items, to: .main, animatingDifferences: true)
```

### 注意事项
Item 标识必须稳定且唯一。
典型反模式：用 index 作为 item id，插入删除后动画与数据错乱。

---

## 14. XXFSwiftFormat - 代码格式化

### 工程边界
- 上游依赖：SwiftFormat
- 下游服务对象：CI 与团队协作
- 边界与不负责：不处理静态语义问题

### 定位
统一 Swift 代码格式规则与配置入口。

### 何时使用
多人协作、CI 合并前格式校验时。

### 核心能力
- 统一配置路径
- 规则集中治理

### 最小示例
```swift
let path = SwiftFormatConfig.path
```

### 注意事项
规则变更需公告并渐进落地，避免大规模无效 diff。
典型反模式：一次性改动全部格式规则并和业务改动混在一个 PR。

---

## 15. XXFImageEditor - 图片编辑/裁切

### 工程边界
- 上游依赖：Provider 实现（如 Brightroom）
- 下游服务对象：头像、封面、内容图编辑
- 边界与不负责：不负责媒体资源上传

### 定位
图片编辑门面层，隔离具体编辑 SDK。

### 何时使用
需要裁切/编辑能力且希望可替换底层实现时。

### 核心能力
- `ImageEditorProvider` 协议
- Brightroom 实现可插拔

### 最小示例
```swift
ImageEditor.shared.provider = BrightroomImageEditorProvider()
ImageEditor.shared.presentCrop(from: self, image: image) { _ in }
```

### 注意事项
启动阶段完成 provider 注册。
典型反模式：在页面点击时才懒注册 provider，导致首帧行为不一致。

---

## 16. XXFPhotoPicker - 图片视频选择器

### 工程边界
- 上游依赖：Provider 实现（如 ZLPhotoBrowser）
- 下游服务对象：相册、拍摄入口
- 边界与不负责：不负责后续媒体处理流水线

### 定位
相册/拍摄/裁切统一门面。

### 何时使用
需要统一媒体选择入口并隔离三方依赖时。

### 核心能力
- 单选/多选/视频
- 相机拍摄
- 可选裁切与主题配置

### 最小示例
```swift
PhotoPicker.shared.provider = ZLPhotoPickerProvider()
PhotoPicker.shared.presentPicker(from: self) { _ in }
```

### 注意事项
权限申请与拒绝兜底需要业务补齐。
典型反模式：只实现成功路径，不处理相册/相机权限拒绝分支。

---

## 17. XXFKeyboard - 键盘适配组件

### 工程边界
- 上游依赖：RxKeyboard/SnapKit
- 下游服务对象：输入页与面板联动布局
- 边界与不负责：不管理输入业务规则

### 定位
输入场景键盘联动与高度治理。

### 何时使用
聊天/评论/输入面板等与键盘强耦合页面。

### 核心能力
- `KeyboardResizeContainer`
- `KeyboardPanelContainer`
- `KeyboardHeightProvider`

### 最小示例
```swift
KeyboardHeightProvider.shared.startMonitoring()
let container = KeyboardResizeContainer()
container.bindContentView(contentView)
```

### 注意事项
建议冷启动即开启高度监听，提升首次弹起体验。
典型反模式：首次输入时才计算键盘高度，造成布局突跳。

---

## 18. XXFPerformance - 性能监控

### 工程边界
- 上游依赖：GDPerformanceView 等
- 下游服务对象：性能观测与告警
- 边界与不负责：不自动修复性能问题

### 定位
运行时性能观测与卡顿检测。

### 何时使用
性能优化、线上问题排查、压测阶段。

### 核心能力
- `BlockWatcher` 卡顿检测
- FPS/CPU/内存悬浮监控

### 最小示例
```swift
let _ = BlockWatcher(threshold: 0.4)
GDPerformanceMonitorView.shared.start()
```

### 注意事项
生产环境建议降采样或按开关启用。
典型反模式：线上常驻高频性能面板，增加额外性能开销。

---

## 19. XXFCompress - 图片压缩（Luban）

### 工程边界
- 上游依赖：Luban 算法实现
- 下游服务对象：上传前图片压缩链路
- 边界与不负责：不做图像内容质量评估

### 定位
上传前图片压缩能力层。

### 何时使用
聊天、动态、内容发布等图片上传场景。

### 核心能力
- Luban 压缩策略
- 链式/同步/异步 API

### 最小示例
```swift
let data = try await Luban.with().load(image).compress()
```

### 注意事项
按场景区分压缩策略（头像/内容图/原图）。
典型反模式：所有图片统一极限压缩，导致关键内容不可读。

---

## 20. 其他模块

### 工程边界
- 上游依赖：各三方 SDK
- 下游服务对象：具体实现替换点
- 边界与不负责：不新增抽象层契约

### 定位
具体三方实现与平台扩展层。

### 何时使用
需要对接具体 SDK 或替换默认实现时。

### 代表模块
- `XXFDatabaseGrdb` / `XXFDatabaseObjectBox`
- `XXFCacheMMKV`
- `XXFImageEditorBrightroom`
- `XXFPhotoPickerZl`
- `XXFTrackerSentry` / `XXFTrackerBugsnag`
- `XXFHudIOS` / `XXFHudMac`

### 注意事项
扩展模块升级需与抽象层版本联测。
典型反模式：只升级实现模块不做联测，最终在运行期出现协议不兼容。

---
## 设计模式

| 模式 | 应用 | 收益 |
|------|------|------|
| **单例** | XXFHttp, RxBus, Router | 全局访问，资源复用 |
| **工厂** | ViewModelProvider, XXFHttp | 延迟创建，生命周期管理 |
| **适配器** | ImageLoaderAdapter, DiffableDataSourceAdapter | 可替换实现 |
| **拦截器链** | RouteInterceptor, RxCallAdapter | 灵活的处理流程 |
| **状态机** | RefreshableState | 状态管理清晰 |
| **Repository** | XXFDatabase | 数据层抽象 |
| **观察者** | RxSwift, RxBus | 响应式，松耦合 |

---

## 最佳实践

### 推荐初始化顺序

```swift
@main
struct MyApp: App {
    init() {
        // 1. 日志系统（最先）
        LogUtils.initialize(enableCacheFile: true, enableMemoryCache: true)

        // 2. 性能监控
        let _ = BlockWatcher(threshold: 0.4)
        GDPerformanceMonitorView.shared.start()  // FPS/CPU/内存悬浮窗

        // 3. 错误追踪
        Tracker.shared.registerChanelTracker(SentryTracker())

        // 4. 路由配置
        setupRoutes()
        setupInterceptors()

        // 5. 网络监控
        NetworkMonitor.shared.startMonitoring()

        logI { "App initialized" }
    }
}
```

### 网络请求最佳实践

```swift
api.request(...)
    .subscribeOnIO()           // 1. 后台执行
    .retry(3)                  // 2. 自动重试
    .catchError(fallback)      // 3. 错误降级
    .observeOnMain()           // 4. 主线程回调
    .bindLifecycle(to: self)   // 5. 生命周期绑定
    .subscribe(...)
    .disposed(by: disposeBag)
```

---

## 依赖关系

### 外部依赖

| 依赖 | 用途 | 版本 |
|------|------|------|
| RxSwift/RxCocoa | 响应式编程 | 6.x |
| Moya/RxMoya | 网络层 | 15.x |
| GRDB.swift | 数据库（SQLite/关系型） | 7.x |
| objectbox-swift-spm | 数据库（对象数据库/NoSQL） | 5.x |
| Factory | 依赖注入 | 2.x |
| swift-log | 日志标准 | 1.x |
| Pulse | 日志可视化 | 4.x |
| Nuke | 图片加载 | 12.x |
| Brightroom | 图片编辑/裁切 | 2.x |
| ZLPhotoBrowser | 图片视频选择器 | 4.x |
| RxKeyboard | 键盘事件响应式封装 | 2.x |
| GDPerformanceView-Swift | FPS/CPU/内存监控悬浮窗 | 2.x |
| MMKV | 高性能 KV 存储（PreferencesStorage 实现） | 2.x |
| SnapKit | 自动布局 | 5.x |
| MJRefresh | 下拉刷新 | 3.x |
| URLNavigator | 路由匹配 | 2.x |

### 依赖图

```
XXFArch (一站式引入)
├── XXFHttp (网络 + SSE + 缓存)
│   ├── XXFFlow
│   │   └── XXFFoundation
│   └── Moya + RxMoya
├── XXFRouter (路由框架)
│   └── URLNavigator
├── XXFDatabase
│   ├── XXFDatabaseGrdb (GRDB, SQLite/关系型)
│   └── XXFDatabaseObjectBox (ObjectBox, 对象数据库/NoSQL)
├── XXFReusable (Cell 复用)
├── XXFRefreshable (下拉刷新)
│   └── MJRefresh
├── XXFAdapter (DiffableDataSource)
├── XXFBus (RxSwift)
├── XXFCache
│   └── XXFCacheMMKV (MMKV)
├── XXFLog (swift-log + Pulse)
├── XXFJson
├── XXFSpeed (XXHash)
├── XXFSwiftFormat
├── XXFUIKit
├── XXFImageLoader ────────── XXFImageNukeLoader (Nuke)
├── XXFImageEditor ────────── XXFImageEditorBrightroom (Brightroom 2.x)
├── XXFPhotoPicker ────────── XXFPhotoPickerZl (ZLPhotoBrowser 4.x)
├── XXFCompress (Luban 图片压缩)
├── XXFKeyboard ───────────── RxKeyboard (2.x)
├── XXFPerformance (BlockWatcher + GDPerformanceView-Swift)
├── SnapKit
└── ...
```

---

## 深度规范（跨模块）

### 1. 稳定性契约
- 线程模型：明确主线程/后台线程执行边界，禁止隐式线程切换。
- 失败语义：统一约定失败行为（抛错、降级、空值）并写入 API 注释。
- 超时重试：网络和 IO 相关能力必须声明默认超时与重试上限。

### 2. 性能基线
- 每个核心模块至少维护 3 个指标：平均耗时、TP95/TP99、峰值内存。
- 基准测试需注明：机型、系统版本、样本量、并发度、冷/热启动场景。

### 3. 状态机与时序
- 带状态流转模块必须有状态图或时序图：输入、状态迁移、终止条件。
- 关键异步链路必须标注“可能多次回调”的节点（如缓存+网络）。

### 4. 可观测性
- 统一日志字段：`traceId`、`module`、`action`、`result`、`costMs`、`errorCode`。
- 统一错误编码：模块级前缀 + 场景编号，支持跨端检索。

### 5. 升级与迁移
- 每次破坏性变更必须附迁移说明：影响面、替换 API、灰度与回滚步骤。
- Provider 模块升级需给兼容矩阵（抽象层版本 vs 实现层版本）。

### 6. 测试矩阵
- 必含：单元测试、集成测试、并发测试、故障注入测试。
- 核心模块新增能力时，同步补“最低必过用例”清单。

### 7. 安全与合规
- 日志脱敏、缓存分级、权限失败分支、敏感字段传输规范必须可审计。

### 8. 反模式修复
- 每个反模式需提供最短修复路径（1-2 步），便于 code review 直接落地。

### 核心模块落地样例

#### XXFHttp
- 稳定性契约：默认请求超时、重试上限、缓存回填回调次数（1-2 次）必须显式说明。
- 性能基线：记录 `request->decode` 全链路 TP95 与缓存命中率。
- 可观测性：每次请求输出统一字段并关联 `traceId`。
- 测试矩阵：覆盖缓存策略分支、SSE 分块乱序、弱网重试。
- 迁移要求：新增/废弃缓存策略时给 API 替换表。
- 安全合规：禁止日志打印完整 token/header。
- 反模式修复：若全局误用 `firstCache`，先按接口分级，再补一致性校验。

#### XXFDatabase
- 稳定性契约：读写线程约束、事务边界、失败回滚策略需固定。
- 性能基线：分页查询耗时、批量写入吞吐、索引命中率。
- 可观测性：慢查询阈值告警 + SQL/Query 模板日志（脱敏）。
- 测试矩阵：事务回滚、并发写冲突、迁移脚本回放。
- 迁移要求：GRDB/ObjectBox 切换需提供双写或影子验证窗口。
- 安全合规：本地敏感字段加密存储策略需单独声明。
- 反模式修复：若业务直连 ORM，先回收到 Repository，再做接口收敛。

#### XXFRouter
- 稳定性契约：拦截器执行顺序、短路规则、降级优先级固定。
- 性能基线：路由匹配耗时、批量注册耗时、高频跳转抖动率。
- 可观测性：记录每次导航的命中路由、拦截原因、最终结果。
- 测试矩阵：参数缺失、权限拒绝、循环跳转保护。
- 迁移要求：路由 path 改名必须提供 alias 过渡期。
- 安全合规：敏感参数不得拼接进明文 URL 日志。
- 反模式修复：若分散硬编码跳转，先收口到 Router API，再统一拦截器。

#### XXFJson
- 稳定性契约：默认值、宽松转换、日期解析优先级需确定且可回归。
- 性能基线：大模型解码耗时、嵌套结构峰值内存。
- 可观测性：字段解析失败计数与样本上报（脱敏）。
- 测试矩阵：脏数据、类型漂移、缺失字段、未知枚举值。
- 迁移要求：Wrapper 行为变更需给兼容开关。
- 安全合规：禁止把原始敏感 JSON 全量写日志。
- 反模式修复：若模型层逻辑过重，抽离为 Adapter 并收敛职责。

#### XXFFoundation
- 稳定性契约：并发容器与工具函数需保持无副作用与线程安全语义。
- 性能基线：并发读写开销与锁竞争指标可回归。
- 可观测性：工具层仅输出必要错误日志，避免噪声。
- 测试矩阵：并发读写、边界值、异常路径。
- 迁移要求：基础 API 变更需给替换建议。
- 安全合规：不落地业务敏感信息。
- 反模式修复：若上层重复造基础工具，统一回收至 Foundation。

#### XXFFlow
- 稳定性契约：线程切换与订阅释放行为保持确定性。
- 性能基线：长链路订阅耗时与内存驻留可监控。
- 可观测性：关键操作符支持可开关日志。
- 测试矩阵：线程切换、取消订阅、错误传播。
- 迁移要求：操作符语义变化需给行为对照表。
- 安全合规：日志不输出敏感 payload。
- 反模式修复：混用多套调度约定时，统一封装入口。

#### XXFCache
- 稳定性契约：读写一致性、默认值行为、序列化失败语义固定。
- 性能基线：命中率、读写耗时、存储体积增长曲线。
- 可观测性：关键 key 的 miss/hit 统计。
- 测试矩阵：升级迁移、类型不匹配、并发读写。
- 迁移要求：Provider 切换需双读或迁移标记。
- 安全合规：敏感 key 分级存储与脱敏。
- 反模式修复：若当数据库使用，拆分到 DB 层处理。

#### XXFBus
- 稳定性契约：事件发布顺序、粘性事件覆盖规则明确。
- 性能基线：高频事件吞吐与订阅分发耗时。
- 可观测性：事件名、订阅数量、投递失败统计。
- 测试矩阵：粘性事件、取消订阅、重复订阅。
- 迁移要求：事件结构变化需版本兼容。
- 安全合规：事件载荷禁止携带敏感明文。
- 反模式修复：广播滥用时收敛为显式调用链。

#### XXFLog
- 稳定性契约：日志级别、落盘策略、崩溃前缓存刷新行为确定。
- 性能基线：高频日志写入耗时与磁盘占用上限。
- 可观测性：日志丢失率、flush 成功率。
- 测试矩阵：磁盘满、权限异常、崩溃恢复。
- 迁移要求：Handler 变更需兼容旧格式。
- 安全合规：脱敏规则和黑名单字段必须可配置。
- 反模式修复：明文敏感日志改为字段脱敏 + 分级采样。

#### XXFSpeed
- 稳定性契约：哈希结果稳定、缓存淘汰规则可预测。
- 性能基线：哈希吞吐与 LRU 命中率。
- 可观测性：缓存淘汰次数与热点 key 分布。
- 测试矩阵：大数据量、极端容量、并发读写。
- 迁移要求：算法替换需提供一致性评估。
- 安全合规：避免把哈希当安全加密用途。
- 反模式修复：误用为安全签名时切换到加密算法。

#### XXFReusable
- 稳定性契约：注册/出队流程幂等可重复。
- 性能基线：滚动场景出队耗时与掉帧率。
- 可观测性：注册失败和类型错配日志。
- 测试矩阵：NIB/Code 两种模式、Header/Footer 场景。
- 迁移要求：复用 ID 规则变更需全局扫描。
- 安全合规：无敏感数据特殊要求。
- 反模式修复：字符串出队改为泛型安全 API。

#### XXFRefreshable
- 稳定性契约：刷新与加载互斥状态机不可破坏。
- 性能基线：高频触发下状态切换耗时。
- 可观测性：触发来源、成功率、终止原因。
- 测试矩阵：空数据、到底、重复触发、防抖。
- 迁移要求：状态枚举扩展需兼容旧逻辑。
- 安全合规：无敏感数据特殊要求。
- 反模式修复：并发请求冲突时统一走状态绑定 API。

#### XXFAdapter
- 稳定性契约：snapshot 应用时机和线程语义固定。
- 性能基线：大列表 diff 耗时与动画稳定性。
- 可观测性：apply 次数、冲突项统计。
- 测试矩阵：插删改混合、空 section、重排。
- 迁移要求：item identity 规则升级需灰度验证。
- 安全合规：无敏感数据特殊要求。
- 反模式修复：index 作为 id 改为业务唯一键。

#### XXFSwiftFormat
- 稳定性契约：规则版本固定且可复现。
- 性能基线：全仓格式化耗时。
- 可观测性：CI 格式化失败率。
- 测试矩阵：关键语法样例回归。
- 迁移要求：规则升级分批发布。
- 安全合规：无敏感数据特殊要求。
- 反模式修复：业务改动和格式化改动拆分 PR。

#### XXFImageEditor
- 稳定性契约：provider 生命周期与回调语义一致。
- 性能基线：编辑页首开耗时、导出耗时与峰值内存。
- 可观测性：取消率、失败类型、导出尺寸分布。
- 测试矩阵：大图、旋转、比例裁切、取消流程。
- 迁移要求：provider 替换需统一能力对照。
- 安全合规：临时文件清理策略明确。
- 反模式修复：业务直接依赖三方编辑器，回收至门面层。

#### XXFPhotoPicker
- 稳定性契约：权限流、选择流、回调流语义固定。
- 性能基线：首屏加载耗时、媒体预览内存。
- 可观测性：权限拒绝率、选择完成率、失败码分布。
- 测试矩阵：权限拒绝、单选多选、视频路径。
- 迁移要求：provider 切换需做功能对齐清单。
- 安全合规：相册/相机权限说明文案合规。
- 反模式修复：未处理权限拒绝时补兜底提示与引导。

#### XXFKeyboard
- 稳定性契约：高度同步与动画时序一致。
- 性能基线：输入场景布局抖动率与重排耗时。
- 可观测性：键盘高度变化事件频次。
- 测试矩阵：横竖屏、不同机型、外接键盘。
- 迁移要求：容器策略调整需验证聊天页/表单页。
- 安全合规：无敏感数据特殊要求。
- 反模式修复：手写 frame 适配改为容器组件托管。

#### XXFPerformance
- 稳定性契约：监控采样不会阻断主业务线程。
- 性能基线：监控自身开销上限。
- 可观测性：卡顿次数、FPS 分布、内存水位。
- 测试矩阵：压测、后台前台切换、低电量模式。
- 迁移要求：监控指标变更需兼容历史看板。
- 安全合规：监控上报数据脱敏。
- 反模式修复：线上常驻全量监控改为按开关采样。

#### XXFCompress
- 稳定性契约：输入输出格式与失败语义固定。
- 性能基线：压缩耗时、压缩率、视觉可接受度抽样。
- 可观测性：压缩成功率与失败原因。
- 测试矩阵：超大图、透明图、长图、低内存。
- 迁移要求：压缩策略变更需 AB 对比。
- 安全合规：临时文件与原图清理规则明确。
- 反模式修复：单一质量参数改为按场景分档配置。

#### 其他扩展模块
- 稳定性契约：实现层严格遵循抽象层协议。
- 性能基线：实现层关键指标与主模块同口径。
- 可观测性：实现层错误码可映射到抽象层。
- 测试矩阵：协议一致性与回归测试。
- 迁移要求：实现层升级需兼容抽象层最小版本。
- 安全合规：继承主模块安全基线并补充 SDK 特殊项。
- 反模式修复：实现层泄漏到业务层时，收口到抽象模块。

---

## 常见问题（FAQ）

### 1. 新项目应该直接用 `XXFArch` 还是按模块引入？

优先 `XXFArch` 快速起步；当业务边界稳定后，再做按需收敛以减少编译体积与依赖面。

### 2. 线上排查建议先接哪几个模块？

优先 `XXFLog`、`XXFPerformance`、`XXFTracker`。这三者组合可覆盖日志、性能、异常三条主链路。

### 3. 数据库该选 GRDB 还是 ObjectBox？

关系型查询与 SQL 可控性优先 `GRDB`；对象图建模、快速 CRUD 和迭代效率优先 `ObjectBox`。

---

## 贡献

欢迎提交 Issue 和 Pull Request！

---

## 许可证

本项目采用 MIT 许可证。

---

<p align="center">
  <strong>XXF iOS</strong> — 为构建卓越的 iOS/macOS 应用而生
</p>

<p align="center">
  <em>让开发者专注业务逻辑，而非重复造轮子</em>
</p>
