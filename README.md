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
  <img src="https://img.shields.io/badge/Modules-35+-purple.svg" alt="Modules">
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
| 自动布局代码冗长 | **SnapKit** - 声明式约束语法 |

### 核心优势

```
┌─────────────────────────────────────────────────────────────────────┐
│                         XXF iOS 核心优势                             │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ⚡ 极致性能        │  🧩 模块化设计      │  🛡️ 生产级质量          │
│  ─────────────     │  ─────────────     │  ─────────────          │
│  • XXH3 31.5GB/s  │  • 35+独立模块     │  • 线程安全保证          │
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

- [快速开始](#快速开始)
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
  - [XXFKeyboard - 键盘适配组件](#17-xxfkeyboard---键盘适配组件)
  - [XXFPerformance - 性能监控](#16-xxfperformance---性能监控)
  - [其他模块](#18-其他模块)
- [设计模式](#设计模式)
- [最佳实践](#最佳实践)
- [依赖关系](#依赖关系)

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
│    XXFReusable · XXFRefreshable · XXFAdapter · SnapKit · MJRefresh   │
│        ┌─────────────────────────────────────────────────┐          │
│        │    Cell复用、下拉刷新、数据源适配、自动布局         │          │
│        └─────────────────────────────────────────────────┘          │
└─────────────────────────────────────────────────────────────────────┘
```

---

## 模块详解

---

## 1. XXFFoundation - 基础设施层

整个框架的基石，提供最底层的基础类型、工具函数和并发安全的数据结构。

### 核心功能

| 功能 | 说明 |
|------|------|
| **Result 扩展** | Kotlin 风格链式调用：`getOrDefault`、`fold`、`onSuccess`、`recover` |
| **Try 工具函数** | 异常处理简化：`tryOrLog`、`tryOrNil`、`tryOrDefault` |
| **并发集合** | 线程安全：`ConcurrentDictionary`、`ConcurrentArray` |
| **不可变格式化器** | 线程安全：`ImmutableDateFormatter`、`ImmutableNumberFormatter` |
| **事件限制器** | `EventLimiter.debounce()`、`EventLimiter.throttle()` |

### Demo

```swift
// Result 扩展
let user = result.getOrDefault(User.guest)
let message = result.fold(
    onSuccess: { "欢迎，\($0.name)！" },
    onFailure: { "加载失败：\($0.localizedDescription)" }
)

// Try 工具
let content = tryOrLog { try String(contentsOfFile: path, encoding: .utf8) }

// 并发字典
let cache = ConcurrentDictionary<String, Data>()
cache["key"] = data  // 线程安全

// 搜索防抖
let search = EventLimiter.debounce(delay: 0.3) {
    api.search(keyword: searchField.text)
}
```

---

## 2. XXFFlow - 响应式流处理引擎

基于 RxSwift 提供 **64+ 增强操作符**，降低响应式编程学习曲线。

### 核心功能

| 操作 | 原生写法 | XXFFlow |
|------|---------|---------|
| 后台线程 | `subscribeOn(ConcurrentDispatchQueueScheduler(...))` | `subscribeOnIO()` |
| 主线程 | `observeOn(MainScheduler.instance)` | `observeOnMain()` |
| 错误降级 | `.catchError { _ in .just(default) }` | `.catchErrorJustReturn(default)` |
| 阻塞获取 | 复杂... | `.blockingGet(timeout:)` |
| 调试 | - | `.log("tag")` |

### Demo

```swift
api.fetchData()
    .subscribeOnIO()           // 后台执行
    .map { transform($0) }     // 后台处理
    .observeOnMain()           // 切换主线程
    .catchErrorJustReturn([])  // 错误降级
    .bindLifecycle(to: self)   // 自动释放
    .subscribe(onNext: { data in
        updateUI(data)
    })
    .disposed(by: disposeBag)
```

---

## 3. XXFHttp - 网络请求框架

基于 Moya + RxSwift，提供类型安全、自动缓存、**SSE 流式支持**、网络监控等企业级特性。

### 核心功能

