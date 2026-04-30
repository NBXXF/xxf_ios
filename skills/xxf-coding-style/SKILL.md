---
name: xxf-coding-style
description: xxf_ios 项目的 iOS/Swift 编码规范（强制约束）——文件组织与拆分、命名、注释、访问控制。写 Swift 代码时必须遵守。
---

# iOS/Swift 基础编码规范（强制约束）

> **适用范围**：本规范为强制约束。在本项目编写、修改任何 Swift 代码时，必须遵守以下规则。违反时应主动修正，不要沉默通过。

---

## 1. 文件组织与拆分

### 1.1 核心原则：分而治之（Divide and Conquer）

**所有内容都尽可能按职责拆分到独立文件，不要揉到一个 Swift 文件里。** 每个文件职责单一、边界清晰，是本项目文件组织的第一原则。

- 一个文件只承载**一个核心类型**（类/结构体/枚举/协议）
- 不同类型、不同职责的代码**一律分文件**，不要图"顺手"塞在一起
- 主类型的 extension 按职责/协议边界**继续往下拆**（详见 1.2）

```swift
// ✅ UserProfileViewController.swift —— 只承载 UserProfileViewController
// ✅ OrderModel.swift —— 只承载 OrderModel（及其私有嵌套类型）
// ✅ OrderListSection.swift —— 单独一个枚举也要独立成文件
// ❌ Helpers.swift —— 堆放各种无关工具（禁止）
// ❌ OrderModels.swift —— 一个文件塞 OrderModel + CartModel + PaymentModel（禁止）
```

### 1.2 主类的 Extension 必须按职责拆分到独立文件

**强制要求:主类的扩展(extension)必须按功能 / 协议边界抽离为独立文件。** 禁止把多个 extension 堆在主类文件内 —— 主文件快速膨胀、阅读与导航成本剧增,review diff 也会失焦。

**理由**:
- 主文件只保留核心属性、init、生命周期,阅读主干逻辑时无需在上千行里滚动
- 功能变更时,相关文件的 diff 聚焦、review 成本低
- 协议实现独立成文件后,职责边界更清晰,不易出现"一个方法被多处 extension 重复覆盖"

**命名约定**:`主类型名+职责.swift`,职责名用 UpperCamelCase:

```
UserProfileViewController.swift              // 属性、init、生命周期
UserProfileViewController+UI.swift           // UI 搭建与布局
UserProfileViewController+TableView.swift    // UITableView DataSource / Delegate
UserProfileViewController+Network.swift      // 数据请求
UserProfileViewController+Actions.swift      // @objc / IBAction 事件响应
UserProfileViewController+Event.swift        // 通知 / 业务事件处理
UserProfileViewController+Prefetch.swift     // 列表预取 / 预加载
```

```swift
// ✅ UserProfileViewController.swift —— 只保留核心
final class UserProfileViewController: UIViewController {

    // MARK: - Properties
    private let viewModel = UserProfileViewModel()
    private lazy var tableView = UITableView()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        fetchData()
    }
}
```

```swift
// ✅ UserProfileViewController+TableView.swift —— 协议实现独立
extension UserProfileViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { ... }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { ... }
}
```

```swift
// ❌ 禁止:所有 extension 堆在主文件里
// UserProfileViewController.swift(1200+ 行)
class UserProfileViewController: UIViewController { ... }
extension UserProfileViewController { /* UI */ }
extension UserProfileViewController: UITableViewDataSource { ... }
extension UserProfileViewController: UITableViewDelegate { ... }
extension UserProfileViewController { /* Network */ }
extension UserProfileViewController { /* Actions */ }
```

**唯一豁免情形**(需同时满足):
- 主文件 < 200 行 **且** 只有 1 个极小 extension(< 20 行)
- extension 仅是 1~2 个紧贴核心逻辑的私有辅助方法
- 该 extension 依赖主类的 `private` 成员,拆出会被迫放宽为 `fileprivate`(此时优先保持封装性可留本文件,但需 MARK 分区)

### 1.3 拆分粒度建议

按以下维度拆分，避免过细（每个文件只装一两个方法）也避免过粗（一个文件包含多种无关职责）：

1. **协议一致性**：每个重要协议实现独立一个文件，如 `+TableView.swift`、`+CollectionView.swift`、`+ScrollViewDelegate.swift`
2. **功能模块**：`+UI.swift`（布局）、`+Network.swift`（数据请求）、`+Actions.swift`（交互响应）
3. **系统类型 / 第三方类型扩展**：如 `UIView+Snap.swift`、`String+Validation.swift`
4. **Model 协议实现**：`OrderModel+Codable.swift`、`OrderModel+Hashable.swift`

