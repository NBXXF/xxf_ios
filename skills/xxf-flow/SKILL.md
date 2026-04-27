---
name: xxf-flow
description: 使用 XXFFlow 做响应式编程，或从 RxSwift / Combine 迁移到 XXFFlow。当用户提到 Observable、Single、Flow、操作符、subscribeOn/observeOn、线程切换、事件流，或询问"RxSwift 怎么换成 XXFFlow"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFFlow 响应式流

## 触发场景

- 写链式异步（网络 → 解析 → 更新 UI）
- 合并多个数据源（请求 + 缓存 + 推送）
- 迁移已有 RxSwift / Combine 代码
- 状态机（加载中 / 成功 / 失败 / 重试）

## 工作流

### 1. 读源码定 API

```
Glob Sources/XXFFlow/**/*.swift
Grep "public (struct|class|func|extension) " in Sources/XXFFlow/
```

必须确认的点：
- 核心类型名（Flow? FlowOf<T>? 具体以源码为准）
- 订阅 / 释放机制（DisposeBag 等价物）
- 线程调度 API（`subscribeOnIO` / `observeOnMain` 等）
- 与 XXFHttp 的桥接方式

### 2. 常见模式速查

**链式请求**
```
api.fetchUser()
    .flatMap { api.fetchProfile(userId: $0.id) }
    .subscribeOnIO()
    .observeOnMain()
    .subscribe { profile in ... }
```

**错误恢复**
```
flow.catchError { error in
    // 返回备选 flow 或空流
}
```

**状态机**  
把业务状态封装成 `enum State { case loading, success(T), error(Error) }`，用 flow 驱动。

### 3. 线程使用铁律

- **IO 操作**：`subscribeOnIO()`
- **UI 更新**：`observeOnMain()`
- **CPU 密集**：`subscribeOnCompute()`（如源码存在）
- 链中只切一次 `subscribeOn`；`observeOn` 可切多次

### 4. RxSwift 迁移映射

| RxSwift | XXFFlow（先读源码确认具体命名） |
|:------|:------|
| `Observable<T>` | 对应的 Flow 类型 |
| `Single<T>` | 单值 Flow |
| `Completable` | 空值 Flow |
| `Subject` | 对应的 Subject/Relay |
| `DisposeBag` | 对应的持有容器 |
| `.subscribe(onNext:)` | `.subscribe { ... }` |
| `.flatMap` | `.flatMap` |
| `.observe(on:)` | `.observeOn(...)` |

迁移步骤：

1. 先在一个小文件（低风险模块）上试跑
2. 替换 import，走编译器错误一条条改
3. **保留旧测试用例**，确保行为等价
4. 全量替换前跑一遍关键链路

### 5. 内存与生命周期

- 所有订阅必须绑定生命周期（VC / ViewModel 的释放容器）
- 不要用 `[strong self]`，默认 `[weak self]`
- 无限流（如 Bus 订阅）要在 `deinit` 前显式取消

## 反模式

- 在一个 flow 链里混用 `try?` 和 `catchError`（选一种）
- `subscribe` 后不持有订阅（导致立即释放）
- 在 `observeOnMain` 之后做耗时计算

## 深入阅读

RxSwift → XXFFlow 逐算子迁移表详见 [references/rxswift-migration.md](references/rxswift-migration.md)。
