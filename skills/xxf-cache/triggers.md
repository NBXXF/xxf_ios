## 应该触发
- "@PreferenceWrapper 怎么用"
- "XXF 缓存怎么选"
- "图片磁盘缓存 XXF 有吗"
- "存 Dark Mode 开关"

## 不应该触发
- "存 token" → `xxf-keychain`
- "数据库表怎么建" → `xxf-database`

## 边界用例
- "UserDefaults 能存什么"
  - 期望：触发，引导到 `@PreferenceWrapper`