**访问权限注意**：private 成员在 Swift 中跨文件 extension 不可见。如果 extension 需要访问主类的私有属性，要么将该属性改为 `fileprivate`（仅限本类型真正需要的内部共享），要么在 extension 中定义独立的辅助方法。优先保持 private，只有在拆分后的 extension 确实需要访问时才放宽。

### 1.4 使用 MARK 组织长文件

长文件必须用 `// MARK: -` 分区，让大纲清晰：

```swift
class OrderListViewController: UIViewController {

    // MARK: - Properties

    private let viewModel = OrderListViewModel()
    private var dataSource: UITableViewDiffableDataSource<Section, Item>!

    // MARK: - Lifecycle

    override func viewDidLoad() { ... }
    override func viewWillAppear(_ animated: Bool) { ... }

    // MARK: - UI Setup

    private func setupUI() { ... }
    private func setupNavigationBar() { ... }

    // MARK: - Data

    private func fetchOrders() { ... }

    // MARK: - Actions

    @objc private func refreshTapped() { ... }
}

// MARK: - UITableViewDelegate

extension OrderListViewController: UITableViewDelegate { ... }
```

**MARK 分区推荐顺序**：Properties → Lifecycle → UI Setup → Data → Actions → Helpers → 协议实现 extension。

### 1.5 文件大小参考（非硬性上限）

得益于"分而治之"原则，单文件通常应保持较小：

- 单文件 < 200 行：理想区间
- 200 ~ 400 行：可接受，但应检查是否还能按职责继续拆分
- \> 400 行：**必须评估拆分**。优先拆 extension 到独立文件，其次考虑拆子组件（子 ViewController / 子 View / 子 ViewModel）

---

## 2. 命名规范

### 2.1 基本规则

| 类别 | 规则 | 示例 |
|---|---|---|
| 类 / 结构体 / 枚举 / 协议 | UpperCamelCase | `OrderListViewController`、`UserProfile`、`PaymentType` |
| 方法 / 属性 / 变量 / 枚举 case | lowerCamelCase | `fetchOrders()`、`isLoading`、`.success` |
| 常量（全局/静态） | lowerCamelCase（不要用 `k` 前缀、不要全大写） | `static let defaultTimeout = 15.0` |
| 泛型参数 | 单字母或 UpperCamelCase | `T`、`Element`、`Response` |
| 布尔变量 / 方法 | is / has / should / can 开头 | `isHidden`、`hasLoaded`、`shouldRefresh` |

### 2.2 文件名与主类型同名

文件名必须与其承载的主类型保持一致（区分大小写）：

```
✅ OrderListViewController.swift → class OrderListViewController
✅ UIView+Layout.swift           → extension UIView
❌ orderList.swift / OrderVC.swift（禁止缩写、禁止小写开头）
```

### 2.3 命名应表意完整，避免缩写

```swift
// ❌ 禁止
let usrInfo: UsrInfo
func calcAmt() -> Double
var vc: UIViewController

// ✅ 推荐
let userInfo: UserInfo
func calculateAmount() -> Double
var presentedViewController: UIViewController
```

常见可接受缩写（行业通用）：`URL`、`ID`、`JSON`、`HTTP`、`API`、`UI`。作为标识符出现时**整体大小写一致**：

```swift
var userID: String      // ✅
var userId: String      // ❌
let apiURL: URL         // ✅
let apiUrl: URL         // ❌
```

### 2.4 方法命名遵循 Swift API Design Guidelines

- 读起来像英语句子
- 第一个参数标签 + 方法名构成完整语义

```swift
// ✅
func insert(_ element: Element, at index: Int)
func remove(at index: Int) -> Element
array.insert(newItem, at: 0)
array.remove(at: 3)

// ❌
func insertElementAtIndex(element: Element, index: Int)
```

### 2.5 私有属性不加前缀

```swift
// ❌ OC 风格遗留，禁止
private var _viewModel: ViewModel
private var m_userName: String

// ✅ 直接命名，靠 private 修饰符表达可见性
private var viewModel: ViewModel
private var userName: String
```

### 2.6 Delegate / Closure 参数命名

Delegate 方法第一个参数必须是发送者本身：

```swift
// ✅
protocol OrderListViewDelegate: AnyObject {
    func orderListView(_ view: OrderListView, didSelectOrder order: Order)
    func orderListViewDidRefresh(_ view: OrderListView)
}
```

---

## 3. 注释与文档

### 3.1 类型 / 方法 / 参数 / 字段必须加文档注释(强制)

**强制要求:所有类型、方法、方法参数、成员字段都必须用 `///` 加文档注释。** 本项目内部类型也不例外。

