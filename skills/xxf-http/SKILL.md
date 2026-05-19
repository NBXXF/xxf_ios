---
name: xxf-http
description: 使用 XXFHttp 写网络接口。当用户要封装 REST API、GET/POST 请求、文件上传下载、SSE 流式响应、请求拦截器、错误统一处理，或说"用 XXFHttp 怎么…"、"网络层用 XXF 实现"时使用。若属于普通编码任务中的实现环节，应先经过 `xxf-aaa-delivery-loop` 再落到本 skill。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFHttp 网络层

## 触发场景

- 封装业务 API（登录、列表、详情等）
- SSE 流式响应（AI 对话、实时推送）
- 添加请求拦截器、签名、鉴权
- 统一错误处理、loading、重试
- 上传 / 下载文件

## 工作流

### 1. 读源码定 API（**必做**）

本技能不复述 API 细节。首先用 Grep / Read 从 `Sources/XXFHttp/` 获取当前版本的真实签名：

```
Glob Sources/XXFHttp/**/*.swift
Grep "public struct|public class|public protocol" in Sources/XXFHttp/
```

重点关注：
- 请求构造入口（通常是 `XXFHttp.request` 或类似）
- Response 结构体 / 错误类型
- 拦截器协议
- 与 XXFFlow 的集成点

### 2. 识别用户场景，生成代码

**场景 A：普通 REST API**  
先读 `Sources/XXFHttp/` 的示例用法，再按业务写 `XxxApi.swift`，封装接口定义而不是直接 call。

**场景 B：SSE 流式**  
查找源码中 SSE 相关入口（关键字：`SSE`、`stream`、`EventSource`、`text/event-stream`）。生成返回 `Flow<Event>` 的封装。

**场景 C：文件上传**  
查找 `multipart` / `upload` 相关 API。

### 3. 检查约定

- 接口封装层命名：`XxxApi` / `XxxService`(与项目现有风格保持一致,先 Grep 项目)
- 错误类型：复用 XXFHttp 提供的,**不要自造错误枚举**
- 线程：IO 请求用 `subscribeOnIO()`,回调回主线程用 `observeOnMain()`(需 `XXFFlow`)
- 鉴权：统一走拦截器,**不要在每个接口里塞 token**
- **Rx 请求首选带 `type:` 的 `request` 重载**（见 `Sources/XXFHttp/RxProxy/ReactiveProxy+Rx.swift`）：
  - ✅ 优先：`provider.rx.xxf.request(api, type: Foo.self)` → `Observable<Foo>`
  - ❌ 避免：`provider.rx.xxf.request(api).mapHttpResponse(Foo.self)`（除非需要原始 `Response`）
  - 原因：解析错误堆栈直接指向具体 API；在 `concat` / `flatMap` 等组合流中错误信息不丢失；省掉样板 `.mapHttpResponse`。
- **全程 `Observable`**,不用 `Single`。需要一次性消费在调用端 `take(1)` / `subscribe(onNext:)` 处理。

### 4. 测试点

提醒用户：
- 弱网 / 断网 分支
- 大包响应（内存）
- SSE 断开重连
- 拦截器与缓存的交互

## 反模式（禁止）

- 在 ViewController 里直接写 URLSession 调用
- 不加超时、不加错误处理的"乐观代码"
- 在拦截器里做阻塞 IO

## 深入阅读

具体范式和取舍详见 [references/patterns.md](references/patterns.md)。
