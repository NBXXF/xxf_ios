# Changelog

本 Skill 集合遵循 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/) 与 [语义化版本 2.0.0](https://semver.org/lang/zh-CN/)。

> 版本号含义：
> - **MAJOR** — SKILL 的 `name` / `description` 触发词有破坏性改动（可能影响现存 Agent 路由）
> - **MINOR** — 新增 skill、新增 reference、扩展触发场景
> - **PATCH** — 文档修订、错别字、内部重构

## [Unreleased]

### Added
- `install.sh` —— 一键安装 / 升级脚本，支持 Claude Code / Codex CLI / Cursor
  - Claude Code：`git clone` 到 `~/.cache/xxf-ios-skills` + 软链到目标目录，升级只需重跑脚本或 `git pull` 缓存
  - Codex CLI：在项目 `AGENTS.md` 注入受控引用块（`<!-- BEGIN/END -->` 标记），幂等刷新
  - Cursor：`.cursor/rules/*.mdc` 拷贝（Cursor 对软链支持不稳定）

### Changed
- README 安装章节重写：不再推荐 `cp -r`（每次升级都要重来），改用脚本 + 软链模式
- 新增 Codex CLI 小节（之前缺失）

---

## [0.2.0] — 2026-04-27

### Added — 模块全覆盖（42 个新 skill）

**基础设施（6）**：xxf-foundation、xxf-extensions、xxf-adapter、xxf-arch、xxf-di、xxf-bus

**存储与数据（8 新）**：xxf-cache、xxf-cache-mmkv、xxf-keychain、xxf-database-grdb、xxf-database-objectbox、xxf-datasource、xxf-json、xxf-identifier

**UI 底座（6）**：xxf-uikit、xxf-appkit、xxf-hud、xxf-hud-ios、xxf-hud-mac、xxf-keyboard

**UI 辅助（3）**：xxf-reusable、xxf-refreshable、xxf-viewmodel

**图片（8）**：xxf-image、xxf-image-loader、xxf-image-nuke-loader、xxf-image-editor、xxf-image-editor-brightroom、xxf-photo-picker、xxf-photo-picker-zl、xxf-compress

**观测与埋点（8）**：xxf-log、xxf-performance、xxf-tracker、xxf-tracker-firebase、xxf-tracker-sentry、xxf-tracker-bugsnag、xxf-event-reporter、xxf-event-reporter-firebase

**网络辅助（2）**：xxf-server、xxf-speed

**工程化（1）**：xxf-swift-format

### Changed
- `xxf-database` 缩窄为抽象层专属，GRDB / ObjectBox 相关内容拆到各自子 skill
- README 按类别重组 skill 清单，并建议按需安装（49 个全装会占路由预算）

### Design decisions
- 每个模块一个 skill：与库目录 1:1 对应，便于查找和维护
- Provider / 平台变体 skill 保持简短，主要职责是说"去用抽象层"，避免信息重复
- 命名空间级 skill（`xxf-server`、`xxf-speed`）要求 AI **先读源码再回答**，避免凭名字臆测
- 跨 skill 引用通过正文"相关 skill"段落表达，不引入 frontmatter 级依赖字段

---

## [0.1.0] — 2026-04-27

### Added
- `xxf-quickstart` — 接入与模块选型助手
- `xxf-http` — 网络层范式，含 `references/patterns.md`（分层 / 拦截器 / SSE / 上传下载）
- `xxf-router` — 路由框架，含 `references/patterns.md`(路由 key 管理 / 拦截器职责 / 降级链 / URL 映射)
- `xxf-database` — 持久化 + GRDB/ObjectBox 选型指引
- `xxf-flow` — 响应式流，含 `references/rxswift-migration.md`(类型/操作符/线程映射)
- `xxf-module-scaffold` — 框架维护者新增模块脚手架
- `xxf-troubleshooting` — 编译 / 崩溃 / 性能速查
- 多 Agent 安装指南（Claude Code / Cursor / CodeBuddy / Submodule / 自建）
- CI lint（frontmatter / name-dir 匹配 / 死链）
- 每个 skill 的 `triggers.md` 评测用例

### Design decisions
- 不做根 `SKILL.md` 路由层，交由各 skill `description` 自行路由（与 Anthropic Skills 规范一致）
- Skill 不复述源码 API，统一引导 AI 阅读 `Sources/XXFxxx/` 获取当前真实签名
- `allowed-tools` 按需白名单，只读 skill 不授予 Write/Edit

[Unreleased]: https://github.com/NBXXF/xxf_ios/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/NBXXF/xxf_ios/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/NBXXF/xxf_ios/releases/tag/v0.1.0