- **类型(class / struct / enum / protocol / actor)** — 必须 `///` 描述**大致意图**,让读者一眼看出"这个类存在是为了做什么 / 解决什么问题"
- **方法(func / init / subscript)** — 必须 `///` 覆盖以下维度(按需,不相关的省略,相关的**一条不能少**):
  - **具体功能** — 这个方法做什么;一句话能说清就不要拆多句
  - **使用限制 / 前置条件** — 调用前必须满足的状态(如"必须先调用 `start()`"、"仅在登录态可用"、"单次实例化后不可重入")
  - **线程 / 隔离限制** — `@MainActor` / 特定 queue / "任意线程"需显式注明;涉及 async 的要说明 suspension point 与 actor hop
  - **边界 / 特殊输入** — 空数组、nil、负数、超大值、重复调用、并发调用的行为(幂等?抛错?忽略?)
  - **副作用** — 修改哪些外部状态、发哪些通知、是否触发网络/IO/文件写入
  - **性能开销** — 若非 O(1) 或可能阻塞,需标注(如"首次调用会 stat 文件 ~1ms")
  - **WHY** — 为什么存在、为什么这样实现(非显然时补充)
- **方法参数** — 使用 `- Parameter xxx:` 或 `- Parameters:` 列出每个参数:含义、单位、**取值范围 / 允许 nil / 边界**、是否被闭包捕获(`@escaping`)、回调所在线程
- **返回值** — 使用 `- Returns:` 说明含义与**特殊情况**(nil / 空数组 / 负数 的语义差别,成功与失败的返回形态)
- **抛出** — 使用 `- Throws:` 列出可能抛出的错误类型,**以及什么条件下会抛出**(不只是类型名)
- **成员字段(let / var / computed property / 关联对象)** — 必须 `///` 说明字段的**作用**;对外可见字段要明确语义边界(如"未加载前为 nil"、"修改需在主线程")

**理由**:
- 降低 onboarding 成本,新人不需要反复爬调用链才能理解用途
- 强制作者思考"这个东西为什么存在",避免堆出低信息密度的 API
- 与 Xcode Quick Help / Option+Click 工作流自然对齐,让智能提示有用

```swift
// ✅ 类型:描述意图 + 使用场景
/// 订单列表分页加载器。
///
/// 内部维护 `pageIndex` 与 `hasMore`,对外只暴露「下一页」语义,避免调用方感知分页细节。
/// **线程限制**:所有 public 方法仅允许在主线程调用;内部会切换到后台执行网络请求,
/// completion 固定回到主线程。
final class OrderListPager {

    // MARK: - Properties

    /// 当前已加载的订单,按业务字段排序后的结果。
    ///
    /// 下拉刷新(`loadNextPage(forceRefresh: true)`)会整体替换;
    /// 追加加载只会 append 尾部。只允许在主线程读写。
    private(set) var orders: [Order] = []

    /// 是否还有下一页。为 false 时上拉不再触发请求。
    ///
    /// 由最近一次服务端返回驱动;下拉刷新会被重置为 true。
    private(set) var hasMore = true

    /// 单页条数。与后端约定为 20,超过可能触发限流。
    private let pageSize: Int = 20

    // MARK: - Public

    /// 加载下一页订单。
    ///
    /// **功能**:按当前 `pageIndex` 向后端拉取一页数据,追加到 `orders` 尾部。
    ///
    /// **使用限制**:
    /// - 必须先调用 `start(userID:)` 建立上下文,否则直接回调 `.failure(.notStarted)`
    /// - 调用方应处于登录态,未登录时直接 `.failure(.notLoggedIn)`
    ///
    /// **线程**:必须在主线程调用;`completion` 也在主线程回调。
    ///
    /// **边界**:
    /// - 幂等:正在加载时重复调用会被忽略,`completion` 不会被多次触发
    /// - `hasMore == false` 时直接返回 `.success([])`,不发请求
    /// - `forceRefresh == true` 会取消在途请求,重置 `pageIndex = 0`,`orders` 会整体替换
    ///
    /// **副作用**:成功时 `orders` / `hasMore` / `pageIndex` 会被更新;
    /// 失败不修改状态。不发送任何通知。
    ///
    /// **性能**:网络耗时主导;无本地耗时操作。
    ///
    /// - Parameters:
    ///   - forceRefresh: true 时忽略本地缓存、重置 `pageIndex` 到 0;默认 false
    ///   - completion: 主线程回调;`@escaping`,成功返回本次新增的订单数组(下拉刷新场景返回首页全部)
    /// - Returns: 正在进行的请求 task,调用方可持有用于外部取消;重复调用被忽略时返回 nil
    @discardableResult
    func loadNextPage(
        forceRefresh: Bool = false,
        completion: @escaping (Result<[Order], Error>) -> Void
    ) -> Task<Void, Never>? { ... }
}
```

