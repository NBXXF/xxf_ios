# xxf-router — 触发用例

## 应该触发

- "用 XXFRouter 注册一个用户详情页"
- "跳转前加登录拦截怎么做"
- "XXFRouter 降级 H5 怎么配"
- "模块间跳转不想互相 import"
- "URL Scheme 怎么映射到 XXF 路由"
- "Universal Link 唤起后跳到指定页"

## 不应该触发

- "UINavigationController push 参数" → 不涉及 XXF 路由框架
- "网络请求拦截器" → 应走 `xxf-http`
- "SwiftUI NavigationStack 怎么用" → 与 XXFRouter 无关

## 边界用例

- "XXF 路由和 SwiftUI 的 NavigationStack 能一起用吗？"
  - 期望：触发，skill 应诚实说明兼容性（读 `Sources/XXFRouter/` 确认）
- "跳转前打埋点"
  - 期望：触发（路由拦截器场景），而非走埋点相关 skill
