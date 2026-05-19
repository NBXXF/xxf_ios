# xxf-aaa-quickstart — 触发用例

用于回归测试：改动 `SKILL.md` 的 `description` 后，确认下列 prompt 仍被正确路由。

## 应该触发

- "新项目想用 XXF，该怎么开始？"
- "XXF iOS 集成需要哪些最低版本？"
- "我只需要网络层，应该引哪些模块？"
- "XXFArch 和单模块引入有什么区别？"
- "给我一个 Package.swift 集成 XXF 的示例"
- "用 XXF 替换现有的 Alamofire + RxSwift 架构，从哪里入手？"

## 不应该触发

- "XXFHttp 拦截器怎么写" → 应走 `xxf-http`
- "路由跳转带参数怎么传" → 应走 `xxf-router`
- "XXF 编译报 no such module" → 应走 `xxf-aaa-troubleshooting`
- "XCTest 怎么写" → 与 XXF 无关，不触发任何 xxf skill

## 边界用例（容易误触发）

- "iOS 新项目怎么搭建？"
  - 期望：**不触发**（未提到 XXF，属于通用问题）
- "XXF 的 XXFArch 是什么？"
  - 期望：触发（名词即意图）
