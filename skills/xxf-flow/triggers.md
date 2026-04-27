# xxf-flow — 触发用例

## 应该触发

- "RxSwift 怎么迁到 XXFFlow"
- "Observable 换成 Flow 有什么坑"
- "XXFFlow 怎么链式请求"
- "subscribeOnIO 和 observeOnMain 什么区别"
- "Combine 能和 XXFFlow 一起用吗"
- "XXFFlow 订阅怎么释放"

## 不应该触发

- "RxSwift 本身的教程" → 不涉及 XXF，不触发
- "Swift Concurrency async/await 用法" → 与 XXFFlow 无关
- "XXFHttp 怎么发请求" → 应走 `xxf-http`

## 边界用例

- "用响应式写一个搜索框防抖"
  - 期望：触发（`debounce` 是 XXFFlow 经典场景）
- "Combine 的 Publisher 能转成 Flow 吗"
  - 期望：触发，skill 应引导 AI 读 `Sources/XXFFlow/` 看桥接 API
