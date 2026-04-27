---
name: xxf-router
description: 使用 XXFRouter 管理页面跳转。当用户要注册路由、配置页面导航、添加跳转拦截器、实现降级策略、处理 URL Scheme 或 Universal Link、解耦模块间跳转时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFRouter 路由框架

## 触发场景

- 项目要做模块化解耦，页面互相跳转不直接依赖
- URL Scheme / Universal Link 外部唤起
- 跳转前鉴权、埋点、风控
- 降级兜底（H5 回退、版本不匹配）

## 工作流

### 1. 读源码定 API（**必做**）

```
Glob Sources/XXFRouter/**/*.swift
Grep "register|navigate|intercept" in Sources/XXFRouter/
```

识别以下关键点（不要凭记忆写）：
- 注册入口（协议 / 宏 / 字符串 key）
- 跳转入口（方法签名、参数传递方式）
- 拦截器接口
- 降级策略的配置点

### 2. 路由表设计（**强制约定**）

- 路由 key 用**常量集中管理**，禁止魔法字符串散落各处  
  推荐位置：`App/Routes.swift` 或每个模块自带 `XxxModule+Routes.swift`
- 参数命名用 `camelCase`，与 Swift 变量一致
- 跨模块跳转**只依赖路由 key**，不 `import` 目标模块

### 3. 注册时机

在 `AppDelegate` / `SceneDelegate` 启动时注册所有路由，或用每个模块的 `@_cdecl` / 自注册机制（先读源码确认框架支持哪种）。

**禁止**在 ViewController 里临时注册。

### 4. 拦截器典型用法

- **登录拦截**：未登录 → 跳登录页 → 登录后恢复原跳转
- **埋点**：所有跳转打点
- **限流**：短时间重复点击去抖
- **版本降级**：新页面在低版本客户端回退到 H5

拦截器**按职责单一**，不要写一个"万能拦截器"。

### 5. 跳转参数传递

优先级：**编译期类型安全 > 字典 > URL query**  
先读源码看框架支持哪种，避免自作主张。

## 反模式（禁止）

- 业务代码里直接 `navigationController?.pushViewController(...)`（除非是页面内部子页面）
- 路由 key 用中文或包含特殊字符
- 把整个 ViewModel 通过路由参数传递（只传 ID / DTO）

## 深入阅读

跳转降级、模块自注册详见 [references/patterns.md](references/patterns.md)。
