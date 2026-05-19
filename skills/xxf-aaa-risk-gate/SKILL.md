---
name: xxf-aaa-risk-gate
description: 对需求或代码变更做风险分级与门禁建议，输出是否阻断发布、是否必须补测试、是否需要灰度与回滚方案。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# 风险门禁（Risk Gate）

## 触发场景

- PR 合并前风险评估
- 发版前变更审查
- 大改动（数据库/路由/缓存）上线前

## 职责边界

- 本 skill 负责回答“能不能放行”“是否必须阻断”“要不要灰度/回滚/补防护”。
- 如果用户要的是找代码里的具体 bug、回归点、漏测项，应优先走 `xxf-aaa-code-reviewer`。
- 如果用户要的是实际执行测试验证，应优先走 `xxf-aaa-auto-test-orchestrator`。
- 如果用户要的是补写单元测试，应优先走 `xxf-aaa-unit-test-writer`。
- 如果用户要的是设计测试方案或最小必测集，应优先走 `xxf-aaa-test-strategy`。
- 如果用户要的是设计 CI 规则、阈值或例外流程，应优先走 `xxf-aaa-ci-quality-gates`。

## 推荐协作顺序

1. 在信息不足时，先消费上游结论，而不是凭感觉放行：
   - `xxf-aaa-code-reviewer` 的 findings
   - `xxf-aaa-auto-test-orchestrator` 的验证结果
   - `xxf-aaa-unit-test-writer` 的补测覆盖情况
   - `xxf-aaa-test-strategy` 的最小必测集
2. 本 skill 再基于这些输入给出 `Block / Warn / Pass`。
3. 如果需要把门禁长期固化到 CI，交给 `xxf-aaa-ci-quality-gates`。

## 风险分级规则

- High：可能导致崩溃、数据错误、权限/隐私问题。
- Medium：功能退化、性能抖动、可用性下降。
- Low：可维护性或风格问题。

## 门禁建议

1. High：必须阻断，修复或加防护后再合并。
2. Medium：需补测试并给灰度方案。
3. Low：可放行，但需列入技术债清单。

## 输出模板

- 风险点列表（含文件定位）
- 影响范围（用户面/模块面）
- 门禁结论（Block / Warn / Pass）
- 最小修复路径

## 典型输出

- High 风险：阻断合并或发布，并说明必须补的验证、防护、回滚条件
- Medium 风险：可条件放行，但必须说明补测范围、灰度策略、监控项
- Low 风险：可放行，但要记录残余风险和技术债

## 反模式

- “凭感觉”评估，不给明确阻断条件。
- 风险只描述，不绑定验证与回滚动作。
