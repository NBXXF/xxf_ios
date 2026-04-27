# xxf-module-scaffold — 触发用例

**本 skill 服务 XXF 框架维护者，不是业务方。** 业务方 prompt 不应触发。

## 应该触发

- "给 xxf_ios 加一个新模块 XXFAnalytics"
- "想拆一个 XXFImageEditorNew 的 Provider 实现"
- "XXFHudiOS 的 macOS 版本怎么加"
- "Package.swift 里新增 target 的规则是什么"

## 不应该触发

- "业务里怎么用 XXFHttp" → 应走 `xxf-http`
- "XXF 有哪些模块" → 应走 `xxf-quickstart`
- "新建一个 iOS 项目" → 与 XXF 框架内部无关

## 边界用例

- "给我的业务 App 新建一个模块"
  - 期望：**不触发**，模型应澄清"这个 skill 用于扩展 XXF 框架本身，业务模块请用 Xcode 向导"
- "XXFCacheMMKV 是怎么做条件编译的"
  - 期望：触发（内部实现细节、维护者关心）