```
┌────────────────────────────────────────────────────────────────┐
│                     XXFHttp 核心特性                            │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🌐 请求管理          │  💾 双层缓存          │  📡 SSE 支持     │
│  ─────────────       │  ─────────────       │  ─────────────   │
│  • API 服务池单例     │  • 内存+磁盘缓存      │  • 流式解析      │
│  • 连接复用          │  • 6种缓存策略        │  • 自动分块处理   │
│  • 动态 Host         │  • 自动回填机制       │  • 多行data合并  │
│                                                                 │
│  🔌 拦截系统          │  📊 监控日志                             │
│  ─────────────       │  ─────────────                          │
│  • RxCallAdapter     │  • Pulse 集成                           │
│  • 请求/响应拦截      │  • 网络状态监控                          │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### 缓存策略

| 策略 | 说明 |
|------|------|
| `firstCache` | 先返回缓存，再请求网络（可能发射2次） |
| `firstRemote` | 先请求网络，失败则返回缓存 |
| `onlyRemote` | 仅网络请求，不缓存 |
| `onlyCache` | 仅读取缓存，不请求网络 |
| `ifCache` | 有缓存用缓存，无缓存走网络 |
| `lastCache` | 网络优先，成功后缓存 |

### SSE (Server-Sent Events) 支持

```swift
// AI 流式对话示例
ChatAPI.apiService
    .requestStreamString(.streamChat(prompt: "Hello"))
    .mapSSEEventData()  // 解析 SSE 事件
    .subscribe(onNext: { event in
        print("Event: \(event.event ?? "message")")
        print("Data: \(event.data ?? "")")

        // 实时更新 UI
        appendToConversation(event.data)
    })
    .disposed(by: disposeBag)
```

### 普通请求示例

```swift
// 定义 API
enum UserAPI: RestApiService {
    case getProfile(userId: String)

    var cachePolicy: CacheType {
        return .firstCache(maxAge: 3600)  // 1小时缓存
    }
}

// 发起请求
UserAPI.apiService
    .request(.getProfile(userId: "123"))
    .mapHttpResponse(User.self)
    .subscribeOnIO()
    .observeOnMain()
    .subscribe(onNext: { user in
        // 可能收到 1-2 次（缓存+网络）
        updateProfile(user)
    })
    .disposed(by: disposeBag)
```

---

## 4. XXFRouter - 企业级路由框架

功能完备的 iOS/macOS 路由框架，支持**拦截器链**、**服务发现(SPI)**、**降级处理**、**防抖导航**等特性。

### 核心特性

```
┌────────────────────────────────────────────────────────────────┐
│                     XXFRouter 核心特性                          │
├────────────────────────────────────────────────────────────────┤
│                                                                 │
│  🔗 路由注册          │  🛡️ 拦截器链         │  📦 服务发现      │
│  ─────────────       │  ─────────────       │  ─────────────   │
│  • Routable 协议     │  • 登录拦截          │  • SPI 机制      │
│  • 闭包工厂          │  • VIP 拦截          │  • 多实现支持    │
│  • 批量注册          │  • 实名认证          │  • 别名映射      │
│  • 模块化分组        │  • 参数验证          │  • 单例/原型     │
│                      │  • 频率限制          │                  │
│                                                                 │
│  🔄 导航方式          │  ⚡ 性能优化          │  🛠️ 调试工具     │
│  ─────────────       │  ─────────────       │  ─────────────   │
│  • Push/Present     │  • 防抖导航          │  • 路由表打印    │
│  • Replace          │  • URL 高效匹配      │  • 日志监听      │
│  • ReplaceRoot      │  • 批量注册优化      │  • 完整回调      │
│  • async/await      │  • 线程安全          │                  │
│                                                                 │
└────────────────────────────────────────────────────────────────┘
```

### Demo

```swift
// 1. 定义 Routable 控制器
class ProfileViewController: UIViewController, Routable {
    static var routePattern: String { "app://profile/<userId>" }
    static var routeFlags: RouteFlags { .requiresLogin }

    required init?(context: RouteContext) {
        super.init(nibName: nil, bundle: nil)
        self.userId = context.string(for: "userId") ?? ""
    }
}

// 2. 注册路由
Router.shared.register(ProfileViewController.self)

// 批量注册
Router.shared.register([HomeVC.self, SettingsVC.self, ProfileVC.self])

