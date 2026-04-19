#!/usr/bin/env bash
# Cursor afterFileEdit → Claude-style PostToolUse for mycelium + asset validation.
# stdin: { "file_path": "<absolute>", "edits": [...] }
set -euo pipefail
INPUT=$(cat)
REPO=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
[ -z "$REPO" ] && exit 0
cd "$REPO" || exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

FP=$(echo "$INPUT" | jq -r '.file_path // empty')
[ -z "$FP" ] && exit 0

SYNTH=$(jq -n --arg fp "$FP" '{tool_name:"Write", tool_input:{file_path:$fp}}')
printf '%s\n' "$SYNTH" | bash .claude/hooks/validate-assets.sh >/dev/null 2>&1 || true
printf '%s\n' "$SYNTH" | bash .claude/hooks/post-tool-use-mycelium.sh >/dev/null 2>&1 || true
exit 0
