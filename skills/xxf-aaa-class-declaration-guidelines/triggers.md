# xxf-aaa-class-declaration-guidelines — 触发用例

## 应该触发

- "这个 VC 变量太多了，帮我分区整理"
- "这个 ViewModel 状态变量太多了，帮我分区整理"
- "方法太乱了，按 MARK 分类"
- "把 UI / 状态 / 入参分开"
- "把 stateA/stateB/pageIndex 这些按职责分区"
- "这个控制器可读性太差，整理结构"
- "这个 ViewModel 可读性太差，整理结构"
- "新建 Swift 文件时把头注释补完整（文件名/项目名/Created by/作用）"
- "给 VC/VM 文件自动推断并填充头注释"

## 不应该触发

- "这个接口超时怎么排查" → 应走对应网络或排障 skill
- "这个 PR 能不能放行" → 应走 `xxf-aaa-risk-gate`
- "帮我设计测试策略" → 应走 `xxf-aaa-test-strategy`

## 边界用例

- "先别改业务，只整理 VC 结构"
  - 期望：触发，仅做分区、重排、MARK 补全与必要的 extension 拆分
- "先别改业务，只整理 ViewModel 结构"
  - 期望：触发，仅做分区、重排、MARK 补全与命名统一
