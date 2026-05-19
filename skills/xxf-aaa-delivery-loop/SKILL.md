---
name: xxf-aaa-delivery-loop
description: 处理 XXF iOS 项目中的通用编码任务交付流程。用于 bugfix、功能开发、重构、回归修复等未显式指明测试或 review 的日常 coding 请求；负责自动串起模块 skill、补测、验证、代码审查与风险门禁。
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# 交付总控（Delivery Loop）

## 触发场景

- 普通编码任务，但用户没有单独点名测试、review、风险评估
- bugfix、功能开发、局部重构、回归修复
- “把这个问题修掉”“改一下这里”“做完为止”这类日常 coding 请求

## 核心职责

本 skill 不是替代具体模块 skill，而是规定默认交付闭环：

1. 先识别是否涉及 XXF 模块或工程约束。
2. 读取对应模块 skill 与相关工程 skill。
3. 实现最小必要改动。
4. 需要时补最小有效单测。
5. 执行最小相关验证。
6. 对结果做一次以 findings 为中心的审查。
7. 最后给出放行风险结论。

## 默认工作流

### 1. 路由到正确上下文

- 如果任务涉及具体 XXF 模块，先读对应 `skills/xxf-*/SKILL.md`
- 代码修改默认同时受这些工程 skill 约束：
  - `xxf-aaa-coding-style`
  - `xxf-aaa-coding-arch`
  - `xxf-aaa-test-strategy`（需要判断最小必测集时）

### 2. 实现阶段

- 优先最小改动，不做顺手重构
- 如果是 bugfix，优先保留可验证的复现路径
- 如果存在明显缺测试风险，进入 `xxf-aaa-unit-test-writer`

### 3. 验证阶段

- 代码有改动时，默认进入 `xxf-aaa-auto-test-orchestrator`
- 优先最小相关测试范围
- 没有可测入口时，至少做编译级验证并说明残余风险

### 4. 审查阶段

- 出现以下任一情况时，进入 `xxf-aaa-code-reviewer`：
  - 改动跨文件或跨层
  - 涉及错误处理、状态、并发、生命周期
  - 有潜在回归面
  - 补了测试但仍存在边界不确定性

### 5. 门禁阶段

- 出现以下任一情况时，进入 `xxf-aaa-risk-gate`：
  - 影响发布或合并决策
  - 有残余风险无法靠当前验证完全证明
  - 涉及数据库、路由、缓存、权限、隐私、兼容性

## 自动进入下游 skill 的条件

### 进入 `xxf-aaa-unit-test-writer`

- bugfix
- 逻辑分支新增或修改
- 原有测试失效
- 当前改动明显缺少回归保护

### 进入 `xxf-aaa-auto-test-orchestrator`

- 任何代码改动完成后
- 补完测试后
- 需要确认修复有效时

### 进入 `xxf-aaa-code-reviewer`

- 改动不止一个文件
- 改动触及边界层或共享逻辑
- 用户没有要求 review，但该改动本身有明确回归风险

### 进入 `xxf-aaa-risk-gate`

- 用户问能否放行
- 已有 findings 或验证残余风险
- 需要决定是否必须灰度、回滚、防护或补测

## 升级给开发者的条件

只有在以下情况才停止自动闭环并升级澄清：

- 需要密钥、签名、生产配置、外部敏感环境
- 测试或构建入口依赖不明确且无法安全推断
- 是否正确属于敏感业务规则或产品决策
- 改动已触及 framework/core architecture 且超出已批准边界

## 输出要求

最终至少包含：

- 实现了什么
- 是否补了测试
- 跑了哪些验证
- 是否发现 review findings
- 风险结论和残余风险

## 非目标

- 不要求用户显式说“顺便跑测试 / 做 review / 做风险评估”
- 不把所有任务都升级成完整 CI 设计问题
- 不把编码任务拆成过多显式确认步骤
