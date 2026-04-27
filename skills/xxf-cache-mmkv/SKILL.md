---
name: xxf-cache-mmkv
description: XXFCacheMMKV（腾讯 MMKV 作为 XXFCache 的 KV 实现）。当用户想用 MMKV 高性能替代 UserDefaults，或询问"MMKV 怎么接入 XXF"、"Swift 6.2 条件依赖"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFCacheMMKV

腾讯 MMKV 在 XXFCache 体系下的 Provider 实现，大容量、高并发 KV 场景的高性能替代。

**依赖要求：Swift 6.2+。** 低版本用户请用 `xxf-cache` 的默认实现。

## 触发场景

- 已有 `XXFCache` 集成，想换高性能 KV 后端
- 跨进程共享 KV（MMKV 支持）
- UserDefaults 性能瓶颈

## 工作流

1. 检查 Swift 版本：`swift --version` 必须 ≥ 6.2，否则劝阻
2. 读源码：
   ```
   Glob Sources/XXFCacheMMKV/**/*.swift
   Grep "MMKV|register" in Sources/XXFCacheMMKV/
   ```
3. 在启动期注册 MMKV 为 `XXFCache` 的 Provider（具体入口读源码）
4. 业务层**不变**，仍用 `@PreferenceWrapper`

## 反模式

- 跳过 `XXFCache` 抽象直接 `import MMKV`（失去可替换性）
- 在多个进程 / App Group 场景忘记配置 MMKV 的共享路径
- 存敏感数据（MMKV 默认未加密，敏感走 `xxf-keychain`）

## 相关 skill

- `xxf-cache` — 上游抽象
- `xxf-keychain` — 敏感数据
