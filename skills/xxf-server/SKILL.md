---
name: xxf-server
description: XXFServer 本地服务 / 网络基础能力（非业务 API，而是协议 / 本地 HTTP 服务器等底层能力）。当用户询问该模块具体职责时使用；不确定时先读源码再回答。
allowed-tools: Read, Glob, Grep
---

# XXFServer

**本模块职责需读源码确认**。名字较泛，可能是：
- 本地 HTTP 服务（Mock / 调试）
- 服务端能力抽象
- WebSocket / 长连
- DNS / 网络层工具

## 工作流

**第一步必做**：读源码判断具体职责，**不要凭名字猜**。

```
Glob Sources/XXFServer/**/*.swift
Read Sources/XXFServer/*.swift
Grep "public class|public struct|public protocol" in Sources/XXFServer/
```

然后根据读到的真实内容回答用户。

## 与其他模块的关系

- 如果是 HTTP 客户端能力 → 常与 `xxf-http` 配合
- 如果是 Mock Server → 测试用途
- 如果是本地服务 → 调试工具

## 反模式

- 未读源码就告诉用户"这是做 XXX 的"
- 跳过 `xxf-http` 抽象直接用 XXFServer（如果是客户端能力）
