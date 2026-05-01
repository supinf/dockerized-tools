#!/bin/bash
set -euo pipefail

# .claude/settings.local.json を事前に退避する（rm -rf .claude で消えるため）
SAVED_SETTINGS_LOCAL=""
if [ -f .claude/settings.local.json ]; then
  SAVED_SETTINGS_LOCAL=$(cat .claude/settings.local.json)
fi

rm -rf .claude .codex .cursor .gemini .roo .cursorignore .geminiignore .rooignore .mcp.json AGENTS.md CLAUDE.md GEMINI.md

rulesync generate --targets cursor,claudecode,codexcli,geminicli --features commands,subagents,skills,hooks
rulesync generate --targets roo --features commands,subagents,skills --simulate-subagents
rulesync generate --targets cursor,roo,claudecode,geminicli,codexcli --features mcp,rules,ignore,permissions

TMP=$(mktemp)
trap 'rm -f "$TMP"' EXIT

# .claude/settings.json に追加設定をマージ
# テンプレート (.[0]) をベースに rulesync 生成結果 (.[1]) を優先マージすることで
# $schema や env など rulesync が生成しない設定を保持する。
echo -e "\nMerging extra settings into .claude/settings.json..."
if [ -f .rulesync/configs/.claude-settings.json ] && [ -f .claude/settings.json ]; then
  # $t * $g: rulesync output ($g) wins for scalar conflicts.
  # Permission arrays are explicitly concatenated and deduplicated so both sources contribute.
  jq -s '
    .[0] as $t | .[1] as $g |
    ($t * $g)
    | .permissions.allow = ((($t.permissions.allow // []) + ($g.permissions.allow // [])) | unique)
    | .permissions.deny  = ((($t.permissions.deny  // []) + ($g.permissions.deny  // [])) | unique)
  ' .rulesync/configs/.claude-settings.json .claude/settings.json > "$TMP"
  mv "$TMP" .claude/settings.json
fi

# .claude/settings.local.json を復元・マージ
# 優先順位: 退避済み個人設定 (.[1]) > プロジェクトテンプレート (.[0])
echo -e "\nMerging .claude/settings.local.json..."
if [ -n "$SAVED_SETTINGS_LOCAL" ]; then
  echo "$SAVED_SETTINGS_LOCAL" | jq -s '.[0] * .[1]' .rulesync/configs/.claude-settings.local.json - > "$TMP"
  mv "$TMP" .claude/settings.local.json
else
  cp .rulesync/configs/.claude-settings.local.json .claude/settings.local.json
fi

# .gemini/commands/*.toml ファイル内のプロンプト形式を修正
echo -e "\nFixing prompt format in .gemini/commands/*.toml files...\n"
for f in .gemini/commands/*.toml; do
  [ -f "$f" ] || continue
  sed -i "s/prompt = \"\"\"/prompt = '''/g" "$f"
  sed -i "s/^\"\"\"$/'''/g" "$f"
done

echo -e "\nAll post-generation steps completed successfully.\n"
