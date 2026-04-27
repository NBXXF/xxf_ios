---
name: xxf-keychain
description: XXFKeychain 安全存储。当用户要保存 token、密码、设备 ID、加密密钥等敏感数据，或询问"XXF 怎么存 token"、"Keychain 封装"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFKeychain

对 iOS Keychain 的封装，用于敏感数据持久化。

## 触发场景

- access token / refresh token
- 用户密码 / PIN
- 端到端加密密钥
- 设备唯一标识（跨卸载保留）

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFKeychain/**/*.swift
   Grep "public|save|load|delete" in Sources/XXFKeychain/
   ```
2. 封装业务层 `TokenStore`，**只暴露 get/set/clear**，不泄漏 Keychain API
3. 单测时提供内存 mock 实现（真 Keychain 在 CI 上不可用）

## 访问策略

- 默认：`.whenUnlockedThisDeviceOnly`（安全但不跟随 iCloud 同步）
- 跨设备备份：`.afterFirstUnlock`（谨慎，token 可能泄露）
- **永远不用** `.always`（重启后也可读，风险大）

## 反模式

- 存非敏感数据到 Keychain（用 `xxf-cache`）
- 忘记在登出 / 切账号时 `clear()`
- 把 Keychain 条目 key 用用户 ID（换账号后读到旧值）
- 在后台同步任务里频繁读写（性能差）

## 相关 skill

- `xxf-cache` — 非敏感 KV