```swift
// ❌ 禁止:类型/方法/字段无注释
final class OrderListPager {
    private(set) var orders: [Order] = []
    private(set) var hasMore = true
    private let pageSize: Int = 20

    func loadNextPage(
        forceRefresh: Bool = false,
        completion: @escaping (Result<[Order], Error>) -> Void
    ) -> Task<Void, Never> { ... }
}
```

**豁免情形**(仍需保持克制,不要滥用):
- `override` 方法重写父类语义、父类已有文档 —— 可省略,但若行为改变必须补说明
- 协议方法的默认实现,协议本身已完整描述 —— 可省略
- 明显的样板字段(如 `override var description: String`)且语义与父类一致

### 3.2 内联注释只解释 WHY,不解释 WHAT

文档注释(`///`)以外的行内注释(`//`)默认不写。只在以下情况添加:

1. **WHY 非显然**:隐藏的约束、特殊业务规则、绕过某 bug 的 workaround
2. **复杂算法 / 正则**:逻辑难以直接看懂的
3. **TODO / FIXME / HACK** 标记

```swift
// ❌ 禁止:行内注释解释 WHAT(代码自己已经说了)
// 设置名字为 name
self.name = name

// 循环数组
for item in items { ... }

// ✅ 推荐:解释 WHY(非显然原因)
// 服务端返回 amount 单位是分,这里除以 100 转为元展示
displayAmount = amount / 100.0

// 延迟一帧是为了规避 iOS 16 上 UICollectionView 初次 layout 的布局抖动
DispatchQueue.main.async { [weak self] in ... }
```

### 3.3 MARK / TODO / FIXME 规范

```swift
// MARK: - Section Name        // 分区（必须带 -）
// MARK: Subsection             // 子分区（不带 -）

// TODO: 分页加载待后端接口就绪后实现（@xxf 2026-05）
// FIXME: iOS 17 beta 上 scrollToItem 偶发崩溃，待验证修复方案
// HACK: 临时规避 xxx 库 v1.2 的 bug，升级后移除
```

**TODO / FIXME 必须写清楚：要做什么 + 负责人或日期**，否则会变成永久死债。

### 3.4 不要留注释掉的代码

提交前必须删除注释掉的废代码。需要找回历史代码用 git，不要让仓库变垃圾场。

```swift
// ❌ 禁止
func doSomething() {
    newLogic()
    // oldLogic()
    // if legacy { ... }
}
```

---

## 4. 访问控制与修饰符

### 4.1 默认最小可见性

**默认使用最严的访问级别**，逐级放开：

优先级：`private` > `fileprivate` > `internal`（默认）> `public` > `open`

```swift
// ✅ 内部状态一律 private
class OrderListViewController: UIViewController {
    private let viewModel = OrderListViewModel()
    private var isLoading = false

    private func setupUI() { ... }
    private func handleRefresh() { ... }
}

// ❌ 禁止：无脑默认 internal 暴露内部细节
class OrderListViewController: UIViewController {
    let viewModel = OrderListViewModel()   // 应该 private
    var isLoading = false                  // 应该 private
    func setupUI() { ... }                 // 应该 private
}
```

### 4.2 `private` vs `fileprivate`

- `private`：只在当前**声明作用域**内可见（Swift 4+ 同文件 extension 也能访问同一类型的 private 成员）
- `fileprivate`：同文件其他类型也可见

**默认用 `private`，只有需要让同文件的其他类型访问时才用 `fileprivate`**。

### 4.3 类默认加 `final`

**不打算被继承的类，必须标记 `final`**：

- 编译器可做静态派发优化，性能更好
- 明确表达"不要继承我"的设计意图
- 避免被意外 override 破坏封装

```swift
// ✅ 推荐：业务层的 VC/View/Service 默认 final
final class OrderListViewController: UIViewController { ... }
final class PaymentService { ... }

// ✅ 明确设计为可继承的基类，才不加 final
class BaseViewController: UIViewController { ... }
```

### 4.4 闭包和 delegate 防循环引用

**实例持有的闭包、Combine 订阅、异步回调中，引用 `self` 必须用 `[weak self]` 或 `[unowned self]`**：

```swift
// ❌ 强引用 self 导致循环引用
viewModel.onDataUpdate = {
    self.tableView.reloadData()
}

// ✅ 默认 weak
viewModel.onDataUpdate = { [weak self] in
    guard let self else { return }
    self.tableView.reloadData()
}

// ✅ 明确生命周期不短于闭包时，可用 unowned（谨慎）
timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [unowned self] _ in
    self.tick()
}
```

