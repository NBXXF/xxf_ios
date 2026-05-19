---
name: xxf-aaa-test-strategy
description: 设计测试策略与测试矩阵，覆盖单元测试、集成测试、回归测试、故障注入，并给出可执行测试计划。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# 测试策略（Test Strategy）

## 触发场景

- 新模块上线前需要测试方案
- 重构后需要回归策略
- 线上问题复盘后补测试

## 职责边界

- 本 skill 负责回答“应该测什么”“最小必测集是什么”“自动化优先级怎么排”。
- 本 skill 默认输出测试方案，不直接承担实际跑测试。
- 如果用户要实际执行验证，应优先走 `xxf-aaa-auto-test-orchestrator`。
- 如果用户要直接补单元测试代码，应优先走 `xxf-aaa-unit-test-writer`。
- 如果用户要对具体 patch 做代码问题审查，应优先走 `xxf-aaa-code-reviewer`。
- 如果用户要决定是否阻断合并或发布，应优先走 `xxf-aaa-risk-gate`。

## 推荐协作顺序

1. 先用本 skill 给出最小必测集、回归优先级、自动化优先级。
2. 如果需要落地单元测试，交给 `xxf-aaa-unit-test-writer`。
3. 如果需要实际执行验证，交给 `xxf-aaa-auto-test-orchestrator`。
4. 如果需要基于代码变更找具体问题，交给 `xxf-aaa-code-reviewer`。
5. 如果需要最终判断能否放行，交给 `xxf-aaa-risk-gate`。

## 策略框架

1. 单元测试：核心纯逻辑、边界输入、错误分支。
2. 集成测试：模块协作、依赖注入、接口契约。
3. 回归测试：高频路径、历史故障用例、版本兼容。
4. 故障注入：超时、空数据、错误码、并发冲突。

## 输出模板

- 测试范围（In Scope / Out of Scope）
- 风险分级（High / Medium / Low）
- 用例矩阵（模块 × 场景 × 预期）
- 自动化优先级（必须自动化 / 可手测）

## 典型输出

- 最小必测集：时间有限时必须覆盖哪些路径
- 回归优先级：哪些历史故障和高频路径必须回归
- 自动化建议：哪些项值得立刻自动化，哪些可暂时手测

## 反模式

- 只测 happy path，不测失败路径与边界。
- 仅堆数量，不关注关键风险链路覆盖率。
