#!/usr/bin/env bash
# Reminder before gdcli shell: read Mycelium context for any .tscn paths in the command.
# stdin: { "command": "...", "cwd": "...", ... }
# stdout: { "permission": "allow", "agent_message": "..." }
set -euo pipefail
INPUT=$(cat)
REPO=$(git rev-parse --show-toplevel 2>/dev/null || echo "")
[ -z "$REPO" ] && echo '{"permission":"allow"}' && exit 0
cd "$REPO" || {
  echo '{"permission":"allow"}'
  exit 0
}

if ! command -v jq >/dev/null 2>&1; then
  echo '{"permission":"allow"}'
  exit 0
fi

CMD=$(echo "$INPUT" | jq -r '.command // empty')
MSG=""
while IFS= read -r tscn; do
  [ -z "$tscn" ] && continue
  REL="${tscn#"$REPO"/}"
  if git rev-parse --verify "HEAD:${REL}" >/dev/null 2>&1; then
    CTX=$(mycelium/scripts/context-workflow.sh "$REL" 2>&1 || true)
    if [ -n "$CTX" ]; then
      MSG="${MSG}

=== Mycelium context: ${REL} ===
${CTX}"
    fi
  fi
done < <(echo "$CMD" | grep -oE '[^[:space:]]+\.tscn' || true)

# Trim huge injections
MAX=12000
if [ "${#MSG}" -gt "$MAX" ]; then
  MSG="${MSG:0:$MAX}…(truncated)"
fi

if [ -n "$MSG" ]; then
  jq -n --arg msg "Before gdcli: read Mycelium notes for scenes you touch. Commit + mycelium.sh note HEAD after edits.${MSG}" '{permission:"allow", agent_message:$msg}'
else
  jq -n --arg msg 'gdcli: before scene_edit, run `mycelium/scripts/context-workflow.sh <path>` on each .tscn you change; after commit, `mycelium.sh note HEAD -k context -m "…"`. Shell gdcli: `/usr/local/bin/npx -y gdcli-godot …`.' '{permission:"allow", agent_message:$msg}'
fi
exit 0
