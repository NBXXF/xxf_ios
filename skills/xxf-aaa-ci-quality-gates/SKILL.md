---
name: xxf-aaa-ci-quality-gates
description: CI 质量门禁策略，定义构建、测试、静态扫描、风险阈值、阻断条件与例外流程，保障合入和发布质量。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# CI 质量门禁技能

## 触发场景

- 设计或调整 CI 门禁规则
- 定义哪些情况要阻断合并或发布
- 制定测试、静态检查、风险报告进入 CI 的方式

## 职责边界

- 本 skill 负责“规则设计”“阈值定义”“例外流程”，不是实际跑测试或实际做 code review。
- 如果用户要实际执行验证，应优先走 `xxf-aaa-auto-test-orchestrator`。
- 如果用户要写或修单元测试，应优先走 `xxf-aaa-unit-test-writer`。
- 如果用户要审查具体 patch 风险，应优先走 `xxf-aaa-code-reviewer` 或 `xxf-aaa-risk-gate`。
- 如果用户要设计测试矩阵或最小必测项，应优先走 `xxf-aaa-test-strategy`。

## 推荐协作顺序

1. 先消费上游已经稳定的执行或评审结论：
   - `xxf-aaa-test-strategy` 给出的测试范围与优先级
   - `xxf-aaa-code-reviewer` 给出的高风险问题类型
   - `xxf-aaa-auto-test-orchestrator` 给出的实际验证结果
   - `xxf-aaa-risk-gate` 给出的放行/阻断标准
2. 本 skill 再把这些结论固化成 CI 门禁、阈值、例外流程与审计要求。
3. 不要反过来让 CI 规则去替代具体 review、补测或实际验证。

## 门禁层级

1. 编译门禁：必须可构建
2. 测试门禁：关键测试通过
3. 质量门禁：静态扫描与风险阈值
4. 发布门禁：灰度与回滚条件齐备

## 输出模板

- 门禁项与阈值
- 阻断条件
- 例外申请流程
- 指标看板

## 典型输出

- 编译门禁：必须通过的构建范围
- 测试门禁：必须通过的测试集合与失败阻断条件
- 风险门禁：哪些高风险改动必须附带 review、补测、灰度或回滚方案
- 例外流程：谁能批准、有效期多久、需要哪些补偿动作

## 反模式

- 只看编译通过，不看测试与风险。
- 门禁失败可随意绕过，无审计记录。
