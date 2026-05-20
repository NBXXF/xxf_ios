#!/usr/bin/env bash
#
# XXF iOS Skills 安装 / 升级脚本
#
# 用法：
#   bash install.sh <agent> [scope]
#
# agent:
#   claude      — Claude Code（~/.claude/skills 或 .claude/skills）
#   codex       — Codex CLI（在 AGENTS.md 里注入引用段）
#   cursor      — Cursor（.cursor/rules/*.mdc）
#
# scope（claude / cursor 可选，默认 user）：
#   user        — 全局安装到 $HOME 对应目录
#   project     — 只安装到当前项目目录
#
# 示例：
#   bash install.sh claude user           # 全局装到 ~/.claude/skills
#   bash install.sh claude project        # 只装到 ./.claude/skills
#   bash install.sh codex project         # 在当前项目 AGENTS.md 注入
#   bash install.sh cursor project        # 装到 ./.cursor/rules
#
# 升级：重复执行本脚本即可，底层只做 git pull + symlink 刷新，不会覆盖用户修改。

set -euo pipefail

SKILLS_REPO="${XXF_SKILLS_REPO:-https://github.com/NBXXF/xxf_ios.git}"
CACHE_DIR="${XXF_SKILLS_CACHE:-$HOME/.cache/xxf-ios-skills}"
AGENT="${1:-}"
SCOPE="${2:-user}"

