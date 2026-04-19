#!/usr/bin/env bash
# Cursor subagentStart → audit log (Claude log-agent expects agent_name; we map subagent_type).
set -euo pipefail
INPUT=$(cat)
REPO=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
[ -z "$REPO" ] && exit 0
cd "$REPO" || exit 0

if command -v jq >/dev/null 2>&1; then
  TYPE=$(echo "$INPUT" | jq -r '.subagent_type // "unknown"')
  TASK=$(echo "$INPUT" | jq -r '.task // ""' | head -c 200)
else
  TYPE="unknown"
  TASK=""
fi

TS=$(date +%Y%m%d_%H%M%S)
LOG_DIR="production/session-logs"
mkdir -p "$LOG_DIR" 2>/dev/null || true
echo "$TS | Cursor subagent | type=$TYPE | task=$TASK" >>"$LOG_DIR/agent-audit.log" 2>/dev/null || true
exit 0
