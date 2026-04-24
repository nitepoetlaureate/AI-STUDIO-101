# Mycelium Note-Writing Discipline

Mycelium is the project's persistent knowledge layer — structured notes attached
to git objects (files, directories, commits) via `refs/notes/mycelium`. Agents
read it on arrival and write to it after meaningful work.

The full protocol and command reference is at `./mycelium/SKILL.md`.

## Mandatory Arrival Protocol

At the start of any session working on a specific file or system:

```bash
./mycelium/mycelium.sh find constraint     # project-wide constraints — READ FIRST
./mycelium/mycelium.sh find warning        # known fragile things — READ FIRST
./mycelium/scripts/context-workflow.sh <file>   # file + parent dirs + commit context
```

If `context-workflow.sh` is unavailable, do this manually:

```bash
./mycelium/mycelium.sh read <file>         # note on this exact file version
./mycelium/mycelium.sh read HEAD           # note on current commit
```

## Immediate persistence (Cursor + agents)

**Do not defer Mycelium writes to “end of session”** when the agent has already applied substantive edits in this turn.

1. **Same turn as the change:** after meaningful `Write` / `Edit` / shell-driven edits, run **in the same assistant response** (before ending the turn):
   - `./mycelium/mycelium.sh note HEAD -k context -m "…"`
   - `./mycelium/mycelium.sh note <changed-path> -k summary -m "…"` (per file that needs cross-session context)
2. **Push notes to GitHub immediately (optional, recommended when notes must survive on other machines):**
   ```bash
   git config mycelium.autoPushNotes true
   git config mycelium.remote origin   # optional
   ```
   Then either:
   - use **`./mycelium/scripts/note-and-push.sh …`** instead of `mycelium.sh note …` for those commands, **or**
   - rely on **Cursor `afterShellExecution`** (see `.cursor/hooks.json`): after a successful shell command that invokes `mycelium.sh note`, the hook appends to `production/session-state/.mycelium-hook-log` and **auto-pushes** `refs/notes/mycelium` when `mycelium.autoPushNotes` is true.

3. **Code commits** (`git commit` of the branch) remain separate from **git notes** (`refs/notes/mycelium`). Notes can be pushed without a new code commit.

## Mandatory Departure Protocol

After any meaningful work (design decision, code change, architectural discovery), if you have **not** already written the notes in the same turn as above, run:

```bash
# Note on the commit (context — why this change exists)
./mycelium/mycelium.sh note HEAD -k context -m "What you did and why."

# Note on changed files (summary — what future agents should know)
./mycelium/mycelium.sh note <changed-file> -k summary -m "What this file does now."

# If you found something fragile or dangerous
./mycelium/mycelium.sh note <file> -k warning -m "What to watch out for."

# If you made an architectural decision
./mycelium/mycelium.sh note <file> -k decision -t "Short label" -m "Decision and rationale."
```

## When to Write Which Kind

| Kind | When to use |
|------|-------------|
| `constraint` | A rule that must not be broken (e.g., "pixel art must render nearest-neighbor") |
| `warning` | Something fragile or dangerous that future agents must know |
| `decision` | An architectural or design choice with rationale |
| `summary` | What a file or directory does — current state |
| `context` | Why a change was made — commit-level reasoning |
| `observation` | Neutral finding — not a decision, not a warning, but worth recording |
| `todo` | Explicit deferred work |
| `value` | Project-level principle (attach to `.`) |

## Target Selection

| Target | Use when |
|--------|----------|
| `path/to/file` | Note is about this file (stable, findable even as file changes) |
| `HEAD` | Note is about this commit (why this change exists) |
| `.` | Note applies to the whole project |
| `src/dir/` | Note is about this subsystem |

Default: use paths. Use `HEAD` for commit context. Use `.` for project principles.

## Noise Discipline

**Do NOT write notes for:**
- Trivial edits (typos, formatting, renaming)
- Information self-evident from reading the code
- Information that will be stale within this session

**DO write notes for:**
- Non-obvious decisions (why X instead of Y)
- Constraints that cannot be derived from reading the code
- Warnings about known-fragile paths or API gotchas
- Cross-session context that saves the next agent 15+ minutes of archaeology

## Workflow Scripts

```bash
mycelium/scripts/context-workflow.sh <path>   # arrival workflow
mycelium/scripts/path-history.sh <path>       # historical notes via git
mycelium/scripts/note-history.sh <target>     # overwrite history for one note
```

## Full Reference

Read `./mycelium/SKILL.md` for the complete protocol, patterns, edge types,
slot usage, and jj colocated repo guidance.
