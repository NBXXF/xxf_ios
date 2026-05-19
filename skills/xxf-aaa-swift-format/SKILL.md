---
name: xxf-aaa-swift-format
description: XXFSwiftFormat 代码格式化集成。当用户要在项目里接入 SwiftFormat、配置规则、CI 校验，或询问"XXF 代码风格工具"时使用。
allowed-tools: Read, Glob, Grep, Edit, Write
---

# XXFSwiftFormat

集成 SwiftFormat 的规则和配置，统一团队代码风格。

## 触发场景

- 新项目接入 XXF 时统一代码风格
- 修改 SwiftFormat 规则
- CI 做格式校验
- pre-commit hook 集成

## 工作流

1. 读源码 / 配置：
   ```
   Glob Sources/XXFSwiftFormat/**/*.swift
   Glob .swiftformat .swiftformat.yml
   ```
2. 查看 XXF 推荐规则，对齐
3. 业务方可以覆盖局部规则，**尽量少覆盖**以保持一致性

## CI 集成

```bash
swiftformat --lint . --config .swiftformat
```

不通过则 CI 红。本地开发用 pre-commit：

```bash
swiftformat . --config .swiftformat
```

## 反模式

- 每个业务方各自魔改规则
- 用 SwiftFormat 覆盖团队其他人已定的风格
- 格式化覆盖了第三方代码（要用 `--exclude`）

## 相关 skill

- `xxf-aaa-module-scaffold` — 新模块遵守格式规则
