## 应该触发
- "UITableViewCell 注册简化"
- "XXFReusable 怎么用"
- "dequeueReusableCell 类型安全"

## 不应该触发
- "UITableView 性能优化" → 通用问题
- "SwiftUI List" → 非 XXFReusable

## 边界用例
- "CollectionView Header / Footer 注册" → 触发，确认 XXFReusable 是否支持 supplementary view
