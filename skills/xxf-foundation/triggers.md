## 应该触发

- "XXFFoundation 里有哪些协议"
- "线程工具 XXF 提供了吗"
- "XXF 的基础类型定义在哪"

## 不应该触发

- "Foundation 的 URLSession 怎么用" → 是 Apple Foundation，不是 XXFFoundation
- "怎么发网络请求" → 应走 `xxf-http`

## 边界用例

- "扩展 String 方法" → 先查 `XXFExtensions`，不在再考虑 `XXFFoundation`
