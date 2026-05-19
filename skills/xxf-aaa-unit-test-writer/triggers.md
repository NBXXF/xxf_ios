# xxf-aaa-unit-test-writer — 触发用例

## 应该触发

- "这个 bug 补个单测"
- "帮我把受影响的单元测试写掉"
- "这个改动的单元测试直接补上"
- "现有单测挂了，你直接修到能验证"

## 不应该触发

- "帮我运行一下测试" → 应走 `xxf-aaa-auto-test-orchestrator`
- "帮我做代码评审" → 应走 `xxf-aaa-code-reviewer`
- "帮我做完整测试策略规划" → 应走 `xxf-aaa-test-strategy`
- "这个改动最小要测哪些" → 应先走 `xxf-aaa-test-strategy`

## 边界用例

- "如果缺测试就补上"
  - 期望：触发，并先从现有测试风格中推导最小可行补测方案
