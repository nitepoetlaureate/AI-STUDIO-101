#!/bin/bash
# Claude Code PostToolUse hook: Track files edited this session for mycelium departure.
# Fires on Write and Edit tool calls.
# Appends edited file paths to a session tracking file (gitignored).
# The session-stop hook uses this list to remind the agent which files to annotate.
#
# Input schema (PostToolUse for Write/Edit):
# { "tool_name": "Write|Edit", "tool_input": { "file_path": "...", ... } }

INPUT=$(cat)

# Extract file_path
if command -v jq >/dev/null 2>&1; then
    FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
    FILE_PATH=$(echo "$INPUT" | grep -oE '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 \
        | sed 's/"file_path"[[:space:]]*:[[:space:]]*"//;s/"$//')
fi

[ -z "$FILE_PATH" ] && exit 0

# Strip to repo-relative path
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
REL_PATH="${FILE_PATH#$REPO_ROOT/}"

# Append to session tracking file (gitignored alongside active.md)
TRACKING_FILE="production/session-state/.mycelium-touched"
mkdir -p "production/session-state" 2>/dev/null
echo "$REL_PATH" >> "$TRACKING_FILE" 2>/dev/null

exit 0
