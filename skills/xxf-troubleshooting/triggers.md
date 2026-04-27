# xxf-troubleshooting — 触发用例

## 应该触发

- "XXF 编译报 no such module 'XXFCacheMMKV'"
- "用了 XXFHttp 后启动变慢"
- "XXFRouter 跳转崩溃 EXC_BAD_ACCESS"
- "XXFFlow 订阅立刻释放了"
- "滚动列表卡顿，怀疑 XXF 相关"
- "XXFDatabase 死锁了"

## 不应该触发

- "iOS 通用崩溃排查" → 太宽，需用户明确是否涉及 XXF
- "Swift 编译器 bug" → 不涉及 XXF
- "Xcode 安装失败" → 工具链问题

## 边界用例

- "项目启动慢"
  - 期望：**条件触发**。若未提 XXF，应先澄清"启动慢有很多原因，是否用了 XXF？若是，可检查…"
  - 避免抢答：不要默认把 XXF 当成所有性能问题的根源
- "XXFHttp 返回 401 怎么处理"
  - 期望：**不触发 troubleshooting**，这是用法问题，应走 `xxf-http`
