---
name: xxf-performance
description: XXFPerformance 性能监控（主线程卡顿 / FPS / CPU / 内存 / 悬浮窗）。当用户要检测卡顿、实时看 FPS / CPU / 内存、定位性能瓶颈时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFPerformance

主线程卡顿检测 + FPS / CPU / 内存实时监控悬浮窗。

## 触发场景

- 开发期开悬浮窗实时看指标
- 检测主线程卡顿，自动上报堆栈
- 定位某页面性能瓶颈

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFPerformance/**/*.swift
   Grep "public|Performance|FPS|Monitor" in Sources/XXFPerformance/
   ```
2. 启动期开启（Debug / 内测开，Release 默认关）
3. 卡顿回调对接到 `xxf-log` 或 `xxf-tracker`

## 配置项

- 卡顿阈值（通常 16.7ms × 3 帧 = 50ms）
- 采样频率
- 悬浮窗位置
- 是否采集堆栈（生产环境注意隐私）

## 反模式

- 生产环境常开悬浮窗（影响性能）
- 未脱敏就上传卡顿堆栈（含用户路径、参数）
- 用它替代 Instruments 做深度剖析（互补关系）

## 相关 skill

- `xxf-log` — 卡顿输出到日志
- `xxf-tracker` — 卡顿作为性能埋点上报
- `xxf-troubleshooting` — 性能问题总入口
