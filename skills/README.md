# XXF iOS Skills

为使用 [XXF iOS](../README.md) 框架的业务方提供的 AI Skill 集合。遵循 [Anthropic Agent Skills 规范](https://docs.anthropic.com) —— 每个子目录一个 `SKILL.md`，YAML frontmatter + markdown，无专有格式。

---

## 一、Skill 清单

共 **65 个** skill，按类别分组。每个 skill 目录下有 `SKILL.md`（AI 读）和 `triggers.md`（回归用例）。

### 元 skill（路由 / 维护）

| 技能 | 触发场景 |
|:------|:------|
| `xxf-quickstart` | 新项目接入、模块选型、版本排查 |
| `xxf-troubleshooting` | 编译 / 运行时 / 性能故障排查 |
| `xxf-module-scaffold` | 框架维护者新增模块（非业务方） |

### 基础设施

| 技能 | 对应模块 |
|:------|:------|
| `xxf-foundation` | XXFFoundation |
| `xxf-extensions` | XXFExtensions |
| `xxf-adapter` | XXFAdapter |
| `xxf-arch` | XXFArch |
| `xxf-di` | XXFDi |
| `xxf-bus` | XXFBus |

### 网络与响应式

| 技能 | 对应模块 |
|:------|:------|
| `xxf-http` | XXFHttp |
| `xxf-server` | XXFServer |
| `xxf-flow` | XXFFlow |
| `xxf-speed` | XXFSpeed |

### 路由

| 技能 | 对应模块 |
|:------|:------|
| `xxf-router` | XXFRouter |

### 存储与数据

| 技能 | 对应模块 |
|:------|:------|
| `xxf-cache` | XXFCache |
| `xxf-cache-mmkv` | XXFCacheMMKV（需 Swift 6.2+） |
| `xxf-keychain` | XXFKeychain |
| `xxf-database` | XXFDatabase（抽象层） |
| `xxf-database-grdb` | XXFDatabaseGrdb |
| `xxf-database-objectbox` | XXFDatabaseObjectBox |
| `xxf-datasource` | XXFDataSource |
| `xxf-json` | XXFJson |
| `xxf-identifier` | XXFIdentifier |

### UI

| 技能 | 对应模块 |
|:------|:------|
| `xxf-uikit` | XXFUIKit |
| `xxf-appkit` | XXFAppkit（macOS） |
| `xxf-hud` | XXFHud |
| `xxf-hud-ios` | XXFHudiOS |
| `xxf-hud-mac` | XXFHudMac |
| `xxf-keyboard` | XXFKeyboard |
| `xxf-reusable` | XXFReusable |
| `xxf-refreshable` | XXFRefreshable |
| `xxf-viewmodel` | XXFViewModel |

### Web 与页面容器

| 技能 | 对应模块 |
|:------|:------|
| `xxf-webview` | XXFWebView |

### 图片

| 技能 | 对应模块 |
|:------|:------|
| `xxf-image` | XXFImage |
| `xxf-image-loader` | XXFImageLoader |
| `xxf-image-nuke-loader` | XXFImageNukeLoader |
| `xxf-image-editor` | XXFImageEditor |
| `xxf-image-editor-brightroom` | XXFImageEditorBrightroom |
| `xxf-photo-picker` | XXFPhotoPicker |
| `xxf-photo-picker-zl` | XXFPhotoPickerZl |
| `xxf-compress` | XXFCompress |
| `xxf-qrcode` | XXFQRCode |

### 观测与埋点

| 技能 | 对应模块 |
|:------|:------|
| `xxf-log` | XXFLog |
| `xxf-performance` | XXFPerformance |
| `xxf-tracker` | XXFTracker |
| `xxf-tracker-firebase` | XXFTrackerFirebase |
| `xxf-tracker-sentry` | XXFTrackerSentry |
| `xxf-tracker-bugsnag` | XXFTrackerBugsnag |
| `xxf-event-reporter` | XXFEventReporter |
| `xxf-event-reporter-firebase` | XXFEventReporterFirebase |

### 工程化

| 技能 | 对应模块 |
|:------|:------|
| `xxf-swift-format` | XXFSwiftFormat |
| `xxf-coding-style` | 编码规范（项目约束） |
| `xxf-coding-arch` | 架构约束（项目约束） |
| `xxf-architecture-review` | 架构评审（跨模块） |
| `xxf-test-strategy` | 测试策略（跨模块） |
| `xxf-risk-gate` | 风险门禁（跨模块） |
| `xxf-release-management` | 发布管理（跨模块） |
| `xxf-adr-rfc` | ADR/RFC 决策（跨模块） |
| `xxf-incident-response` | 事故响应与复盘（跨模块） |
| `xxf-observability` | 可观测性规范（跨模块） |
| `xxf-security-privacy` | 安全与隐私基线（跨模块） |
| `xxf-api-contract` | 接口契约治理（跨模块） |
| `xxf-migration-playbook` | 迁移作战手册（跨模块） |
| `xxf-project-planning` | 技术项目规划（跨模块） |
| `xxf-ci-quality-gates` | CI 质量门禁（跨模块） |

---

## 二、安装

根据你用的 Agent 选一个小节。**推荐走 2.1 / 2.2 的一键脚本**——它做的是 git clone + 软链，升级只需重跑脚本（不是每次都拷贝一遍）。

**脚本行为概览：**

| Agent | 策略 | 升级方式 |
|:------|:------|:------|
| Claude Code | git clone 到 `~/.cache/xxf-ios-skills`，软链到 `.claude/skills/` | 重跑脚本 或 `git -C <cache> pull` |
| Codex CLI | git clone 到缓存，在项目 `AGENTS.md` 注入受控引用块 | 重跑脚本 |
| Cursor | git clone + 拷贝 `.mdc` 到 `.cursor/rules/`（Cursor 对软链不稳定） | 重跑脚本 |

### 2.1 Claude Code（推荐：一键脚本 + 自动升级）

一条命令完成安装，升级也只是再跑一遍：

```bash
# 全局安装（对所有项目可用）
bash <(curl -fsSL https://raw.githubusercontent.com/NBXXF/xxf_ios/main/skills/install.sh) claude user

# 或只在当前项目安装
bash <(curl -fsSL https://raw.githubusercontent.com/NBXXF/xxf_ios/main/skills/install.sh) claude project
```

脚本做的事（透明、可审）：
1. `git clone` 到 `~/.cache/xxf-ios-skills`（或 `git pull` 更新）
2. 把每个 `xxf-*` 目录 **软链接** 到 `~/.claude/skills/`（或项目 `.claude/skills/`）
3. 升级时重跑脚本即可——**软链自动跟随**，不用再拷贝。

重启 Claude Code 会话后生效。

**手动版（不想跑脚本）：**

```bash
git clone https://github.com/NBXXF/xxf_ios.git ~/.cache/xxf-ios-skills
mkdir -p ~/.claude/skills
for d in ~/.cache/xxf-ios-skills/skills/xxf-*/; do
    ln -sfn "$d" ~/.claude/skills/$(basename "$d")
done
# 升级：cd ~/.cache/xxf-ios-skills && git pull
```

**按需安装：** 65 个 skill 全装会占用路由预算；只需要部分时，把脚本 `for` 循环改成固定几个，或手动 `ln -sfn` 想要的 skill 即可。

### 2.2 Codex CLI（OpenAI）

Codex CLI 没有 "skill" 的概念，它通过项目根目录的 `AGENTS.md` 接收指令。安装脚本会在你的 `AGENTS.md` 里注入一段受控块，引导 Codex 在遇到 XXF 相关提问时读取对应 `SKILL.md`：

```bash
cd /path/to/your/ios-project
bash <(curl -fsSL https://raw.githubusercontent.com/NBXXF/xxf_ios/main/skills/install.sh) codex project
```

注入的内容被 `<!-- BEGIN: xxf-ios-skills ... -->` / `<!-- END ... -->` 标记包裹，**再次运行脚本只刷新该块，不动你其它内容**。

效果：Codex 看到用户问"怎么用 XXFHttp"时，会自己去读 `~/.cache/xxf-ios-skills/skills/xxf-http/SKILL.md`。

**手动版：** 把 `SKILL.md` 内容直接粘到 `AGENTS.md` 也行，但不方便后续升级；推荐用脚本。

### 2.3 Cursor

Cursor 用 `.cursor/rules/*.mdc`（与 Anthropic Skills frontmatter 部分兼容，仅识别 `description`）：

```bash
cd /path/to/your/ios-project
bash <(curl -fsSL https://raw.githubusercontent.com/NBXXF/xxf_ios/main/skills/install.sh) cursor project
```

> Cursor 对软链支持不稳定，本模式用**拷贝**不是软链；升级需要重跑脚本。

### 2.4 CodeBuddy（用 `skills` CLI）

```bash
npm install -g skills
npx skills add https://github.com/NBXXF/xxf_ios.git --agent codebuddy -y

# 按需
npx skills add https://github.com/NBXXF/xxf_ios.git --skill xxf-http --skill xxf-router --agent codebuddy -y
```

### 2.5 Git Submodule（团队锁版本）

业务仓库把本仓作为 submodule，再用项目级软链接：

```bash
git submodule add https://github.com/NBXXF/xxf_ios.git third_party/xxf_ios
mkdir -p .claude/skills
for d in third_party/xxf_ios/skills/xxf-*/; do
    ln -sfn "../../$d" .claude/skills/$(basename "$d")
done

# 锁版本
cd third_party/xxf_ios && git checkout v0.2.0
```

好处：整个团队锁同一版本；`git submodule update --remote` 升级。

### 2.6 自建 Agent / Anthropic API 直调

Skill 就是 markdown + YAML frontmatter。按需求选：
- 全注入：把相关 `SKILL.md` 正文拼进 system prompt
- 路由模式：先把所有 `description` 喂给模型做选择，再加载具体 skill

---

## 三、版本 & 升级

- 遵循 [SemVer](https://semver.org)。release 打 tag `vX.Y.Z`。
- 破坏性改动前会在 [CHANGELOG.md](CHANGELOG.md) 列出迁移步骤。
- 业务方建议**锁版本**：`git checkout vX.Y.Z` 或 CLI 支持的 `@vX.Y.Z` 语法。

---

## 四、设计原则

1. **渐进披露**：`SKILL.md` ≈ 100 行，重度内容放 `references/*.md` 按需加载。
2. **Skill 不复述源码**：API 以 `Sources/XXFxxx/` 为准，避免文档腐烂。
3. **触发词显式化**：`description` 写"当用户…时使用"句式。
4. **最小工具权限**：`allowed-tools` 白名单。
5. **人机分离**：`README.md` 给人，`SKILL.md` 给 AI。
6. **无中心路由**：每个 skill 的 `description` 是自己的路由器，不依赖根索引。

---

## 五、贡献 & 验证

```bash
# 本地跑 lint（零依赖，只需 Python 3）
python3 scripts/validate-skills.py
```

校验项：
- frontmatter 必须含 `name` + `description`
- `name` 必须与目录名一致
- 文档中所有相对链接必须存在

PR 时 GitHub Actions 会自动跑上述校验。

---

## 六、与 Swift Package 主工程的关系

- `skills/` 不在 SPM 扫描范围，不影响 `swift build` / `swift test`。
- `scripts/` 和 `.github/` 同理。
- `Sources/` 和 `Tests/` 是主工程唯一交付物。
