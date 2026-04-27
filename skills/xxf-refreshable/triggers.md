## 应该触发
- "列表下拉刷新用 XXF 怎么做"
- "上拉分页加载"
- "XXFRefreshable 状态机"

## 不应该触发
- "MJRefresh 怎么用" → 三方
- "UIRefreshControl API" → Apple 原生

## 边界用例
- "Search 页防抖" → 不触发 `xxf-refreshable`，应走 `xxf-flow` 的 debounce