# 写入 AGENTS.md 的路径使用 $HOME 前缀,保证多机器间内容一致,避免每个开发者看到不同的 /Users/xxx/...
# 自定义 XXF_SKILLS_CACHE 的场景(不在 $HOME 下)则退回绝对路径
if [[ "$CACHE_DIR" == "$HOME"/* ]]; then
  CACHE_DIR_DISPLAY='$HOME'"${CACHE_DIR#$HOME}"
else
  CACHE_DIR_DISPLAY="$CACHE_DIR"
fi

err() { echo "error: $*" >&2; exit 1; }
info() { echo "→ $*"; }

[[ -n "$AGENT" ]] || err "missing agent. usage: $0 <claude|codex|cursor> [user|project]"

# ---------- sync cache ----------

if [[ -d "$CACHE_DIR/.git" ]]; then
  info "updating cache: $CACHE_DIR"
  git -C "$CACHE_DIR" pull --ff-only --quiet
else
  info "cloning to cache: $CACHE_DIR"
  mkdir -p "$(dirname "$CACHE_DIR")"
  git clone --depth 1 --quiet "$SKILLS_REPO" "$CACHE_DIR"
fi

SKILLS_SRC="$CACHE_DIR/skills"
[[ -d "$SKILLS_SRC" ]] || err "skills/ not found in cache"

# ---------- install by agent ----------

install_claude() {
  local target
  case "$SCOPE" in
    user)    target="$HOME/.claude/skills" ;;
    project) target="$PWD/.claude/skills" ;;
    *) err "scope must be 'user' or 'project'" ;;
  esac

  mkdir -p "$target"
  local count=0
  for skill_dir in "$SKILLS_SRC"/xxf-*/; do
    [[ -d "$skill_dir" ]] || continue
    local name
    name=$(basename "$skill_dir")
    ln -sfn "$skill_dir" "$target/$name"
    count=$((count + 1))
  done
  info "installed $count skills to $target (symlinks to cache)"
  info "to update later: re-run this script OR 'git -C $CACHE_DIR pull'"
}

install_codex() {
  [[ "$SCOPE" == "project" ]] || err "codex scope must be 'project' (AGENTS.md is per-project)"

  local agents_md="$PWD/AGENTS.md"
  local marker_begin="<!-- BEGIN: xxf-ios-skills (managed by install.sh) -->"
  local marker_end="<!-- END: xxf-ios-skills -->"

  # remove previous managed block if present
  # `\n*` 放在 begin 前，吃掉 block 之前紧邻的空行，避免每次重跑都累积一个空行
  if [[ -f "$agents_md" ]] && grep -qF "$marker_begin" "$agents_md"; then
    info "refreshing existing xxf-ios-skills block in AGENTS.md"
    python3 - "$agents_md" "$marker_begin" "$marker_end" <<'PY'
import sys, pathlib, re
path, begin, end = sys.argv[1:]
text = pathlib.Path(path).read_text()
pattern = re.compile(r'\n*' + re.escape(begin) + r'.*?' + re.escape(end) + r'\n?', re.DOTALL)
pathlib.Path(path).write_text(pattern.sub('', text))
PY
  fi

  local skills_list=""
  for skill_dir in "$SKILLS_SRC"/xxf-*/; do
    [[ -d "$skill_dir" ]] || continue
    skills_list+="- $(basename "$skill_dir")"$'\n'
  done

  # 追加新块：先用 `$(cat)` 天然剥掉文件尾部所有空白行（bash 命令替换会吃掉尾部换行），
  # 再固定 \n\n 作为和新块的分隔，保证每次重跑 block 前恰好只有一个空行
  {
    if [[ -f "$agents_md" ]]; then
      local existing
      existing=$(cat "$agents_md")
      if [[ -n "$existing" ]]; then
        printf '%s\n\n' "$existing"
      fi
    fi
    echo "$marker_begin"
    echo "## XXF iOS Skills"
    echo ""
    echo "For normal coding tasks in an XXF iOS project, do not wait for the user to explicitly ask for tests, review, or release-risk assessment."
    echo ""
    echo "Before implementing a generic bugfix, feature change, refactor, or regression fix, first read:"
    echo ""
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-delivery-loop/SKILL.md"
    echo ""
    echo "Then load any additional relevant skills:"
    echo ""
    echo "- Matching XXF module skills under:"
    echo "    $CACHE_DIR_DISPLAY/skills/<skill-name>/SKILL.md"
    echo "- Engineering constraints when relevant:"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-coding-style/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-coding-arch/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-class-declaration-guidelines/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-test-strategy/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-unit-test-writer/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-auto-test-orchestrator/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-code-reviewer/SKILL.md"
    echo "    $CACHE_DIR_DISPLAY/skills/xxf-aaa-risk-gate/SKILL.md"
    echo ""
    echo "Default expectation for ordinary coding work in this repo:"
    echo ""
    echo "1. Make the smallest correct change."
    echo "2. Add or repair the minimum effective tests when the change needs regression protection."
    echo "3. Run the narrowest relevant verification."
    echo "4. Review the change when risk is non-trivial."
    echo "5. Surface a merge/release risk conclusion when residual risk remains."
    echo ""
    echo "Only skip one of these steps when it is clearly not applicable, or when blocked by sensitive credentials, signing, environment ambiguity, or explicit user direction."
    echo ""
    echo "Available skills:"
    echo ""
    echo "$skills_list"
    echo "Update cache: \`git -C $CACHE_DIR_DISPLAY pull\` (or re-run install.sh)."
    echo "$marker_end"
  } > "$agents_md.new"
  mv "$agents_md.new" "$agents_md"

  info "injected managed block into $agents_md"
  info "upgrade: re-run install.sh to refresh skill list and pull cache"
}

install_cursor() {
  local target
  case "$SCOPE" in
    user)    err "Cursor rules are project-scoped; use 'project'" ;;
    project) target="$PWD/.cursor/rules" ;;
    *) err "scope must be 'project' for Cursor" ;;
  esac

  mkdir -p "$target"
  local count=0
  for skill_dir in "$SKILLS_SRC"/xxf-*/; do
    [[ -d "$skill_dir" ]] || continue
    local name
    name=$(basename "$skill_dir")
    # Cursor uses .mdc files; copy SKILL.md as <name>.mdc.
    # Symlink would also work but some Cursor versions don't follow them.
    cp "$skill_dir/SKILL.md" "$target/$name.mdc"
    count=$((count + 1))
  done
  info "installed $count rules to $target"
  info "note: Cursor .mdc only uses 'description' from frontmatter; allowed-tools is ignored"
}

case "$AGENT" in
  claude) install_claude ;;
  codex)  install_codex ;;
  cursor) install_cursor ;;
  *) err "unknown agent '$AGENT'. use: claude | codex | cursor" ;;
esac

info "done."
