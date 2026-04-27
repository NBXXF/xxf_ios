# XXFRouter 进阶范式

本文档是 `xxf-router` skill 的**进阶参考**，仅在需要深度设计时加载。

## 1. 路由 key 管理

集中声明：

```swift
enum Routes {
    static let userProfile = "app://user/profile"
    static let orderDetail = "app://order/detail"
    static let webView     = "app://common/web"
}
```

规则：
- 协议前缀统一（如 `app://`）
- 路径语义化（`user/profile` 而非 `page_123`）
- **参数不写在 key 里**，通过 params 传

## 2. 参数传递三档

| 档 | 用法 | 场景 |
|:------|:------|:------|
| **编译期类型安全** | 专用注册/跳转方法 | 同项目内强类型跳转（推荐） |
| **字典 params** | `[String: Any]` | 跨模块、无法共享类型 |
| **URL query** | `?id=123&from=push` | 外部唤起（URL Scheme / UL） |

**反模式**：传整个 ViewModel / Model。只传 ID 或 DTO，目标页自己查。

## 3. 拦截器职责拆分

| 拦截器 | 单一职责 |
|:------|:------|
| `AuthInterceptor` | 未登录 → 跳登录 → 登录后恢复 |
| `TrackingInterceptor` | 发埋点（不修改跳转行为） |
| `ThrottleInterceptor` | 短时间重复点击去抖 |
| `DowngradeInterceptor` | 新功能在低版本回退 H5 |

**顺序**：Throttle → Auth → Downgrade → Tracking → 跳转

## 4. 降级策略

```
目标页注册？
  ├─ 是 → 跳转
  └─ 否 → 降级链
         ├─ H5 兜底页
         ├─ 静态帮助页
         └─ Toast + 返回
```

降级规则集中配置，不要散在拦截器里。

## 5. 模块自注册

让每个模块声明"我提供了哪些路由"，启动时由框架统一收集。好处：
- 新增模块不需要改 `AppDelegate`
- 可选模块动态打开 / 关闭

具体机制读 `Sources/XXFRouter/` 确认框架支持的形式。

## 6. URL Scheme / Universal Link 映射

**不要**让外部 URL 直接等于内部路由 key（URL 可能被用户收藏、分享）。做一层映射：

```
外部 URL: https://xxx.com/u/42
  ↓  映射表
内部 Route: app://user/profile?id=42
```

映射表支持版本化，老 URL 永远能解析到当前对应页面。

## 7. 跳转埋点

所有跳转经路由时打点：

```
source: 调用方页面
target: 目标路由 key
params_hash: 参数脱敏哈希
intercepted_by: 拦截器链
result: success / downgraded / denied
```

用于分析：哪些功能入口没人用、哪些降级频率高。

## 8. 测试

- 注册冲突：启动扫描所有路由 key，重复抛错（只在 Debug）
- 拦截器顺序：单测每个拦截器独立，再单测编排顺序
- 降级：mock 目标页不存在，验证兜底页可达
