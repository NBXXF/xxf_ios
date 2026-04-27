---
name: xxf-troubleshooting
description: 排查 XXF iOS 相关的编译错误、运行时崩溃、性能问题。当用户贴出编译错误日志、崩溃栈、卡顿报告、内存警告，或说"XXF 报错"、"用了 XXF 后变慢"时使用。
allowed-tools: Read, Glob, Grep, Bash
---

# XXF iOS 故障排查

## 触发场景

- 编译失败（SPM 解析错误、符号找不到、Swift 版本不匹配）
- 运行时崩溃（EXC_BAD_ACCESS、死锁、类型转换失败）
- 性能问题（启动慢、卡顿、内存涨）
- Provider / 多实现冲突

## 第一步：分类

让用户描述或贴出 **完整错误信息**；**不要凭猜测给答案**。

## 常见问题速查

### A. 编译错误

| 症状 | 可能原因 | 处理 |
|:------|:------|:------|
| `no such module 'XXFxxx'` | Package.swift 未加 dependency | 检查 `.product(name:...)` |
| `XXFCacheMMKV` 找不到 | Swift < 6.2 | 升级 Swift 或改用 `XXFCache` |
| 符号重复定义 | 同时引入 `XXFArch` 和单模块 | 二选一 |
| `iOS 13` 不支持 | 部署目标过低 | 提升到 iOS 15+ |

### B. 运行时崩溃

| 症状 | 可能原因 | 处理 |
|:------|:------|:------|
| Router 找不到目标 | 未注册 / key 拼错 | 检查路由常量、注册时机 |
| Flow 订阅立即释放 | 未持有订阅 | 绑定生命周期容器 |
| 数据库死锁 | 并发写 + 未串行化 | 写入走同一队列 |
| Cache miss 雪崩 | 无锁并发 | 用 XXFCache 内置并发保护 |

### C. 性能问题

| 症状 | 可能原因 | 处理 |
|:------|:------|:------|
| 启动慢 | 在 `+load` / `init` 做重活 | 延迟到 `didFinishLaunching` 之后 |
| 首屏白屏 | 同步请求阻塞 | 改异步，展示骨架屏 |
| 滚动卡顿 | 主线程 IO / 图片解码 | 用 `XXFPerformance` 监测并迁到后台 |
| 内存持续上涨 | 订阅泄漏 / 缓存无淘汰 | 检查 DisposeBag、LRU 配置 |

## 工作流

### 1. 收集信息

要求用户提供：
- 完整错误栈 / 编译输出
- `swift --version`、`Xcode` 版本
- `Package.resolved` 片段（确认 XXF 版本）
- 复现步骤

### 2. 定位

```bash
# 确认 XXF 版本
grep "xxf_ios" Package.resolved -A 5

# 搜索错误相关符号
Grep "ErrorSymbol" in Sources/
```

### 3. 最小复现

如果问题难定位，建议用户剥离到一个 **最小 demo**（只保留触发 bug 的代码），通常过程中就能自己找出原因。

### 4. 反馈

确认是 XXF 框架 bug 后，引导用户提 issue：

- 仓库：`https://github.com/NBXXF/xxf_ios/issues`
- 模板：环境信息 + 最小复现 + 期望 / 实际行为

## 禁止

- 不要劝用户 "关掉 XXFPerformance 就好了"（除非确认是监测本身的 bug）
- 不要建议降级 Swift 版本绕开错误（先确认是否真的不兼容）
- 不要修改 XXF 框架源码来"暂时解决"用户的业务问题，除非确认是框架 bug
