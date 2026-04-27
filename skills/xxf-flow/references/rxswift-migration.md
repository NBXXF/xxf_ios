# RxSwift → XXFFlow 迁移指南

本文档是 `xxf-flow` skill 的**进阶参考**。实际 API 以 `Sources/XXFFlow/` 为准，冲突时以源码为准。

## 0. 迁移前提

- 已读完 `Sources/XXFFlow/` 的公共接口
- 现有 RxSwift 有完整单测，迁移后能做等价回归
- 先迁一个**低风险**模块练手（比如设置页）

## 1. 类型映射

| RxSwift | XXFFlow（占位，读源码确认） |
|:------|:------|
| `Observable<T>` | `Flow<T>` |
| `Single<T>` | `SingleFlow<T>` |
| `Maybe<T>` | — 通常用 `Flow<T?>` 代替 |
| `Completable` | `CompletableFlow` |
| `PublishSubject` | `PublishRelay` / `FlowSubject` |
| `BehaviorSubject` | `BehaviorRelay` / `StateFlow` |
| `Driver<T>` | UI 绑定用，以源码为准 |
| `DisposeBag` | 框架提供的持有容器 |

## 2. 操作符映射

| RxSwift | XXFFlow |
|:------|:------|
| `.map` | `.map` |
| `.flatMap` | `.flatMap` |
| `.filter` | `.filter` |
| `.merge` | `.merge` |
| `.zip` | `.zip` |
| `.combineLatest` | `.combineLatest` |
| `.debounce` | `.debounce` |
| `.distinctUntilChanged` | `.distinctUntilChanged` |
| `.catchError` / `.catch` | `.catchError` |
| `.retry` | `.retry` |
| `.do(onNext:)` | `.doOnNext` / `.onEach` |

## 3. 线程切换

RxSwift：

```
.subscribe(on: ConcurrentDispatchQueueScheduler(qos: .background))
.observe(on: MainScheduler.instance)
```

XXFFlow：

```
.subscribeOnIO()
.observeOnMain()
```

语义等价，但**入口只调一次** `subscribeOn`；`observeOn` 可以在链中多次切换。

## 4. 热 / 冷流差异

- RxSwift `PublishSubject`：**热流**，订阅后才开始接收
- RxSwift `Observable.create`：**冷流**，每次订阅重新执行

XXFFlow 是否有相同语义？**读源码确认**，不要猜。迁移时保持热冷属性一致，否则会引入订阅行为差异。

## 5. 生命周期

### RxSwift

```swift
disposeBag = DisposeBag()
flow.subscribe(...).disposed(by: disposeBag)
```

### XXFFlow

以源码提供的容器为准。**每个 VC / ViewModel 必须持有**自己的容器，生命周期结束自动释放。

### 无限流

如 Bus 订阅、通知、心跳：
- 显式在 `deinit` 前 `cancel()`
- 或用 `takeUntil(lifecycle)` 绑定宿主销毁事件

## 6. 测试

- RxSwift 用 `TestScheduler` + `RxTest`
- XXFFlow 测试方案读 `Tests/XXFFlowTests/` 找范式
- 单测重点：事件顺序、错误传播、完成信号、取消行为

## 7. 迁移执行步骤

1. **选模块**：低耦合、有单测、业务稳定
2. **替换 import**：`import RxSwift` → `import XXFFlow`
3. **类型替换**：跟着编译错误改，优先 `Observable` → `Flow`
4. **操作符替换**：大多数同名直接可用
5. **线程 API**：统一改成 `subscribeOnIO` / `observeOnMain`
6. **生命周期**：替换 DisposeBag
7. **跑单测**：全部通过才算完成
8. **人肉走一遍**：关键链路手动验证（尤其是热流相关）
9. **观察线上**：灰度发布，看崩溃率 / 订阅异常

## 8. 禁区

- **不要**同一文件内混用 RxSwift 和 XXFFlow（会造成订阅链断裂）
- **不要**把 `Observable` 强转成 `Flow`（即便运行时兼容）
- **不要**迁移关键支付 / 登录链路而不做 A/B

## 9. 回滚策略

- 用 feature flag 包裹迁移模块
- 保留 RxSwift 原代码至少一个发版周期
- 记录订阅数量、错误数量的对比指标