**`weak` vs `unowned` 选择**：
- 不确定 / 闭包生命周期可能长于 self → **用 `weak`**
- 明确闭包生命周期严格短于 self（如 init 内捕获） → 可用 `unowned`
- **不确定就用 `weak`**，`unowned` 访问已释放对象会直接崩溃

Delegate 属性必须 `weak`：

```swift
weak var delegate: OrderListViewDelegate?
```

### 4.5 属性修饰符使用原则

| 修饰符 | 使用场景 |
|---|---|
| `let` | 默认首选，只在明确需要可变时用 `var` |
| `lazy` | 初始化开销大且未必使用；不要用于引用 self 方法的复杂初始化（隐式循环引用风险） |
| `@Published` / Combine | ViewModel 对外发布状态，配合 `private(set)` 限制外部写入 |
| `private(set) var` | 外部可读不可写 |
| `@MainActor` | UI 相关类型 / 方法，确保主线程调用 |

```swift
// ✅ 外部只读，内部可写
final class OrderListViewModel {
    @Published private(set) var orders: [Order] = []
    @Published private(set) var isLoading = false
}
```

### 4.6 避免隐式解包可选值 `!`

除 `@IBOutlet` 和极少数初始化后才可用的场景，**禁止使用隐式解包 `Type!`**：

```swift
// ❌ 禁止
var viewModel: ViewModel!
let user = userInfo!

// ✅ 用普通可选 + guard / if let
var viewModel: ViewModel?
guard let user = userInfo else { return }
```

**仅以下场景允许隐式解包**：
- `@IBOutlet weak var tableView: UITableView!`
- 父子对象双向关联、必须延迟设置的情况（应加文档说明）

### 4.7 强制解包和 `try!` 的使用

```swift
// ❌ 禁止：任意强制解包
let url = URL(string: userInput)!
let data = try! JSONEncoder().encode(obj)

// ✅ 只在编译期/启动期常量可保证绝不失败时接受
let localURL = URL(string: "https://api.example.com")!  // 字面量 URL，启动期失败会立即暴露
let data = try! JSONEncoder().encode(staticConfig)      // 静态配置，失败即编程错误
```

**原则**：运行时数据一律用 `guard let` / `try?` / `do-catch`；只有"失败即程序 bug"的场景才用 `!` / `try!`。

---

## 5. 代码设计六大原则（必须满足）

本项目代码必须尽量满足以下六大设计原则，配合"分而治之"的文件组织，形成可维护、可扩展的代码结构。

### 5.1 单一职责原则（SRP, Single Responsibility Principle）

**一个类型只应有一个变化的理由。** 如果一个类同时承担多个职责，其中任何一个职责的变化都会迫使这个类修改。

```swift
// ❌ 一个 Manager 同时做网络、缓存、UI 通知
final class OrderManager {
    func fetchFromServer() { ... }
    func saveToDisk() { ... }
    func showToast() { ... }
}

// ✅ 拆分为三个各司其职的类型
final class OrderAPIClient { func fetch() async throws -> [Order] { ... } }
final class OrderCache    { func save(_ orders: [Order]) { ... } }
final class OrderToastPresenter { func showSuccess() { ... } }
```

### 5.2 开闭原则（OCP, Open/Closed Principle）

**对扩展开放，对修改关闭。** 新增能力时，通过扩展（新增类型 / 实现协议）而不是改动已有稳定代码。

```swift
// ❌ 新增一种支付方式就要改 switch
func pay(type: String) {
    switch type {
    case "wechat": ...
    case "alipay": ...
    // 新增 applepay 就得改这里
    }
}

// ✅ 抽象出协议，新支付方式只新增实现，不改调用方
protocol PaymentMethod { func pay(amount: Decimal) async throws }
final class WeChatPayment: PaymentMethod { ... }
final class AliPayPayment: PaymentMethod { ... }
final class ApplePayPayment: PaymentMethod { ... } // 新增时无需改调用方
```

### 5.3 里氏替换原则（LSP, Liskov Substitution Principle）

**子类型必须可以替换其父类型而不破坏程序正确性。** 继承关系必须是真正的"is-a"，不要用继承实现"共享代码"。

```swift
// ❌ 鸟类都会飞 —— 但企鹅不会，让它继承 Bird 并 override fly() 会破坏语义
class Bird { func fly() { ... } }
class Penguin: Bird { override func fly() { fatalError("penguins can't fly") } }

// ✅ 抽象出真正共享的契约
protocol Bird { var name: String { get } }
protocol Flyable { func fly() }
final class Sparrow: Bird, Flyable { ... }
final class Penguin: Bird { ... } // 不实现 Flyable
```