// 模块化注册
Router.shared.group(name: "account", prefix: "app://account", sharedFlags: .requiresLogin) { group in
    group.register(pattern: "wallet") { _ in WalletViewController() }
    group.register(pattern: "orders") { _ in OrdersViewController() }
}

// 3. 配置拦截器
Router.shared.registerInterceptor(LoginCheckInterceptor(
    loginURL: "app://login",
    isLoggedIn: { UserManager.shared.isLoggedIn }
))

Router.shared.registerInterceptor(VIPCheckInterceptor(
    purchaseURL: "app://vip/purchase",
    isVIP: { UserManager.shared.isVIP }
))

// 4. 导航
Router.shared.navigate(to: "app://profile/123")

Router.shared.navigate(to: "app://profile/123") { result in
    switch result {
    case .success(let vc): print("Success")
    case .intercepted(let reason): print("Intercepted: \(reason)")
    case .failure(let error): print("Failed: \(error)")
    }
}

// 5. 简化 API（从 ViewController）
self.navigate(to: "app://settings", options: .pushHideTabBar)
self.pop(options: .toRoot)

// 6. async/await
let result = await Router.shared.navigate(to: "app://profile/123")
```

### 内置拦截器

| 拦截器 | 功能 |
|--------|------|
| `LoginCheckInterceptor` | 登录检查，未登录重定向到登录页 |
| `VIPCheckInterceptor` | VIP 权限检查 |
| `RealNameCheckInterceptor` | 实名认证检查 |
| `SingletonRouteInterceptor` | 单例页面（防止重复打开） |
| `ParameterValidationInterceptor` | 参数验证 |
| `AnalyticsInterceptor` | 埋点统计 |
| `RateLimitInterceptor` | 频率限制 |

---

## 5. XXFDatabase - 数据库抽象层

采用 **Repository 模式**，提供优雅的数据库抽象层。配合 **XXFDatabaseGrdb** 实现。

### Demo

```swift
// 定义实体
struct User: Codable, FetchableRecord, PersistableRecord {
    var id: String
    var name: String
    var age: Int
}

// CRUD 一行代码
let repo = UserRepository.shared
repo.insertOrUpdate(user)
let user = repo.selectById("123")
let adults = repo.selectList { $0.filter(Column("age") >= 18) }
let page = repo.selectPage(page: 1, pageSize: 20)
repo.delete(id: "123")
```

---

## 6. XXFBus - 事件总线

基于 RxSwift 的轻量级事件总线，支持**普通事件**和**黏性事件**。

### Demo

```swift
// 定义事件
struct UserLoginEvent { let user: User }

// 发送事件
RxBus.shared.post(UserLoginEvent(user: currentUser))

// 监听事件
RxBus.shared.observe(UserLoginEvent.self)
    .observeOnMain()
    .subscribe(onNext: { event in
        updateUI(for: event.user)
    })
    .disposed(by: disposeBag)

// 黏性事件：新订阅者立即收到最后一条
RxBus.shared.postSticky(ThemeChangedEvent(theme: .dark))
```

---

## 7. XXFCache - 缓存系统

声明式的键值对存储，通过 **@PreferenceWrapper** 属性包装器实现。

### Demo

```swift
class UserPreferences {
    @PreferenceWrapper(nil, "access_token")
    var accessToken: String?

    @PreferenceWrapper(false, "dark_mode")
    var darkMode: Bool

    @PreferenceWrapper(User.guest, "current_user")
    var currentUser: User  // 自动 JSON 编解码
}

// 使用
let prefs = UserPreferences()
prefs.accessToken = "new_token"  // 自动持久化
print(prefs.darkMode)            // 类型安全

// Combine 监听
prefs.$darkMode.sink { isDark in
    updateAppearance(isDark)
}
```

---

## 8. XXFLog - 日志系统

专业的日志管理系统，支持**多 Handler 架构**、**文件持久化**、**Pulse 可视化**。

### Demo

```swift
// 初始化
LogUtils.initialize(
    enableCacheFile: true,
    enableMemoryCache: true,
    enableCrashCache: true
)

// 使用
logD { "调试信息" }
logI { "用户登录成功" }
logW { "配置缺失，使用默认值" }
logE { "网络请求失败: \(error)" }

