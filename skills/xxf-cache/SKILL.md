---
name: xxf-cache
description: XXFCache 缓存系统（内存 LRU + 磁盘 + @PreferenceWrapper KV）。当用户要做内存缓存、磁盘缓存、声明式 KV 存储，或询问"XXF 缓存选型"、"@PreferenceWrapper 怎么用"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFCache

内存 LRU、磁盘、声明式 KV 的统一缓存层。

## 触发场景

- 存用户偏好（Dark Mode、语言、是否显示引导）
- 网络响应缓存（与 `xxf-http` 拦截器联动）
- 内存级的短期数据（搜索历史、会话态）

## 选型决策（**必问**）

| 场景 | 用什么 |
|:------|:------|
| KV 键值对（User Default 语义） | `@PreferenceWrapper` |
| 内存 LRU（大对象、短生命周期） | `XXFCache` 内存层 |
| 磁盘缓存（图片、响应、草稿） | `XXFCache` 磁盘层 |
| 大容量 KV + 高性能 | `xxf-cache-mmkv`（需 Swift 6.2+） |
| 加密存储（token、密码） | `xxf-keychain` |

**token 类敏感数据绝对不用 `@PreferenceWrapper`**，走 `xxf-keychain`。

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFCache/**/*.swift
   Grep "public|PreferenceWrapper|Cache" in Sources/XXFCache/
   ```
2. 按场景选 API
3. 配置容量 / 过期策略（别用默认值就完事，要明确业务预期）

## 声明式 KV

```
@PreferenceWrapper(key: "user.theme", default: "system")
var theme: String
```

约定：
- key 用点号命名空间（`user.theme`、`app.lastOpenDate`）
- default 必须提供（避免 optional 污染业务层）
- key 集中声明（`App/Preferences.swift`），不散落

## 反模式

- 存 token → 用 Keychain
- 存大文件 → 用磁盘缓存，不塞进 UserDefaults
- key 拼魔法字符串
- LRU 不限容量（内存爆炸）

## 相关 skill

- `xxf-cache-mmkv` — 高性能 KV 替代
- `xxf-keychain` — 安全存储
