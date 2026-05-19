# xxf-aaa-auto-test-orchestrator — 触发用例

## 应该触发

- "帮我把相关测试直接跑掉"
- "这个改动先验证一下"
- "失败测试先帮我定位 root cause"
- "提交前帮我做最小回归"

## 不应该触发

- "帮我设计测试体系" → 应走 `xxf-aaa-test-strategy`
- "帮我补单元测试代码" → 应走 `xxf-aaa-unit-test-writer`
- "这个改动最小要测哪些" → 应先走 `xxf-aaa-test-strategy`
- "只是想看代码有没有问题" → 应走 `xxf-aaa-code-reviewer`

## 边界用例

- "先验证再说"
  - 期望：如果已经落到测试验证语境，优先执行最小相关测试；只有遇到敏感配置或高风险命令才升级澄清