// 带 Tag
logI(tag: "Network") { "请求开始: \(url)" }
```

---

## 9. XXFJson - JSON处理

高性能、线程安全的 JSON 编解码，通过**线程本地缓存**优化性能。

### Demo

```swift
let user: User = try Json.fromJson(jsonString)
let json = try Json.toJson(user)
let copy: User = try Json.copy(original)  // 深拷贝
```

---

## 10. XXFSpeed - 高性能工具

提供 **LRU 缓存** 和 **XXH3 哈希算法**。

### 性能数据

```
Hash 算法吞吐量:
XXH3      31.5 GB/s  ████████████████████████████████████
MD5        3.2 GB/s  ████
SHA256     2.1 GB/s  ██

LRU 缓存操作:
读取 (get)     O(1)  ~50ns
写入 (set)     O(1)  ~80ns
```

### Demo

```swift
// LRU 缓存
let cache = LRUCache<String, Data>(maxCount: 100, maxCost: 50 * 1024 * 1024)
cache.set("key", data, cost: data.count)
let data = cache.get("key")

// XXH3 哈希
let hash = XXH3.hash(data)
```

---

## 11. XXFReusable - Cell复用系统

UITableView/UICollectionView Cell 的**自动注册**和**类型安全出队**。

### 特色功能

- **自动协议实现**：UITableViewCell/UICollectionViewCell 自动遵循 Reusable
- **自动注册**：dequeue 时自动检测并注册
- **类型安全**：泛型返回，无需强制转换
- **NIB 支持**：NibLoadable / NibOwnerLoadable

### Demo

```swift
// 定义 Cell（自动实现 Reusable）
class MyCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
}

// 使用 - 无需手动注册！
func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell: MyCell = tableView.dequeueReusableCell(for: indexPath)
    cell.titleLabel.text = "Hello"
    return cell
}

// NIB Cell
class MyNibCell: UITableViewCell, NibLoadable {
    // 自动查找同名 NIB 文件
}

// CollectionView 同样支持
let cell: MyCollectionCell = collectionView.dequeueReusableCell(for: indexPath)

// Header/Footer
let header: MyHeader = tableView.dequeueReusableHeaderFooterView()
```

---

## 12. XXFRefreshable - 下拉刷新组件

基于 MJRefresh 的**状态机管理**和 **RxSwift 集成**。

### 特色功能

- **状态互斥**：刷新和加载自动互斥
- **自动冲突处理**：内置防冲突逻辑
- **异步流集成**：`bindRefreshableState` 自动管理状态

### Demo

```swift
class ListViewController: UIViewController {
    var refreshableState = RefreshableState().obs

    override func viewDidLoad() {
        super.viewDidLoad()

        // 绑定状态到 UI
        refreshableState
            .bind(to: tableView.rx.refreshableState)
            .disposed(by: disposeBag)

        // 下拉刷新
        tableView.addRefreshing { [weak self] in
            self?.refreshData()
        }

        // 上拉加载
        tableView.addLoadingMore { [weak self] in
            self?.loadMoreData()
        }
    }

    func refreshData() {
        APIService.fetchList(page: 1)
            .bindRefreshableState(of: refreshableState, isRefresh: true)
            .subscribe(onNext: { [weak self] items in
                self?.dataList = items
            })
            .disposed(by: disposeBag)
    }
}
```

---

## 13. XXFAdapter - DiffableDataSource适配器

基于 iOS 13+ DiffableDataSource 的现代化适配器。

### 特色功能

- **主线程安全**：自动在主线程执行
- **统一 API**：UITableView/UICollectionView 接口一致
- **类型安全**：泛型 Section 和 Item

### Demo

```swift
// 创建 DataSource
var dataSource: UITableViewDiffableDataSource<SingleSection, Product>?

dataSource = UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, product in
    let cell: ProductCell = tableView.dequeueReusableCell(for: indexPath)
    cell.configure(with: product)
    return cell
}

// CRUD 操作
dataSource?.appendItems(products, to: .main, animatingDifferences: true)
dataSource?.replaceItems(newProducts, in: .main, animatingDifferences: true)
dataSource?.deleteItems(where: { $0.isExpired }, animatingDifferences: true)
dataSource?.moveItem(item, after: targetItem)

