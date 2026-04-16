#!/bin/bash
# Claude Code PreToolUse hook: Run mycelium context workflow before editing files.
# Fires on Write and Edit tool calls.
# Provides file-specific notes, constraints, and warnings to the agent before it touches the file.
#
# IMPORTANT: Mycelium annotates git blob OIDs. New files that haven't been committed
# yet have no blob — attempting mycelium on them exits 128. This hook guards for that.
#
# Input schema (PreToolUse for Write/Edit):
# { "tool_name": "Write|Edit", "tool_input": { "file_path": "...", ... } }

INPUT=$(cat)

# Extract file_path from tool input JSON
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
        | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0

# Strip leading slash if absolute path — mycelium uses repo-relative paths
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
REL_PATH="${FILE_PATH#$REPO_ROOT/}"

# Verify the file is committed to git (has a blob OID in HEAD).
# New/untracked files have no git object — mycelium will fail with exit 128.
git rev-parse --verify "HEAD:${REL_PATH}" >/dev/null 2>&1 || exit 0

# Run context workflow — fail-open: never block agent on mycelium errors.
# Outputs notes, constraints, and warnings for this file to stderr (visible to agent).
mycelium/scripts/context-workflow.sh "$REL_PATH" 2>/dev/null || true

exit 0
