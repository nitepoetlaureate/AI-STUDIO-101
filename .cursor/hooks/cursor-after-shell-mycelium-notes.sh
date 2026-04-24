#!/usr/bin/env bash
# Cursor afterShellExecution: persist mycelium git notes to the remote immediately
# after the agent successfully runs `mycelium.sh note ...`.
#
# Opt-in push (recommended for solo / trusted remotes):
#   git config mycelium.autoPushNotes true
#   git config mycelium.remote origin   # optional; default origin
#
# stdin: JSON (fields vary by Cursor version — we accept several shapes)
set -euo pipefail
INPUT=$(cat)
REPO=$(git rev-parse --show-toplevel 2>/dev/null || true)
[ -z "$REPO" ] && exit 0
cd "$REPO" || exit 0

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

# Exit code: only act on success
EC=$(echo "$INPUT" | jq -r '.exit_code // .exitCode // .status // empty')
if [ -n "$EC" ] && [ "$EC" != "0" ] && [ "$EC" != "null" ]; then
  exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.command // .shell_command // .tool_input.command // empty')
[ -z "$CMD" ] && exit 0

# Only react to explicit mycelium note invocations (avoid noise on `mycelium.sh read`, etc.)
if ! printf '%s' "$CMD" | grep -qE '(\./)?mycelium/mycelium\.sh\s+.*\bnote\b|(^|[;&|(]|\s)mycelium\.sh\s+.*\bnote\b'; then
  exit 0
fi

REF_NAME=$(git config mycelium.ref 2>/dev/null || echo "mycelium")
NOTES_REF="refs/notes/${REF_NAME}"
REMOTE=$(git config mycelium.remote 2>/dev/null || echo "origin")
mkdir -p production/session-state 2>/dev/null || true
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
printf '%s mycelium note shell ok; ref=%s\n' "$TS" "$NOTES_REF" >>production/session-state/.mycelium-hook-log 2>/dev/null || true

if git config --bool mycelium.autoPushNotes 2>/dev/null | grep -qiE '^(true|1|yes)$'; then
  if git remote get-url "$REMOTE" >/dev/null 2>&1; then
    git push "$REMOTE" "$NOTES_REF" 2>>production/session-state/.mycelium-hook-log || true
  fi
fi

exit 0
