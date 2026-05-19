---
name: xxf-aaa-security-privacy
description: iOS 安全与隐私基线，覆盖敏感数据存储、日志脱敏、权限最小化、传输安全、第三方 SDK 合规与审计清单。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# 安全与隐私技能

## 覆盖范围

- 敏感数据分级与存储策略
- Keychain/本地缓存使用边界
- 日志脱敏与禁止字段
- 权限申请与拒绝兜底
- 第三方 SDK 合规审查

## 输出模板

- 风险项
- 影响级别
- 修复优先级
- 验证方式

## 反模式

- 把 token / PII 打入日志。
- 未经审查直接引入埋点 SDK。
