---
name: xxf-aaa-class-declaration-guidelines
description: 规范 ViewController 与 ViewModel 的分区组织方式。用于治理成员变量和方法过多、顺序混乱、阅读成本高的问题；通过 MARK 分区和职责分层保持代码导航清晰。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# VC/VM 分区治理（ViewController and ViewModel Partition）

## 触发场景

- 一个 VC 或 ViewModel 成员变量很多，阅读时找不到重点
- 方法越来越多，初始化、事件、业务逻辑混在一起
- 同一文件里的属性和方法顺序混乱，review 成本高
- 需要统一 VC/VM 的 MARK 分区结构

## 核心目标

让 VC/VM 在大纲中可快速导航：

1. 变量按职责分区，不按“写代码顺手顺序”堆放。
2. 方法按业务职责分区，初始化、绑定、事件、数据、渲染分离。
3. 分区命名稳定，跨页面结构一致。
4. 每个声明（字段和方法）都有注释，读代码时无需反向猜测用途。

## Swift 文件头注释规则（强制）

适用范围：新建或重命名的 VC/VM 主文件与职责 extension 文件（如 `XxxViewController.swift`、`XxxViewModel.swift`、`XxxViewController+UI.swift`）。

- 文件顶部必须包含以下头注释结构（字段顺序固定）：

```swift
//
//  文件名.swift
//  项目名
//
//  Created by git用户名 on 年/月/日
//  作用（一句话介绍）
//
```

- 禁止提交仍含占位词的头注释：`文件名.swift`、`项目名`、`git用户名`、`年/月/日`、`作用（一句话介绍）`。
- `作用`必须一句话写清该文件唯一职责，禁止空泛描述（如“处理逻辑”“相关代码”）。

### 自动推断与填充规则（vibecoding）

生成 Swift 文件时按以下顺序自动填充：

1. `文件名.swift`：使用当前真实文件名，并保持与主类型名一致（遵循 `xxf-aaa-coding-style`）。
2. `项目名`：优先使用当前 target/module 名；无法确定时回退为仓库目录名 `xxf_ios`。
3. `git用户名`：优先 `git config user.name`；为空时回退 `git config user.email` 的本地部分；仍为空则使用系统用户名。
4. `年/月/日`：使用当前本地日期，格式固定为 `yyyy/MM/dd`（示例：`2026/05/21`）。
5. `作用（一句话介绍）`：根据主类型与文件职责自动推断并填充，不可留空。
6. 若上下文不足以精确命名场景，至少基于类型名生成可读职责描述，禁止保留模板占位文案。

建议推断模板：

- `*ViewController.swift`：负责 `<页面/场景>` 的展示、交互与生命周期编排。
- `*ViewModel.swift`：负责 `<页面/场景>` 的状态管理、输入处理与数据编排。
- `+UI.swift`：扩展 `<主类型>` 的 UI 搭建与布局职责。
- `+Bind.swift`：扩展 `<主类型>` 的状态绑定与事件绑定职责。
- `+Event.swift`：扩展 `<主类型>` 的事件处理职责。
- `+Data.swift`：扩展 `<主类型>` 的数据请求与数据组装职责。
- `+Actions.swift`：扩展 `<主类型>` 的交互响应职责。

## 声明注释规则（强制）

- 每个字段都要有注释，说明“存的是什么、给谁用、何时变化”。
- 每个方法都要有注释，说明“做什么、输入输出、关键副作用”。
- 优先使用 `///` 文档注释，不要只写无信息注释（如“按钮点击”）。

示例：

```swift
// MARK: - Business State

/// 当前分页页码。首屏为 1，成功加载下一页后递增。
var pageIndex: Int = 1

/// 是否还有更多数据可加载。由服务端分页结果更新。
var hasMore = true

// MARK: - Data Request

/// 拉取下一页数据并合并到现有列表。
/// - Note: 该方法会更新 `pageIndex` 与 `hasMore`，并触发输出状态变化。
func loadNextPage() { ... }
```

## VC 变量分区规则（强制）

至少按以下类别分区：

1. 页面入参（从外部页面或路由传入）
2. UI 组件（按钮、列表、容器等）
3. 业务状态（状态机、计数、选中态、缓存态）
4. 依赖对象（ViewModel、Service、Repository、Coordinator）

示例：

```swift
final class OrderDetailViewController: UIViewController {

    // MARK: - Input

    /// 订单 ID，由上一个页面或路由传入，用于请求详情。
    var orderID: String
    /// 进入来源，用于埋点和页面行为差异处理。
    var source: OrderSource

    // MARK: - UI

    /// 页面标题，用于展示订单核心信息。
    private lazy var titleLabel = UILabel()
    /// 支付按钮，触发支付动作。
    private lazy var payButton = UIButton(type: .system)
    /// 详情列表容器，承载明细模块。
    private lazy var tableView = UITableView()

    // MARK: - State

    /// 页面当前状态，用于驱动渲染。
    private var state: ViewState = .idle
    /// 当前已选优惠数量，影响按钮文案和金额展示。
    private var selectedCouponCount = 0

    // MARK: - Dependencies

    /// 详情页业务逻辑入口，负责数据请求与状态产出。
    private let viewModel: OrderDetailViewModel
}
```

## 方法分区规则（强制）

至少按以下类别分区：

1. Lifecycle
2. Setup UI
3. Bind / Event
4. Data / Request
5. Render / State Apply
6. Action Handler
7. Private Helper

