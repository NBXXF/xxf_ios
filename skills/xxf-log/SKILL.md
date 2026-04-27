---
name: xxf-log
description: XXFLog 日志系统。当用户要统一日志输出、接入 Pulse 可视化、按级别过滤、按模块分类，或询问"XXF 怎么打日志"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFLog

统一日志 + Pulse 可视化。替代散落的 `print` / `NSLog` / 自建 logger。

## 触发场景

- 接入项目前配置日志
- 开发期排查问题（实时查看日志）
- 线上日志脱敏 / 等级过滤
- Pulse 网络日志浏览

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFLog/**/*.swift
   Grep "public|log|Pulse|level" in Sources/XXFLog/
   ```
2. 启动期配置：
   - 日志等级（Debug / Release 差异化）
   - 输出目标（Console / 文件 / Pulse）
   - 脱敏规则
3. 业务层只用统一接口（如 `XXFLog.info(...)`），禁止 `print`

## 日志等级约定

- `verbose` — 高频细节（默认 release 关闭）
- `debug` — 开发期调试信息
- `info` — 关键业务事件（如登录成功）
- `warn` — 可恢复异常
- `error` — 不可恢复 / 业务错误

## 脱敏

- 手机号 / 邮箱 / token / 密码**必须脱敏**
- 脱敏规则集中在配置里，不要每处调用都手动遮盖

## 反模式

- `print` / `NSLog` 散落各处
- Release 开 verbose（性能 + 磁盘）
- 日志里拼完整 JSON 不截断（大响应撑爆日志文件）
- 敏感信息未脱敏

## 相关 skill

- `xxf-performance` — 性能日志 / 卡顿
