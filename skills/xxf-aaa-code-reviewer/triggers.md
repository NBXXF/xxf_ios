# xxf-aaa-code-reviewer — 触发用例

## 应该触发

- "帮我 review 这次改动"
- "这个 patch 有没有阻塞问题"
- "你先做一轮 code review"
- "重点看回归和漏测"

## 不应该触发

- "帮我直接修并补测试" → 更适合先走实现或 `xxf-aaa-unit-test-writer`
- "帮我跑验证" → 应走 `xxf-aaa-auto-test-orchestrator`
- "帮我评审整体架构方案" → 应走 `xxf-aaa-architecture-review`

## 边界用例

- "说有没有 blocking findings"
  - 期望：触发，并以严重级别排序给出 findings
