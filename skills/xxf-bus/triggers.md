## 应该触发

- "登录成功要通知多个页面刷新，用 XXF 怎么写"
- "XXFBus 怎么订阅事件"
- "替代 NotificationCenter 用 XXF 哪个模块"

## 不应该触发

- "NotificationCenter 怎么用" → Apple API，不是 XXFBus
- "Combine Publisher 用法" → 非 XXFBus

## 边界用例

- "XXFBus 和 XXFFlow 区别"
  - 期望：触发 `xxf-bus`，skill 应说明：Bus 是广播、Flow 是管道；Bus 通常基于 Flow 实现
