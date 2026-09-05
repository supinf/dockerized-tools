#!/bin/bash
set -euo pipefail

# OS detection for sed -i compatibility
if [ "$(uname)" == "Darwin" ]; then
  SED_INPLACE=(-i '')
else
  SED_INPLACE=(-i)
fi

# .claude/settings.local.json を事前に退避する（rm -rf .claude で消えるため）
SAVED_SETTINGS_LOCAL=""
if [ -f .claude/settings.local.json ]; then
  SAVED_SETTINGS_LOCAL=$(cat .claude/settings.local.json)
fi

rm -rf .cursor .claude .codex .agents .cursorignore .geminiignore .mcp.json AGENTS.md CLAUDE.md

rulesync generate

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

echo -e "\nAll post-generation steps completed successfully.\n"
