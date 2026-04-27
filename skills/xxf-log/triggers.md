## 应该触发
- "XXFLog 怎么初始化"
- "日志分等级"
- "Pulse 日志查看"

## 不应该触发
- "print 输出怎么调试" → 劝用 XXFLog 代替
- "CocoaLumberjack 用法" → 三方

## 边界用例
- "崩溃日志怎么收集" → 不触发 XXFLog，走 `xxf-tracker` 或 `xxf-tracker-sentry`
