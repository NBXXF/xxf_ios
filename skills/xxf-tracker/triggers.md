## 应该触发
- "XXF 怎么做埋点"
- "页面曝光事件"
- "崩溃上报"

## 不应该触发
- "Firebase Analytics 原生 API" → `xxf-tracker-firebase`
- "日志" → `xxf-log`

## 边界用例
- "埋点里能存 userId 吗" → 触发，引导看是否是 PII 风险