### 5.4 接口隔离原则（ISP, Interface Segregation Principle）

**不应强迫客户依赖它用不到的方法。** 多个小而专一的协议，优于一个臃肿的大协议。

```swift
// ❌ 一个协议塞所有能力
protocol DataSource {
    func fetchList() async throws -> [Item]
    func fetchDetail(id: String) async throws -> Item
    func upload(_ file: Data) async throws
    func downloadReport() async throws -> URL
}

// ✅ 按职责拆小协议，使用方只依赖自己需要的
protocol ItemListProviding   { func fetchList() async throws -> [Item] }
protocol ItemDetailProviding { func fetchDetail(id: String) async throws -> Item }
protocol FileUploading       { func upload(_ file: Data) async throws }
protocol ReportDownloading   { func downloadReport() async throws -> URL }
```

### 5.5 依赖倒置原则（DIP, Dependency Inversion Principle）

**高层模块不应依赖低层模块，二者都应依赖抽象。** ViewController 应该依赖 `protocol`，而不是直接 `new` 一个具体的网络类或单例。这也让单元测试可以注入 mock。

```swift
// ❌ VC 直接依赖具体实现，无法替换 / mock
final class OrderListViewController: UIViewController {
    private let api = OrderAPIClient()  // 硬编码具体类
}

// ✅ VC 依赖协议，具体实现通过 init 注入
protocol OrderFetching { func fetch() async throws -> [Order] }

final class OrderListViewController: UIViewController {
    private let fetcher: OrderFetching

    init(fetcher: OrderFetching) {
        self.fetcher = fetcher
        super.init(nibName: nil, bundle: nil)
    }
}
```

### 5.6 迪米特法则（LoD, Law of Demeter / 最少知识原则）

**一个对象应对其他对象保持最少了解。** 只和"直接朋友"通信，避免 `a.b.c.d.doSomething()` 这样的链式调用穿透多层内部结构。

```swift
// ❌ VC 穿透多层去访问 user 的 address 的 city
func updateCityLabel() {
    cityLabel.text = viewModel.user.profile.address.city.name
}

// ✅ 让中间层提供聚合好的值，调用方只与 viewModel 一个"朋友"打交道
extension OrderListViewModel {
    var displayCity: String { user.profile.address.city.name }
}

func updateCityLabel() {
    cityLabel.text = viewModel.displayCity
}
```

### 5.7 原则之间的关系

- **SRP 是基石**：职责清晰后，其他原则才能自然落地
- **OCP 靠抽象**：协议（Protocol）是实现 OCP / DIP 的主要工具
- **LSP 约束继承**：本项目类默认 `final`，继承很少用；使用继承时必须通过 LSP 检验
- **ISP / DIP 依赖协议设计**：协议要小、要聚焦、要面向调用方
- **LoD 约束交互**：避免"火车式调用"，让每层只管自己的一亩三分地

这六条原则与第 1 节的"分而治之"互为表里：职责拆分得当，文件组织自然清晰；文件职责单一，设计原则自然成立。

---

## 6. 警告零容忍

**新增的代码不得引入任何编译器 / 静态分析 / SwiftLint 警告，已有警告在改动到相关代码时就地解决。** 警告一旦积累，会迅速失去信号价值——真正要命的问题会淹没在几百条"历史遗留"里，没人再会去看。

### 6.1 基本规则

- **不引入新警告**：自己写的代码编译后必须 0 warning。有 warning 就不算写完。
- **修动处附近顺手清**：改动一个文件时，该文件里已有的警告能顺手解决就立刻解决。
- **不用 `// swiftlint:disable` 和 `@available` 绕过**：除非有非常明确的业务理由并写明注释。屏蔽不是解决。
- **CI 启用 `-warnings-as-errors`（逐步推进）**：对新增模块开启 Xcode 的 "Treat Warnings as Errors"，把红线向前推。

### 6.2 常见警告的正确处理方式

| 警告类别 | 禁止的"糊弄"做法 | 正确做法 |
|---|---|---|
| 未使用变量 / 参数 | 用 `_ = variable` 强行消 warning | 真不用就删掉；需要保留参数时用 `_` 作为参数名 |
| 废弃 API (deprecated) | `@available` 屏蔽 | 升级到新 API；必须用旧 API 时加 `@available(*, deprecated, message:)` 说明迁移计划 |
| 可选值强制解包警告 | 改成 `!` 跳过检查 | 用 `guard let` / `if let` 真正处理 nil |
| 字面量类型推断警告 | 强转绕过 | 显式声明类型 |
| 协议方法未实现 | 空实现 + 注释"先这样" | 要么实现，要么不声明符合该协议 |
| SwiftLint 行超长 / 复杂度 | `// swiftlint:disable:next` | 拆方法、拆变量、拆文件 |