// 查询
let product = dataSource?.item(at: indexPath)
let hasSection = dataSource?.hasSection(.main) ?? false
```

---

## 14. XXFSwiftFormat - 代码格式化

提供统一的 SwiftFormat 配置文件和路径获取 API。

### Demo

```swift
// 获取配置文件路径
let configPath = SwiftFormatConfig.path

// 在 Xcode Run Script 中使用
// swiftformat --config "$CONFIG_PATH" "$SRCROOT"
```

### 配置规则

- 4 空格缩进
- 禁用 redundantSelf、redundantReturn
- 排除 Pods、.git、DerivedData 等目录
- LF 换行符

---

## 15. XXFImageEditor - 图片编辑/裁切

可替换的图片编辑/裁切门面，外部代码与底层编辑库完全解耦，后期可无缝切换实现。

### 架构设计

```
XXFImageEditor                     ← 公共 API 层（无第三方依赖）
    ImageEditor (门面单例)
    ImageEditorProvider (协议)
    ImageEditorConfiguration / ImageCropConfiguration
    ImageEditorResult / ImageEditorError

XXFImageEditorBrightroom            ← Brightroom 实现（iOS 16+）
    BrightroomImageEditorProvider
```

与 `XXFImageLoader → XXFImageNukeLoader` 完全相同的分层模式，切换底层库只需替换一个 provider 赋值，调用方代码零改动。

### 安装

```swift
// Package.swift
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            "XXFImageEditor",           // 公共 API（调用方）
            "XXFImageEditorBrightroom"  // Brightroom 实现（注册方，通常仅在 App target）
        ]
    )
]
```

> **注意**：`XXFImageEditorBrightroom` 基于 [Brightroom](https://github.com/FluidGroup/Brightroom) 2.x，要求 **iOS 13+**，与主项目 iOS 15+ 完全兼容。
> `XXFImageEditor` 本身不依赖任何第三方库，可在 iOS 15+ 使用。

### 配置（只需一次）

```swift
// AppDelegate / @main，在使用前注册 provider
import XXFImageEditorBrightroom

if #available(iOS 16, *) {
    ImageEditor.shared.provider = BrightroomImageEditorProvider()
}
```

### 图片裁切

```swift
import XXFImageEditor

// 自由比例裁切（默认）
ImageEditor.shared.presentCrop(from: self, image: photo) { result in
    switch result {
    case .success(let r):
        // r.image — 裁切后的 UIImage
        imageView.image = r.image
    case .failure(.cancelled):
        break  // 用户取消，可安全忽略
    case .failure(let e):
        print(e.localizedDescription)
    }
}

// 固定 16:9 比例
ImageEditor.shared.presentCrop(
    from: self,
    image: photo,
    configuration: ImageCropConfiguration(aspectRatio: .ratio(width: 16, height: 9))
) { result in ... }

// 正方形（头像场景）
ImageEditor.shared.presentCrop(
    from: self,
    image: photo,
    configuration: ImageCropConfiguration(aspectRatio: .square)
) { result in ... }
```

### 完整编辑器（滤镜 + 调色 + 裁切）

```swift
ImageEditor.shared.presentEditor(from: self, image: photo) { result in
    switch result {
    case .success(let r): saveImage(r.image)
    case .failure(.cancelled): break
    case .failure(let e): showAlert(e)
    }
}
```

### 宽高比选项

| 枚举值 | 效果 |
|--------|------|
| `.freeform`（默认） | 自由比例，显示比例选择器 |
| `.square` | 锁定 1:1 正方形 |
| `.ratio(width: 16, height: 9)` | 锁定指定整数比例 |

### 替换底层库（隔离性演示）

```swift
// 替换为其他实现，调用方代码完全不需要改动
ImageEditor.shared.provider = CustomImageEditorProvider()
```

自定义 Provider 只需实现两个方法：

```swift
@MainActor
class CustomImageEditorProvider: ImageEditorProvider {

