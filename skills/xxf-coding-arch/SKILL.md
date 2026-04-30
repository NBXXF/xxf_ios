---
name: xxf-coding-arch
description: xxf_ios 项目的功能模块架构规范——按 Feature 分层组织代码（Api / Domain / Repository / Service / Di / Presentation）。新增或重构功能模块时必须遵守。
---

# xxf_ios 功能模块架构规范

> **适用范围**：在本项目新增 Feature 模块、重构已有模块、或跨层改动时，必须遵守以下目录与分层约定。

---

## 1. 目录结构

```
AppName/Sources/
├── Arch/                    # 全局基础设施
└── {Feature}/               # 功能模块
    ├── Api/                 # Moya TargetType 接口定义
    ├── Domain/DTO/          # 数据传输对象
    ├── Repository/          # 数据层（网络 + 缓存）
    ├── Service/             # 业务服务层
    ├── Di/                  # 依赖注入注册
    └── Presentation/
        ├── ViewModel/       # 业务逻辑
        └── Page/            # ViewController
```

---

## 2. 分层职责

| 层 | 目录 | 职责 | 依赖方向 |
|---|---|---|---|
| **Arch** | `Arch/` | 全局基础设施：基类、通用配置、跨模块工具 | 被所有 Feature 依赖 |
| **Api** | `{Feature}/Api/` | 定义 Moya `TargetType`，只声明接口，不关心调用方 | 依赖 Domain/DTO |
| **Domain/DTO** | `{Feature}/Domain/DTO/` | 纯数据模型（`Codable`），无业务逻辑 | 无依赖 |
| **Repository** | `{Feature}/Repository/` | 网络请求 + 本地缓存的组合，对上层屏蔽数据来源 | 依赖 Api、DTO、缓存层 |
| **Service** | `{Feature}/Service/` | **业务规则与跨 Repository 编排的唯一落点**（见 §3.6） | 依赖 Repository |
| **Di** | `{Feature}/Di/` | 模块内依赖注入注册（基于 XXFDi） | 依赖本模块其他层 |
| **Presentation/ViewModel** | `{Feature}/Presentation/ViewModel/` | UI 相关业务逻辑、状态管理；不持有 View | 依赖 Service |
| **Presentation/Page** | `{Feature}/Presentation/Page/` | UIViewController、UIView，只消费 ViewModel 状态 | 依赖 ViewModel |

---

## 3. 核心规则

### 3.1 依赖方向单向

**自上而下单向依赖**：`Page → ViewModel → Service → Repository → Api / DTO`。严禁反向依赖或跨层跳跃（例如 `Page` 直接调用 `Repository`）。

### 3.2 Feature 之间不直接依赖

Feature A 需要 Feature B 的能力时，**通过 B 暴露的 `Service` 协议 + Di 注册**获取，不要直接 import B 的内部类型。

### 3.3 新增 Feature 必须齐全 6 个子目录

即使某层当下为空，也先建好目录。保证所有 Feature 结构对称，方便跨模块阅读。

### 3.4 DTO 只放在 Domain/DTO，不要散落

所有网络返回 / 持久化模型统一放 `{Feature}/Domain/DTO/`，不在 Api 或 Repository 里零散定义。

### 3.5 Di 注册集中到各 Feature 的 Di 目录

每个 Feature 有独立的 Di 注册入口，应用启动时由上层统一调用。不要在 ViewController 或 ViewModel 里手动 new Service / Repository。

### 3.6 业务逻辑只落 Service，严禁 Manager / Tool / Utils / Helper 类业务分层

**核心原则：凡是业务逻辑（含业务规则、跨 Repository 编排、领域状态流转、业务字段计算），只能写在 `{Feature}/Service/` 下。**

**严禁的反模式**（以下命名在项目里出现即视为违规，代码评审必须打回）：

- `XxxManager` / `XxxTool` / `XxxUtils` / `XxxHelper` / `XxxHandler` 承载业务逻辑
- 为了"方便复用"在 Presentation / ViewModel 旁边新建 `XxxLogic`、`XxxProcessor`、`XxxCenter` 等自造分层
- 把业务拆进 `Arch/` 或全局单例里共享（`Arch/` 只放**与业务无关**的通用基础设施，如网络封装、缓存、日志、UI 基类）
- 在 Repository 里混入业务判断（Repository 只负责"取/存数据"，不做"是否允许"、"如何组合"的决策）

**判断标准（写之前先自问）**：

| 这段代码是什么？ | 应该放哪 |
|---|---|
| 业务规则、领域判断、多接口编排、状态流转 | `{Feature}/Service/` |
| 纯数据读写（网络 + 缓存） | `{Feature}/Repository/` |
| UI 状态 / View 驱动 | `{Feature}/Presentation/ViewModel/` |
| 真正与业务无关的通用工具（字符串处理、日期格式化、颜色扩展等） | `Arch/` 或 Swift extension |

**一句话判定**：只要方法里出现"业务"两个字能说得通（"判断订单是否可取消"、"合并用户信息与权限"），它就属于 Service。出现 Manager / Tool / Utils / Helper 作为业务归宿的名字时，**先停下，把它挪到 Service**。

