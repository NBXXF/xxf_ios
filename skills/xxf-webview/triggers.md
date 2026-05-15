# xxf-webview — 触发用例

## 应该触发

- "H5 调 Native 事件怎么接"
- "Native 给 Web 发消息怎么做"
- "Bridge 的 event 命名和方向怎么约定"
- "WebView 双向通信失败怎么排查"

## 不应该触发

- "WKWebView 原生基础用法" → 偏系统 API 教程
- "路由跳转规则" → 应走 `xxf-router`

## 边界用例

- "要在 bridge 里做登录态透传"
  - 期望：触发，并要求事件协议 + 权限校验 + 错误回包
