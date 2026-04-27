# xxf-http — 触发用例

## 应该触发

- "帮我用 XXFHttp 写一个登录接口"
- "XXF 网络层怎么加拦截器？"
- "用 XXFHttp 做 SSE 流式响应"
- "我要在项目里统一错误处理，XXFHttp 怎么做？"
- "XXFHttp 怎么上传文件？"
- "接口返回 401 怎么自动跳登录"（涉及 http 拦截器）

## 不应该触发

- "用 URLSession 写请求" → 不涉及 XXF，不触发
- "XXFRouter 拦截器怎么写" → 应走 `xxf-router`
- "后端的 HTTP 超时应该设多久" → 与客户端无关

## 边界用例

- "XXF 怎么做网络缓存"
  - 期望：触发 `xxf-http`（拦截器级缓存），**但**如果涉及磁盘缓存存储，可能也需 `xxf-cache`（本集暂未提供）— 模型应在 `xxf-http` 内提示"缓存策略见 XXFCache"
- "用 XXFFlow 串接 HTTP 请求"
  - 期望：`xxf-http` 和 `xxf-flow` 都相关，模型优先 `xxf-http`（意图是写接口），在响应式链部分引用 `xxf-flow`