### 3.7 界面内容不可写死,一律由 Service / ViewModel 动态提供

**核心原则:UI 层(Presentation)不得硬编码业务数据。任何"展示给用户的业务内容"(菜单项、条目、分段、入口、文案、图标等)都必须由 Service 构建 → ViewModel 暴露数据源 → UI 循环渲染。"界面上有 N 条"这个 N,永远来自 `data.count`,绝不写死。**

**严禁的反模式**(出现即违规):

- VC / View 里写死条目数组 / 菜单项 / 分区标题 / 入口按钮
- 产品说"暂时就两个",于是直接写两个 `UIButton` IBOutlet,后续加第三个要改 xib/代码
- 业务文案、图标、跳转目标在 UI 层硬编码,未从 Service 或配置来
- `if index == 0 { ... } else if index == 1 { ... }` 式按位置写死分支
- `numberOfRowsInSection` 返回字面量 `return 2`

**正确做法**:

- Service 返回 `[Item]` 数组(可能来自后端配置、灰度、地区定制、枚举生成),ViewModel 转为数据源,View 循环渲染
- 菜单、Tab、Section、入口等"可增减的集合"一律数据驱动
- 空态 / 单条 / 多条等边界由数据天然表达,不写 if-else 分支
- 业务相关的文案 / 图标 / 跳转 action 随数据一起下发或由 Service 组装

```swift
// ❌ 硬编码 2 个菜单项
final class ProfileViewController: UIViewController {
    private let orderButton = UIButton(...)    // "我的订单"
    private let couponButton = UIButton(...)   // "优惠券"
    // 加第三项 → 改 xib、加 outlet、调布局
}

// ❌ TableView 按位置写死分支
func tableView(_ tv: UITableView, numberOfRowsInSection s: Int) -> Int { 2 }
func tableView(_ tv: UITableView, cellForRowAt ip: IndexPath) -> UITableViewCell {
    if ip.row == 0 { /* 订单 */ } else { /* 优惠券 */ }
}

// ✅ 数据驱动:Service 定义 → ViewModel 暴露 → UI 绑定
struct ProfileMenuItem {
    let id: String
    let title: String
    let icon: UIImage
    let action: ProfileAction
}

protocol ProfileService {
    /// 返回个人中心菜单项;顺序即展示顺序,可由后端配置或灰度动态下发。
    func fetchMenuItems() async -> [ProfileMenuItem]
}

final class ProfileViewModel {
    /// 菜单数据源;UI 只需绑定 count 与每项内容,无需感知"有几项"。
    private(set) var menuItems: [ProfileMenuItem] = []

    func load() async { menuItems = await service.fetchMenuItems() }
}

// View 层只做 items.count / items[i] 的循环渲染 —— 未来增减、重排、远程下发都不改 UI
```

**判断边界**:

| 场景 | 正确归宿 |
|---|---|
| 菜单项 / Tab / 分段 的数量与内容 | Service 动态返回,ViewModel 转数据源 |
| 业务文案、图标、跳转 action | 随数据结构一起从 Service 获取 |
| 固定的 app 级文字(导航栏标题、通用按钮文案) | `Localizable.strings`(仍算"配置"而非硬编码) |
| 布局骨架(搜索栏 + 列表这类容器结构) | 可以写死 View 层级,但其中 cell / section 仍走数据驱动 |
| 业务 KV 常量(订单状态、支付方式枚举值) | `Domain/` 里的 enum,不是 UI 层魔法值 |

**自检触发器**:写代码时只要你在 VC/View 里出现以下任意一个,**立刻停下挪到 Service**:
- 字面量数字作为条目 / section 数量 (`return 2`, `maxItems: 3`)
- 按索引的 `switch` / `if-else` 分支处理不同条目
- 固定个数的 IBOutlet 按钮并排对应"入口"、"菜单"、"Tab"
- 写死文案数组 `["订单", "优惠券", "地址"]` 之类

---

## 4. 新增 Feature 检查清单

- [ ] 6 个子目录齐全：`Api / Domain/DTO / Repository / Service / Di / Presentation(ViewModel + Page)`？
- [ ] 依赖方向自上而下，无反向依赖？
- [ ] DTO 统一放在 `Domain/DTO/`，未散落到 Api/Repository？
- [ ] 跨 Feature 调用通过 Service 协议 + Di，而非直接 import？
- [ ] Di 在 Feature 的 Di 目录集中注册，未在 VC/VM 里手动 new？
- [ ] **业务逻辑全部落在 Service，未出现 `Manager / Tool / Utils / Helper / Logic / Processor / Center` 等自造业务分层？**
- [ ] **Repository 只做数据读写，未混入业务判断？`Arch/` 下无业务代码？**
- [ ] **UI 层无写死业务数据?菜单/条目/分段的数量与内容都由 Service 动态提供、ViewModel 转数据源、View 循环渲染?未出现 `return 2` 式字面量条数、按索引的 if/switch、固定个数 IBOutlet 对应"入口"等反模式?**