### 6.3 示例

```swift
// ❌ 用 _ = 糊弄未使用变量警告
let response = try await api.fetch()
_ = response  // 禁止：要么用，要么删
```

```swift
// ❌ 用 ! 消除"表达式总是非 nil"类型警告
let urlString = config.endpoint
let url = URL(string: urlString)!  // 禁止
```

```swift
// ✅ 要么正确处理，要么明确为什么安全
guard let url = URL(string: config.endpoint) else {
    assertionFailure("config.endpoint 必须是合法 URL")
    return
}
```

```swift
// ❌ 忽略 deprecated 警告
@available(iOS, deprecated: 13.0)  // 没有迁移计划就是拖延
func legacyMethod() { ... }

// ✅ 升级到新 API
// 用 UIScene 相关 API 替换旧的 UIApplication 生命周期回调
```

### 6.4 既有警告治理策略

对于接手时已存在的历史警告：

1. **每次修改一个文件时，顺手清理该文件内的所有警告**（边界清晰，不引入额外风险）
2. 有专门时间窗口时，按模块批量清理并提交独立的 PR（便于 review）
3. 禁止通过 `// swiftlint:disable` 批量屏蔽已有警告——那只是把地毯掀起来把灰藏到下面

---

## 7. 常量、魔法值与本地化

### 7.1 禁止魔法数字 / 魔法字符串

散落在代码里的数字和字符串是 bug 的温床——改一处忘一处，或者下一个人根本不知道它含义。

```swift
// ❌ 魔法数字 / 字符串
if user.age >= 18 { ... }
headerView.frame.size.height = 44
NotificationCenter.default.post(name: Notification.Name("UserLoginSuccess"), object: nil)

// ✅ 提升为有命名的常量 / 枚举 / Notification.Name 扩展
enum Legal {
    static let adultAge = 18
}

enum Metrics {
    static let navigationBarHeight: CGFloat = 44
}

extension Notification.Name {
    static let userLoginSuccess = Notification.Name("UserLoginSuccess")
}
```

### 7.2 用户可见文案走本地化

任何会在 UI 上出现的字符串，**不要直接硬编码中文**，统一走 `NSLocalizedString` 或项目约定的本地化封装。即便当前只支持中文，也为将来留好扩展口。

```swift
// ❌
titleLabel.text = "确认删除这条订单？"

// ✅
titleLabel.text = NSLocalizedString("order.delete.confirm.title", comment: "删除订单确认弹窗标题")
```

### 7.3 强类型优先于字符串

API Key / 路由 / 事件名等容易打错的字符串，用 `enum` / `struct` 包装成强类型：

```swift
// ❌
analytics.track(event: "order_paid", params: ["amt": 100])

// ✅
enum AnalyticsEvent: String {
    case orderPaid = "order_paid"
}
analytics.track(event: .orderPaid, params: ["amount": 100])
```

---

## 8. 并发与线程

### 8.1 UI 必须主线程

所有 UIKit 调用必须在主线程。类型上可用 `@MainActor` 约束，运行时不确定线程时显式切回主线程。

```swift
// ❌ 后台线程直接改 UI
URLSession.shared.dataTask(with: url) { data, _, _ in
    self.titleLabel.text = "done"
}.resume()

// ✅ 切回主线程
URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
    Task { @MainActor [weak self] in
        self?.titleLabel.text = "done"
    }
}.resume()

// ✅ 或者类本身声明 @MainActor
@MainActor
final class OrderListViewModel { ... }
```

### 8.2 禁止 `DispatchQueue.main.sync`

主线程 `sync` 到主线程必定死锁；非主线程 `sync` 到主线程容易死锁。**禁止使用**。

```swift
// ❌ 禁止
DispatchQueue.main.sync { titleLabel.text = "foo" }

// ✅
DispatchQueue.main.async { self.titleLabel.text = "foo" }
```

### 8.3 优先使用 `async / await`

新代码优先 `async / await`，避免 callback hell 和遗忘调用 completion 导致的内存泄漏。老代码迁移时按影响面评估。

```swift
// ✅ 结构清晰
func loadOrders() async throws -> [Order] {
    let token = try await auth.currentToken()
    return try await api.fetchOrders(token: token)
}
```

### 8.4 避免数据竞争

可变共享状态必须用 actor / 锁 / 串行队列保护；只读共享数据可用 `let`。

---

## 9. 日志与调试

### 9.1 禁止提交 `print`

`print` 只在本地 debug 时临时用，**提交前必须清理**。正式日志统一走项目的日志封装（如 `Logger`、`os_log` 或项目内统一的日志 facade）。

