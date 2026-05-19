# xxf-aaa-ci-quality-gates — 触发用例

## 应该触发
- "CI 门禁规则帮我设计"
- "哪些情况要阻断合并"
- "风险报告怎么接入门禁"

## 不应该触发
- "某个单测断言怎么写" → 具体测试实现
- "帮我把测试直接跑了" → 应走 `xxf-aaa-auto-test-orchestrator`
- "帮我 review 这个 patch" → 应走 `xxf-aaa-code-reviewer`
- "这个改动最小要测哪些" → 应走 `xxf-aaa-test-strategy`

## 边界用例
- "为了赶版本先关掉门禁"
  - 期望：触发并给受控例外流程