    func makeEditorViewController(
        image: UIImage,
        configuration: ImageEditorConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController {
        // 返回自定义编辑 VC
    }

    func makeCropViewController(
        image: UIImage,
        configuration: ImageCropConfiguration,
        completion: @escaping @Sendable (Result<ImageEditorResult, ImageEditorError>) -> Void
    ) -> UIViewController {
        // 返回自定义裁切 VC
    }
}
```

---

## 17. XXFKeyboard - 键盘适配组件

基于 [RxKeyboard](https://github.com/RxSwiftCommunity/RxKeyboard) 的键盘适配组件，提供类似 Android `adjustPan` 模式的容器视图。

### 架构设计

```
XXFKeyboard
├── KeyboardResizeContainer    ← 核心容器（自动调整高度适配键盘）
├── XXFKeyboard                ← 模块入口（暴露 RxKeyboard 单例）
└── RxKeyboard                 ← 底层依赖（键盘事件响应式封装）
```

### 核心特性

| 特性 | 说明 |
|------|------|
| **自动高度调整** | 容器高度自动减去键盘高度 |
| **动画同步** | 完美同步键盘动画曲线和时长 |
| **响应式 API** | 基于 RxSwift/RxKeyboard |
| **ScrollView 支持** | 自动处理 contentInset 和 contentOffset |
| **点击收起键盘** | 内置 tap gesture 收起键盘 |

### 使用示例

#### 基础用法

```swift
import XXFKeyboard

class ViewController: UIViewController {
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        // 创建容器
        let container = KeyboardResizeContainer()
        view.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // 绑定内容视图
        let contentView = UIView()
        container.bindContentView(contentView)

        // 添加输入框
        let textField = UITextField()
        contentView.addSubview(textField)

        // 点击空白处收起键盘
        container.addTapToDismiss()
    }
}
```

#### 带 ScrollView 的用法

```swift
class FormViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let container = KeyboardResizeContainer()
        view.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        // 绑定 scrollView，自动处理键盘遮挡
        container.bindContentView(scrollView)
        container.bindScrollView(scrollView)

        // 添加内容...
        container.addTapToDismiss()
    }
}
```

#### 订阅键盘事件

```swift
// 通过 XXFKeyboard 单例
XXFKeyboard.instance.visibleHeight
    .drive(onNext: { height in
        print("键盘高度：\(height)")
    })
    .disposed(by: disposeBag)

// 通过容器
container.keyboardVisibleHeight
    .drive(onNext: { height in
        // 调整 UI
    })
    .disposed(by: disposeBag)
```

#### 类似消息列表的布局

```swift
class MessageViewController: UIViewController {
    private let tableView = UITableView()
    private let inputContainer = UIView()
    private let textField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()

        let container = KeyboardResizeContainer()
        view.addSubview(container)
        container.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

        let contentView = UIView()
        container.bindContentView(contentView)

        // TableView
        contentView.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputContainer.snp.top)
        }

        // 底部输入区
        contentView.addSubview(inputContainer)
        inputContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(50)
        }

        container.bindScrollView(tableView)
    }
}
```

### API 参考

#### KeyboardResizeContainer

| 属性/方法 | 说明 |
|-----------|------|
| `keyboardVisibleHeight` | 键盘可见高度（Driver<CGFloat>） |
| `keyboardFrame` | 键盘 frame（Driver<CGRect>） |
| `currentKeyboardHeight` | 当前键盘高度 |
| `bindContentView(_:)` | 绑定内容视图 |
| `bindScrollView(_:)` | 绑定 ScrollView，自动处理 inset/offset |
| `bindTextField(_:)` | 绑定 TextField |
| `bindTextView(_:)` | 绑定 TextView |
| `addTapToDismiss()` | 点击空白处收起键盘 |
| `static create(in:contentView:edges:)` | 便捷创建方法 |

### 安装

```swift
// Package.swift
dependencies: [
    .package(url: "https://github.com/RxSwiftCommunity/RxKeyboard.git", from: "2.0.0")
]