```swift
// ❌ 提交到仓库
print("user=\(user), token=\(token)")

// ✅ 使用统一日志接口 + 分级
Logger.network.info("order fetched", metadata: ["count": orders.count])
```

### 9.2 不要打印敏感信息

token、密码、身份证、手机号、身份认证相关字段一律不入日志。如必须记录，做脱敏处理。

---

## 10. 错误处理

### 10.1 不吞异常

```swift
// ❌ 吞错误
do { try riskyCall() } catch { }

// ❌ 打印后当没事发生
do { try riskyCall() } catch { print(error) }

// ✅ 要么向上抛，要么明确处理（UI 提示 / 降级 / 埋点）
do {
    try riskyCall()
} catch {
    Logger.app.error("riskyCall failed", metadata: ["error": "\(error)"])
    analytics.track(.riskyCallFailed, error: error)
    showErrorAlert(error)
}
```

### 10.2 错误类型用 `enum`，不要抛 `NSError`

自定义错误用 `enum: Error`，带上足够的上下文让调用方可判别：

```swift
enum OrderError: Error {
    case notFound(id: String)
    case expired(expiredAt: Date)
    case network(underlying: Error)
}
```

### 10.3 `try?` 只在"不关心失败原因"时使用

```swift
// ✅ 真的不关心失败原因
let cached = try? cache.read(key)  // 缓存失败就当 nil

// ❌ 关键路径用 try? 会静默丢失错误信息
let order = try? api.fetchOrder(id: id)  // 禁止：网络失败、解析失败都变成 nil
```

---

## 11. 避免 Massive View Controller

ViewController 应是**粘合层**，不应承担业务逻辑、数据转换、网络编排。

- 业务状态与数据流 → `ViewModel`
- 网络 / 持久化 → `Service` / `Repository`
- 子视图复杂时 → 抽 `UIView` 子组件
- 子流程复杂时 → 抽 `ChildViewController`

判断标准：**一个 VC 文件应在 300 行以内完成职责**；超出就该评估能不能拆出 ViewModel / Service / 子 View。

---

## 12. 检查清单（提交前自检）

**文件组织**
- [ ] 每个核心类型独占一个文件？无 `Helpers.swift` 类的杂糅文件？
- [ ] 主类的 extension **必须**按职责 / 协议拆到独立文件(`+UI.swift` / `+TableView.swift` / `+Event.swift` / `+Prefetch.swift` ...)?堆在主文件里一律失败
- [ ] 文件名与主类型同名？未使用缩写？
- [ ] 长文件使用了 `// MARK: -` 分区？

**命名**
- [ ] 命名整体大小写一致（`userID` 而非 `userId`）？
- [ ] 布尔以 `is/has/should/can` 开头？
- [ ] 无 `_`、`m_` 等历史前缀？

**访问控制与修饰符**
- [ ] 所有属性默认 `private`？外部访问用 `private(set)`？
- [ ] 业务类加了 `final`？
- [ ] 闭包捕获 `self` 使用了 `[weak self]`？delegate 属性 `weak`？
- [ ] 运行时数据没有强制解包 `!` / `try!`？

**设计原则**
- [ ] 类/类型职责单一（SRP）？
- [ ] 新增能力走扩展而非修改稳定代码（OCP）？
- [ ] 大协议已拆小（ISP）？依赖通过协议注入（DIP）？
- [ ] 无 `a.b.c.d.x` 式火车调用（LoD）？

**注释与文档**
- [ ] 每个类型(class/struct/enum/protocol/actor)都有 `///` 描述大致意图?
- [ ] 每个方法都有 `///` 描述行为;参数列在 `- Parameter`/`- Parameters:`,返回值 `- Returns:`,抛出 `- Throws:` 都齐?
- [ ] 每个成员字段(let/var/computed)都有 `///` 说明作用?
- [ ] 行内 `//` 注释只解释 WHY,不出现解释 WHAT 的冗余?

**警告与质量**
- [ ] 编译无新增警告？改动文件内已有警告顺手清理？
- [ ] 无 `print` 残留？无注释掉的废代码？
- [ ] TODO/FIXME 标注了责任人或日期？

**常量与本地化**
- [ ] 无魔法数字 / 魔法字符串？UI 文案走本地化？

**并发与错误**
- [ ] UI 代码在主线程？无 `DispatchQueue.main.sync`？
- [ ] 错误未被吞掉？关键路径未用 `try?` 静默忽略？

---

**违反规范时的处理方式**：发现违反本规范的代码时，在修改该代码的当前任务中一并修正；不在无关任务里顺手重构全局代码。