示例：

```swift
// MARK: - Lifecycle
/// 页面加载入口：初始化视图、绑定事件并触发首屏请求。
override func viewDidLoad() { ... }

// MARK: - Setup UI
/// 搭建页面 UI 组件层级与样式。
private func setupUI() { ... }
/// 设置布局约束与安全区适配。
private func setupLayout() { ... }

// MARK: - Bind
/// 绑定 ViewModel 状态输出到 UI 渲染逻辑。
private func bindViewModel() { ... }
/// 绑定按钮点击、手势等用户事件。
private func bindActions() { ... }

// MARK: - Data
/// 拉取页面所需数据并驱动状态更新。
private func fetchData() { ... }

// MARK: - Render
/// 根据状态刷新页面内容与交互可用性。
private func render(_ state: ViewState) { ... }

// MARK: - Actions
/// 处理支付按钮点击事件并发起支付流程。
@objc private func payButtonTapped() { ... }

// MARK: - Helpers
/// 生成价格富文本展示内容。
private func makePriceText() -> NSAttributedString { ... }
```

## ViewModel 变量分区规则（强制）

至少按以下类别分区：

1. Input（外部输入、路由参数、初始化参数）
2. Output State（可观察状态流，如 `Obs` / `Flow` / `Driver`）
3. Business State（分页、筛选、缓存标志、加载状态）
4. Dependencies（Repository、Service、UseCase）

示例（对应你给的场景）：

```swift
final class OrderListViewModel {

    // MARK: - Input

    /// 搜索关键词输入，用于构建查询条件。
    var keyword: String
    /// 页面来源输入，影响默认筛选策略。
    var source: EntrySource

    // MARK: - Output State

    /// 文本状态 A，对外暴露给 View 层订阅。
    var stateA: Obs<String>
    /// 文本状态 B，对外暴露给 View 层订阅。
    var stateB: Obs<String>

    // MARK: - Business State

    /// 当前分页页码，首屏为 1。
    var pageIndex: Int = 1
    /// 是否还有下一页数据可继续加载。
    var hasMore = true

    // MARK: - Dependencies

    /// 数据仓库依赖，负责请求与持久化访问。
    private let repository: OrderRepository
}
```

## ViewModel 方法分区规则（强制）

至少按以下类别分区：

1. Lifecycle / Setup
2. Input Handling（处理 Action/Intent）
3. Data Request（请求与分页）
4. State Mutation / Reduce（更新状态）
5. Output / Notify（向外发出状态或事件）
6. Private Helper

示例：

```swift
// MARK: - Lifecycle
/// 初始化 ViewModel 默认状态与必要订阅。
func setup() { ... }

// MARK: - Input Handling
/// 处理刷新意图，重置分页并拉取首屏数据。
func didTapRefresh() { ... }
/// 处理关键词变更并触发重新查询。
func didChangeKeyword(_ keyword: String) { ... }

// MARK: - Data Request
/// 加载第一页数据并覆盖当前列表状态。
func loadFirstPage() { ... }
/// 加载下一页数据并追加到现有列表。
func loadNextPage() { ... }

// MARK: - State Mutation
/// 合并分页结果并更新 `pageIndex` / `hasMore`。
private func applyPageResult(_ result: PageResult) { ... }

// MARK: - Output
/// 发出错误事件供 View 层展示错误态或提示。
private func emitError(_ error: Error) { ... }

// MARK: - Helpers
/// 构建请求查询参数，屏蔽上层组装细节。
private func buildQuery() -> Query { ... }
```

## 扩展分区规则

当方法增长后，优先按 extension 职责拆分到独立文件：

- `XxxViewController+UI.swift`
- `XxxViewController+Bind.swift`
- `XxxViewController+Event.swift`
- `XxxViewController+Actions.swift`
- `XxxViewController+Data.swift`

同一 extension 文件内部仍需 MARK 分区，避免“拆了文件但文件内部继续混乱”。

## 治理动作

当命中触发场景时，本 skill 的默认动作：

1. 若涉及新建/重命名 Swift 文件，先生成并补全标准文件头注释（含自动推断字段）。
2. 识别当前 VC/VM 的属性和方法职责。
3. 在不改变业务行为前提下重排顺序并补 MARK。
4. 为缺失注释的字段和方法补齐用途说明与关键副作用说明。
5. 合并重复或语义重叠的分区名（如 UIInit/UISetup 统一为 Setup UI）。
6. 若单文件持续膨胀，提出 extension 拆分并执行最小可行拆分。

## 命名建议

- 分区名用稳定词汇，避免同义词乱用：
  - VC 维度：`Input`、`UI`、`State`、`Dependencies`
  - VM 维度：`Input`、`Output State`、`Business State`、`Dependencies`
  - 方法维度：`Lifecycle`、`Setup UI`、`Bind`、`Data`、`Render`、`Actions`、`Helpers`
- 不要使用无信息分区名，如 `Other`、`Temp`、`Misc`。

## 与其他 skill 的关系

- 代码总流程由 `xxf-aaa-delivery-loop` 编排
- 通用风格规则由 `xxf-aaa-coding-style` 约束
- 架构边界问题由 `xxf-aaa-coding-arch` / `xxf-aaa-architecture-review` 处理
- ViewModel 基础用法由 `xxf-viewmodel` 约束

## 非目标

- 不做业务逻辑重写
- 不为了分区而引入大规模重构
- 不改变公开 API 或页面行为
