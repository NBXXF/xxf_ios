---
name: xxf-webview
description: 使用 XXFWebView 的 Bridge 做 Web 与 Native 双向通信。当用户要在 H5 与 iOS 之间发消息、发请求、注册处理器、约定事件协议，或询问“bridge 怎么接”时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFWebView Bridge 双向通信

## Channel 约定（先看这个）

- `handleWebEvent`：**H5 -> Native** 调用入口
  - H5 通过 `bridge.call('handleWebEvent', request, callback)` 发给 Native
  - Native 在 `WebEventInterface` 中暴露该异步方法并分发到 `onWebEvent` / `eventHandlerRegistry`
- `nativeEvent`：**Native -> H5** 调用入口
  - Native 通过 `BridgeWebView.postEvent(...)` 调 H5 的 `nativeEvent`
  - H5 需要 `dsBridge.registerAsyn('nativeEvent', handler)` 接收并回包

## 触发场景

- H5 调 Native（例如：获取登录态、打开页面、调用相机）
- Native 调 H5（例如：下发配置、触发页面刷新、回传操作结果）
- 设计统一事件协议（eventName、payload、requestId、direction）
- 排查 bridge 调用失败、方向错误、事件名冲突

## 工作流

### 1. 先读源码确认真实 API（必做）

```
Glob Sources/XXFWebView/**/*.swift
Grep "Bridge|WebEvent|Handler|request|response|direction" in Sources/XXFWebView/
```

重点文件通常包括：
- `Sources/XXFWebView/Bridge/BridgeWebView.swift`
- `Sources/XXFWebView/Bridge/WebEventInterface.swift`
- `Sources/XXFWebView/Bridge/Model/WebEventRequest.swift`
- `Sources/XXFWebView/Bridge/Model/WebEventResponse.swift`
- `Sources/XXFWebView/Bridge/Model/WebEventDirection.swift`
- `Sources/XXFWebView/Bridge/Handler/WebEventHandler*.swift`

不要凭记忆输出签名，先以当前仓库代码为准。

### 2. 建立通信协议（强制约定）

- 事件名稳定且可枚举，避免散落字符串
- payload 使用可序列化 JSON 结构，字段可演进（新增字段不破坏旧端）
- 当前模型未内建 `requestId` 字段；如业务需要请求-响应关联，请在 `data` 中自行携带（例如 `data.requestId`）
- 明确方向（通过 `WebEventDirection` 给 `event` 加前缀）：
  - `nativeToWeb`：Native 发给 H5
  - `webToNative`：H5 发给 Native
  - `unknown`：兜底，不参与正常业务分发

### 3. App（Native）怎么调用

#### 3.1 Native -> H5（调 `nativeEvent`）

```swift
let request = WebEventRequest(
    name: "nativeMessage",
    direction: .nativeToWeb,
    data: ["text": "hello from native"]
)

bridgeWebView.postEvent(
    request,
    expecting: WebEventResponse<AnyCodable>.self
) { result in
    // 处理 H5 回包
}
```

要点：
- `postEvent` 内部固定调用 channel：`nativeEvent`
- `event` 最终会是带前缀的字符串（如 `ntw:nativeMessage`）
- 业务层不要直接 `evaluateJavaScript` 拼桥接调用

#### 3.2 接收 H5 -> Native（处理 `handleWebEvent`）

```swift
bridgeWebView.onWebEvent = { request, callback in
    // request.event / request.data
    callback(.success(data: AnyCodable(["reply": "native received"])))
}
```

或使用 `eventHandlerRegistry` 做按事件名分发。

### 4. H5 怎么调用

#### 4.1 H5 -> Native（调 `handleWebEvent`）

```javascript
const request = {
  // 推荐与 Native 统一：带方向前缀（wtn:）
  // 若历史包袱使用裸事件名（webMessage），Native 侧需兼容两种写法
  event: "wtn:webMessage",
  data: { text: "hello from h5" }
}

bridge.call("handleWebEvent", request, function(response) {
  // response: { code, message, data }
})
```

#### 4.2 接收 Native -> H5（注册 `nativeEvent`）

```javascript
dsBridge.registerAsyn("nativeEvent", function(request, callback) {
  // request: { event, data }，event 可能带 ntw: 前缀
  callback({
    code: 200,
    message: "h5 received",
    data: { ok: true }
  })
})
```

### 5. Web -> Native 处理约束（Native 侧）

- Native 侧有两种入口：
- `onWebEvent`：单入口直接处理（优先级高）
- `eventHandlerRegistry`：按事件名分发（`onWebEvent` 未设置时生效）
- 根据项目规模二选一或组合，保持全局一致
- handler 内做参数校验，失败返回结构化错误，不要 silent fail
- 耗时任务异步执行，完成后通过 response 回包，不阻塞主线程
- 涉及权限/登录的能力必须加鉴权校验

### 6. 错误与可观测性

- 每次收发至少记录：eventName、requestId、direction、耗时、结果码
- 解析错误、事件未注册、超时都要明确日志
- 对外返回可读错误码，便于 H5 与 Native 联调

## 常见反模式（禁止）

- H5/Native 双方各自维护一套事件名，未集中管理
- 不带 requestId 的“裸消息”用于请求-响应场景
- 捕获错误后直接吞掉，只返回空成功
- 在业务层直接操作 `WKWebView.evaluateJavaScript` 代替 Bridge

## 建议产物

- `XxxBridgeEvents.swift`：事件名与 payload key 常量
- `XxxWebEventHandler.swift`：按能力拆分 handler（登录、路由、设备能力）
- `BridgeDebugLogger.swift`：统一收发日志与耗时埋点
