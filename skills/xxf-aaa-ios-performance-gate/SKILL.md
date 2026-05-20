---
name: xxf-aaa-ios-performance-gate
description: iOS 性能门禁与主动鉴别。针对常规 coding 改动自动识别性能风险（主线程阻塞、列表卡顿、内存抖动、启动耗时、无效并发、过度渲染），并执行最小可行验证与门禁结论，不依赖用户额外提示。
allowed-tools: Read, Glob, Grep, Edit, Write, Bash
---

# iOS 性能门禁（Performance Gate）

## 资源来源

- 第三方实践（已吸收）：`https://github.com/dpearson2699/swift-ios-skills/tree/main/skills/swiftui-performance`
- 官方参考（Profiling 方法）：`https://developer.apple.com/videos/play/wwdc2025/306/`

## 价值评估（复制 + 优化）

- 已复制的高价值部分：
  - Code-First → Profile → Analyze → Remediate → Verify 的闭环
  - SwiftUI identity/lifetime 与依赖扇出诊断模型
  - Long Updates 与 Frequent Updates 的分流诊断
  - Instruments 取证优先级（SwiftUI lane + Time Profiler + Hangs）
- 已优化为本仓可执行版本：
  - 增加“主动执行”门禁策略（无需用户额外提示）
  - 增加 `Block / Warn / Pass` 放行决策
  - 增加本仓可直接执行的最小验证命令与风险等级规则
  - 扩展到 UIKit / 列表 / 图片 / 启动链路，不只限 SwiftUI

## 触发场景

- 日常 iOS 编码改动，且触及以下任一性能敏感区域：
  - UI 渲染与布局（`UIView`/`SwiftUI`/`UITableView`/`UICollectionView`）
  - 图片加载与解码、缓存
  - 主线程上的 I/O、JSON 解析、数据库操作、同步网络
  - 启动路径（`AppDelegate` / `SceneDelegate` / 初始化单例）
  - 高频事件链路（滚动、输入、动画、定时器、通知）
  - 并发模型（Task/GCD/Rx）变更
- 用户明确提到“卡顿/慢/耗电/内存涨/FPS 掉/启动慢”

## 目标

- 主动鉴别：在实现后自动判断是否存在性能退化风险。
- 主动执行：在可运行前提下执行最小性能验证，不只给建议。
- 主动结论：输出 `Block / Warn / Pass` 与最小修复路径。

## 默认行为

1. 读取改动 diff 与调用链，识别性能敏感点。
2. 做静态风险扫描（主线程阻塞、重复渲染、无上限并发、过度分配）。
3. 若触及 SwiftUI，执行 SwiftUI 专项审计（身份稳定性、`body` 重计算、观察域污染、惰性容器误用）。
4. 选择最小验证入口：
   - 能跑测试：执行最小相关测试
   - 不能跑测试：执行编译级验证 + 静态证据
5. 给出性能门禁结论：`Block / Warn / Pass`。
6. 若 `Block/Warn`，给出最小修复路径与补测建议。

## Workflow Decision Tree

- 用户已提供代码：直接做 Code-First Review。
- 只有症状描述：先索要最小可复现上下文，再做 Code-First Review。
- 代码审计证据不足：进入 Profile 取证，收集 trace 再诊断。

## 主动鉴别规则

### High（默认 Block）

- 主线程同步阻塞：`DispatchQueue.main.sync`、主线程执行重 I/O/重解析/重查询。
- 明确 O(n²)+ 热路径循环或重复全量排序/过滤。
- 无边界并发：无限制创建 Task/线程/请求。
- 启动链路中重资源初始化且无延迟策略。

### Medium（默认 Warn）

- 列表 cell 内重复创建重对象/重复解码。
- 频繁 layout/reload 无差分更新。
- 缓存策略缺失（无容量、无失效、无命中观测）。
- 日志/埋点在高频路径过重。
- SwiftUI 中以下模式命中任一：
  - `DateFormatter` / `NumberFormatter` 在 `body` 内反复创建
  - 在 `body` / `ForEach` 内排序、过滤、重计算
  - `ForEach` 使用不稳定 identity（如渲染期 `UUID()`）
  - `GeometryReader` 置于 `Lazy*` / `List` 热路径
  - 顶层 `if/else` 频繁切根视图导致 identity churn

