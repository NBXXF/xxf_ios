# xxf-aaa-delivery-loop — 触发用例

## 应该触发

- "把这个问题修掉"
- "改一下这里"
- "这个功能补一下"
- "这个 bug 处理掉"
- "做完为止"

## 不应该触发

- "这个功能最小要测哪些" → 应走 `xxf-aaa-test-strategy`
- "帮我 review 这次改动" → 应走 `xxf-aaa-code-reviewer`
- "这个 PR 能不能放行" → 应走 `xxf-aaa-risk-gate`
- "CI 门禁规则帮我设计" → 应走 `xxf-aaa-ci-quality-gates`

## 边界用例

- "先修，修完该补测就补测，该验证就验证"
  - 期望：触发，并自动串起 `xxf-aaa-unit-test-writer`、`xxf-aaa-auto-test-orchestrator`、`xxf-aaa-code-reviewer`、`xxf-aaa-risk-gate`
