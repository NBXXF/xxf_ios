---
name: xxf-di
description: XXFDi 依赖注入容器。当用户要注册 / 解析服务、做模块解耦、或询问"XXF 怎么做 DI"、"@Injected 怎么用"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFDi

XXF 轻量依赖注入容器，用于模块间解耦、测试替换、运行时策略切换。

## 触发场景

- 注册服务 / 解析服务
- 用 property wrapper（如 `@Injected`，以源码为准）消除手动 getter
- 单测时 mock 替换实现

## 工作流

1. 读源码：
   ```
   Glob Sources/XXFDi/**/*.swift
   Grep "public|Injected|register|resolve" in Sources/XXFDi/
   ```
2. 在启动期集中注册（`AppDelegate` / `SceneDelegate`），或用每模块自注册机制
3. 业务层**只依赖协议**，不知道具体实现

## 注册时机（**强约定**）

- 启动期：所有全局单例型服务
- 懒加载：大对象、按需启用的功能
- 禁止在 ViewController 里临时注册（不可测、难追踪）

## 反模式

- 把 DI 容器当 Service Locator 满天飞
- 注册后不注销，单测互相污染
- 循环依赖（DI 容器大多检测不到）

## 相关 skill

- `xxf-adapter` — Provider 切换场景常与 DI 配合
- `xxf-viewmodel` — VM 构造时从 DI 拿依赖