### Low（默认 Pass with debt）

- 有优化空间但暂无明显回归证据。

## Analyze and Diagnose（核心复制）

将问题先分为两类，再选修复路径：

1. Long Updates（单次更新太慢）：
  - 常见根因：`body` 内重计算、主线程解码、布局抖动、Representable 更新过重
  - 典型策略：把重计算移出 `body`，预计算并缓存，简化布局链路
2. Frequent Updates（更新过于频繁）：
  - 常见根因：状态依赖面过宽、观察模型扇出、几何/定时信号噪声
  - 典型策略：收窄依赖面，拆分状态域，阈值化或去抖连续信号

优先顺序：先判断是 “长” 还是 “频”，再落定修复；避免混修。

## 最小验证策略

1. 静态扫描（必须）

```bash
rg -n "DispatchQueue\.main\.sync|Data\(contentsOf:|try!|as!|reloadData\(|layoutIfNeeded\(|setNeedsLayout\(|for .* in .*for .* in" Sources --glob '*.swift'
```

2. 构建验证（至少其一）

- SwiftPM：`swift build --target <affected_target>`
- 工程：最小可行 `xcodebuild` 构建目标

3. 测试验证（可用则执行）

- 最小相关测试集（优先受影响模块）

4. 运行期观测（有条件时）

- 使用 `xxf-performance` 进行 FPS/CPU/内存/卡顿观测
- 关键路径至少跑一次用户流并记录观测结论
- SwiftUI 页面优先补充：
  - Release build + 真机 Instruments（SwiftUI 模板 + Time Profiler）
  - 必要时在 Debug 用 `Self._printChanges()` 辅助识别重绘触发源

## SwiftUI 专项鉴别（复制 + 优化）

1. Code-First Review（先看代码）：
  - 是否存在 broad state 触发 invalidation storm
  - identity 是否稳定（列表与条件分支）
  - heavy work 是否被留在 `body`
2. Profile（再取证）：
  - Release + 真机 + 可复现实操路径（滚动/导航/动画）
  - 收集 SwiftUI lanes 与 Time Profiler 证据
3. Remediate（定向修复）：
  - 缩小状态作用域到叶子视图
  - 预计算/缓存重计算结果，移出 `body`
  - 稳定 `ForEach` identity，减少根视图切换抖动
  - 图片降采样与主线程解码迁移
4. Verify（复测对比）：
  - 对比前后 CPU、掉帧、内存峰值

## Common Code Smells（高价值规则）

- `body` 内创建 `DateFormatter` / `NumberFormatter` / `MeasurementFormatter`
- `ForEach(items.sorted/filter(...))` 在渲染期排序过滤
- `ForEach` 使用不稳定 ID（如 `id: \\.self` 且值不稳定、或渲染期 `UUID()`）
- 顶层 `if/else` 切换根视图造成 identity churn
- 在热路径使用 `AnyView` 擦除类型，损失结构信息
- 主线程 `UIImage(data:)` 解码大图
- `GeometryReader` + 状态回写造成布局反馈回路

修复方向：预计算、稳定 identity、收窄观察域、将重工作移出渲染路径。

## 与其他 skill 的协作边界

- 本 skill 负责“性能风险识别 + 最小验证 + 门禁结论”。
- 具体补测交给 `xxf-aaa-unit-test-writer`。
- 具体执行测试交给 `xxf-aaa-auto-test-orchestrator`。
- 代码问题细化交给 `xxf-aaa-code-reviewer`。
- 发布放行汇总交给 `xxf-aaa-risk-gate`。

## 输出模板

1. Performance Findings（按严重级别）
2. Evidence（命令/输出/代码定位）
3. Gate Decision（Block / Warn / Pass）
4. Minimal Fix Path
5. Residual Risk

## 快速参考

- 风险检查清单：`references/perf-checklist.md`
- 常见反模式：`references/perf-anti-patterns.md`