targets: [
    .target(
        name: "YourTarget",
        dependencies: ["XXFKeyboard"]
    )
]
```

### 平台支持

- **iOS 15.0+**
- 依赖：RxSwift 6.x, RxCocoa, RxKeyboard 2.x, SnapKit

---

## 16. XXFPerformance - 性能监控

提供**主线程卡顿检测**和 **FPS/CPU/内存实时监控悬浮窗**，采用协议抽象设计，底层可替换。

### 架构设计

```
XXFPerformance
├── BlockWatcher            ← 主线程卡顿检测（watchdog 模式）
├── PerformanceMonitoring   ← 监控协议（抽象层）
│   ├── PerformanceReport / PerformanceDisplayOptions / PerformanceViewStyle
│   └── PerformanceMonitoring (protocol)
└── GDPerformanceMonitorView ← GDPerformanceView-Swift 实现（iOS only）
```

### 使用

```swift
// 1. 卡顿检测（iOS/macOS）
let _ = BlockWatcher(threshold: 0.4)  // 主线程阻塞超过 0.4s 告警

// 2. FPS/CPU/内存悬浮窗（iOS only）
// 启动（默认显示 FPS + CPU + 应用版本 + 系统版本）
GDPerformanceMonitorView.shared.start()

// 自定义选项和样式
GDPerformanceMonitorView.shared.start(options: .all, style: .light)

// 控制显示/隐藏
GDPerformanceMonitorView.shared.hide()
GDPerformanceMonitorView.shared.show()

// 暂停/恢复
GDPerformanceMonitorView.shared.pause()

// 性能数据回调
GDPerformanceMonitorView.shared.onReport = { report in
    print("CPU: \(report.cpuUsage)%, FPS: \(report.fps), Memory: \(report.memoryUsed)")
}
```

### 面向协议编程

业务层通过 `PerformanceMonitoring` 协议访问，替换底层实现无需修改调用方：

```swift
// 通过协议引用（方便替换实现）
let monitor: PerformanceMonitoring = GDPerformanceMonitorView.shared
monitor.start()
```

---

## 17. 其他模块

| 模块 | 核心功能 | 亮点 |
|------|---------|------|
| **XXFViewModel** | MVVM 架构 | 自动生命周期管理 |
| **XXFHud** | 提示组件 | Toast/Progress/Error HUD |
| **XXFImageLoader** | 图片加载 | 适配器模式，支持 Nuke |
| **XXFImageEditor** | 图片编辑/裁切 | 可替换 Provider，隔离 Brightroom |
| **XXFKeyboard** | 键盘适配 | RxKeyboard 封装，adjustPan 模式 |
| **XXFTracker** | 错误追踪 | Sentry/Bugsnag 支持 |
| **XXFKeychain** | 安全存储 | Codable 支持 |
| **XXFIdentifier** | 设备标识 | UUID 持久化 |
| **XXFPerformance** | 性能监控 | 主线程卡顿检测 + FPS/CPU/内存悬浮窗 |
| **XXFServer** | 内嵌服务器 | Vapor 驱动 |
| **XXFDi** | 依赖注入 | Factory 封装 |
| **SnapKit** | 自动布局 | 声明式约束语法 |

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
| GRDB.swift | 数据库 | 7.x |
| Factory | 依赖注入 | 2.x |
| swift-log | 日志标准 | 1.x |
| Pulse | 日志可视化 | 4.x |
| Nuke | 图片加载 | 12.x |
| Brightroom | 图片编辑/裁切 | 2.x |
| RxKeyboard | 键盘事件响应式封装 | 2.x |
| GDPerformanceView-Swift | FPS/CPU/内存监控悬浮窗 | 2.x |
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
│   └── XXFDatabaseGrdb (GRDB)
├── XXFReusable (Cell 复用)
├── XXFRefreshable (下拉刷新)
│   └── MJRefresh
├── XXFAdapter (DiffableDataSource)
├── XXFBus (RxSwift)
├── XXFCache
├── XXFLog (swift-log + Pulse)
├── XXFJson
├── XXFSpeed (XXHash)
├── XXFSwiftFormat
├── XXFUIKit
├── XXFImageLoader ────────── XXFImageNukeLoader (Nuke)
├── XXFImageEditor ────────── XXFImageEditorBrightroom (Brightroom 2.x)
├── XXFKeyboard ───────────── RxKeyboard (2.x)
├── XXFPerformance (BlockWatcher + GDPerformanceView-Swift)
├── SnapKit
└── ...
```

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
