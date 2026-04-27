# XXF iOS Skills

为使用 [XXF iOS](../README.md) 框架的业务方提供的 AI Skill 集合。遵循 [Anthropic Agent Skills 规范](https://docs.anthropic.com) —— 每个子目录一个 `SKILL.md`，YAML frontmatter + markdown，无专有格式。

---

## 一、Skill 清单

共 **49 个** skill，按类别分组。每个 skill 目录下有 `SKILL.md`（AI 读）和 `triggers.md`（回归用例）。

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

---

## 二、安装

Skill 的安装**没有跨 Agent 的统一标准**。下面按你在用的 Agent 选一种：

### 2.1 Claude Code（官方推荐姿势，零依赖）

**用户级（全局可用）**

```bash
git clone https://github.com/NBXXF/xxf_ios.git /tmp/xxf_ios
mkdir -p ~/.claude/skills
cp -r /tmp/xxf_ios/skills/xxf-* ~/.claude/skills/
```

**项目级（只在当前仓库可用）**

```bash
mkdir -p .claude/skills
cp -r /tmp/xxf_ios/skills/xxf-* .claude/skills/
```

> 💡 49 个 skill 全量安装会占用一定的路由预算；如果你的项目只用部分模块，建议按需拷贝：
> ```bash
> cp -r /tmp/xxf_ios/skills/{xxf-http,xxf-router,xxf-flow,xxf-cache} ~/.claude/skills/
> ```

重启 Claude Code 会话即生效。

### 2.2 Cursor

Cursor 使用 `.cursor/rules/*.mdc` 格式，**与 Anthropic Skills 不兼容**，需要转换。推荐方案：

```bash
mkdir -p .cursor/rules
for skill in /tmp/xxf_ios/skills/xxf-*/SKILL.md; do
    name=$(basename "$(dirname "$skill")")
    cp "$skill" ".cursor/rules/${name}.mdc"
done
```

（Cursor `.mdc` 与 Anthropic SKILL.md 的 frontmatter 字段有差异，`description` 能识别，`allowed-tools` 不识别；足够日常使用。）

### 2.3 CodeBuddy（用 `skills` CLI）

```bash
# 前置
npm install -g skills

# 全装
npx skills add https://github.com/NBXXF/xxf_ios.git --agent codebuddy -y

# 按需
npx skills add https://github.com/NBXXF/xxf_ios.git --skill xxf-http --skill xxf-router --agent codebuddy -y
```

### 2.4 自建 Agent / Anthropic API 直调

Skill 就是 markdown。直接把需要的 `SKILL.md` 正文拼进你的 system prompt 即可，或做一个 router 按 `description` 选 skill 后再注入。

### 2.5 Git Submodule（推荐给团队使用）

适合团队锁版本、全员共享、不想每次都 curl：

```bash
git submodule add https://github.com/NBXXF/xxf_ios.git third_party/xxf_ios
ln -s ../../third_party/xxf_ios/skills/xxf-http .claude/skills/xxf-http
# 或用脚本循环链接所有 xxf-*
```

`git submodule update --remote` 升级到最新，或 `cd third_party/xxf_ios && git checkout v0.1.0` 锁版本。

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
