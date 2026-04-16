# SESSION 007 OPENING DIRECTIVE

You are beginning a new working session on the BONNIE! game project. Before you do ANYTHING else, read this entire directive top to bottom. Do not skim. Do not skip sections. Do not begin executing until you have internalized every constraint below.

## CONTEXT

A comprehensive audit of this project was completed on 2026-04-15 and saved to `./URGENTPLAN.md`. That document contains a full critical review of every file in this repository, identifies every failure, shortcoming, stub, placeholder, and dead reference, and provides a phased remediation plan with 40 atomic tasks organized into 5 phases.

**Read `./URGENTPLAN.md` in full before proceeding.** It is your primary reference for this session.

You are Session 007. Session 006 ended with GATE 1 at CONDITIONALLY NEAR-PASS. The handoff is in `./NEXT.md`. The audit in `URGENTPLAN.md` supersedes NEXT.md's priority list — the audit found urgent issues that NEXT.md does not cover.

## YOUR IDENTITY AND OBLIGATIONS

You are a senior collaborator on this project. You have been trusted with direct access to the codebase. That trust is contingent on the following non-negotiable behaviors:

1. **ULTRATHINK before every action.** Use your extended thinking to reason through consequences before writing or editing any file. If you are uncertain about an action's impact, STOP and explain your uncertainty before proceeding.

2. **Use your tools.** You have access to Read, Write, Edit, Bash, Glob, Grep, and any MCP servers configured for this project. Use them. Do not guess at file contents — read them. Do not assume a command works — run it and check the output. Do not assume a path exists — verify it.

3. **Follow the hooks.** This project has PreToolUse and PostToolUse hooks that fire on Write and Edit operations. These hooks exist for a reason. After you complete work on any file, verify that the hooks fired correctly by checking for any hook output or errors. If hooks are not firing, that is itself a bug that must be diagnosed and fixed.

4. **Mycelium protocol.** This project uses Mycelium (git-notes-based knowledge persistence) for inter-session context. Your arrival protocol is:
   ```
   mycelium.sh find constraint
   mycelium.sh find warning
   ```
   Your departure protocol (before session ends) is:
   ```
   mycelium.sh note HEAD -k context -m "What you did and why."
   mycelium.sh note <changed-file> -k summary -m "What this file does now."
   ```
   **CRITICAL**: The audit found that Mycelium may not be functioning correctly. Diagnosing and fixing this is your FIRST priority (see below).

5. **Never deliver incomplete work.** No stubs. No placeholders. No `# TODO: implement this later`. Every file you touch must be production-ready when you save it.

6. **Never make large changes without explaining why.** If you need to delete a function, restructure a system, or modify behavior, explain the rationale FIRST and get approval before executing.

7. **Commit identity**: `Co-Authored-By: Hawaii Zeke <(302) 319-3895>`

---

## SESSION 007 PRIORITY SEQUENCE

Execute these in order. Do not skip ahead. Each priority must be verified complete before moving to the next.

---

### PRIORITY 0: DIAGNOSE AND FIX MYCELIUM

**This is the single most important task of this session.** The audit found that the `mycelium/` directory (lowercase) appeared empty and `mycelium.sh` was not found on PATH. However, the project owner confirms that Mycelium was installed from a cloned repo at `./Mycelium/` (capital M) using `install.sh`, and believed it was functioning.

**Your task is to determine the ground truth and fix whatever is broken.**

#### Step 0A: Investigate the current state

Run ALL of the following and study the output carefully:

```bash
# 1. Check if Mycelium directory exists (case-sensitive check)
ls -la ./Mycelium/ 2>&1
ls -la ./mycelium/ 2>&1

# 2. Check if mycelium.sh is on PATH
which mycelium.sh 2>&1
type mycelium.sh 2>&1

# 3. Check if mycelium.sh exists anywhere in the project
find . -name "mycelium.sh" -not -path "./.git/*" 2>&1

# 4. Check if context-workflow.sh exists anywhere
find . -name "context-workflow.sh" -not -path "./.git/*" 2>&1

# 5. Check if install.sh exists and what it does
find . -name "install.sh" -path "*/[Mm]ycelium/*" -not -path "./.git/*" 2>&1

# 6. Check git notes refs — does mycelium have any notes stored?
git notes --ref=mycelium list 2>&1 | head -20

# 7. Check if there are any mycelium-related entries in git config
git config --get-regexp notes 2>&1

# 8. Check the hooks — are they actually being triggered?
cat .claude/hooks/pre-tool-use-mycelium.sh
cat .claude/hooks/post-tool-use-mycelium.sh

# 9. Check PATH and shell environment
echo "$PATH"

# 10. Check if there's a symlink or alias
ls -la $(which mycelium.sh 2>/dev/null) 2>&1

# 11. Check .gitignore for mycelium-related entries
grep -i mycelium .gitignore 2>&1

# 12. Check what the install.sh actually did (if you can find it)
# Read its contents to understand the expected installation state
```

#### Step 0B: Identify the failure mode

Based on the investigation above, determine which of these scenarios applies:

**Scenario A — Case sensitivity mismatch**: Mycelium installed at `./Mycelium/` but hooks reference `mycelium/` (lowercase). This works on macOS (case-insensitive HFS+/APFS default) but the hooks may still fail if `mycelium.sh` isn't on PATH.

**Scenario B — PATH not configured**: `install.sh` may have installed `mycelium.sh` as a script within the repo but not added it to PATH. The `command -v mycelium.sh` check in `session-start.sh` would fail, and direct path references would need to use the full path.

**Scenario C — Git notes ref not initialized**: The `git notes --ref=mycelium` namespace may not be set up, so even if the scripts exist, note operations fail silently.

**Scenario D — Hooks are firing but mycelium commands fail silently**: The hooks use `|| true` and `exit 0` on every mycelium call. If mycelium.sh exists but returns errors, those errors are swallowed. Check if mycelium.sh is executable (`chmod +x`), if it has the right shebang, and if its internal paths are correct.

**Scenario E — Something else entirely**: The investigation may reveal a different root cause. Document it precisely.

#### Step 0C: Fix the identified issue

Once you know the failure mode, fix it. The fix must satisfy ALL of these verification criteria:

```bash
# All of these must succeed after your fix:

# 1. mycelium.sh is callable
mycelium.sh --help  # or equivalent

# 2. Notes can be written
mycelium.sh note HEAD -k context -m "Session 007: Mycelium diagnostic and repair"

# 3. Notes can be read back
mycelium.sh read HEAD

# 4. Constraint search works
mycelium.sh find constraint

# 5. Warning search works  
mycelium.sh find warning

# 6. Context workflow script exists and runs
mycelium/scripts/context-workflow.sh project.godot

# 7. The session-start hook correctly surfaces mycelium info
bash .claude/hooks/session-start.sh

# 8. The pre-tool-use hook correctly loads file context
echo '{"tool_name":"Write","tool_input":{"file_path":"project.godot"}}' | bash .claude/hooks/pre-tool-use-mycelium.sh

# 9. The post-tool-use hook correctly tracks edited files
echo '{"tool_name":"Edit","tool_input":{"file_path":"project.godot"}}' | bash .claude/hooks/post-tool-use-mycelium.sh
cat production/session-state/.mycelium-touched
```

**If any of the above fail after your fix, the fix is not complete. Keep working until all 9 pass.**

#### Step 0D: Document what you found and fixed

After the fix is verified, do ALL of the following:

1. Write a mycelium note on HEAD explaining what was broken and how you fixed it:
   ```bash
   mycelium.sh note HEAD -k context -m "Session 007: [exact description of what was broken and the fix applied]"
   ```

2. If you changed any hook scripts or paths, annotate those files:
   ```bash
   mycelium.sh note <changed-file> -k summary -m "What changed and why"
   ```

3. Add a warning note if there's a recurring risk:
   ```bash
   mycelium.sh note <relevant-file> -k warning -m "Description of what could break again and how to prevent it"
   ```

---

### PRIORITY 1: EXECUTE PHASE 0 TRIAGE TASKS

After Mycelium is confirmed working, execute the Phase 0 tasks from `URGENTPLAN.md`. These are small, targeted fixes that eliminate false signals and dead code:

**P0-02**: Implement `soft_landing` group check in `_on_landed()` in `BonnieController.gd`. The `SoftLandingPad` node in `TestLevel.tscn` Zone 4 is in group `"soft_landing"` but the code never checks for it. Add the check so Zone 4 behaves as documented (fall distance resets on soft landing surfaces → LANDING not ROUGH_LANDING). This is approximately 5 lines of code in the `_on_landed()` function.

**P0-03**: Create a placeholder `icon.svg` in the project root. Can be a simple cat silhouette or the Godot default icon. Eliminates the editor warning from `project.godot` line 16.

**P0-04**: Remove the dead variables `skid_timer` (line 144) and `jump_hold_timer` (line 147) from `BonnieController.gd`. Verify with grep that nothing external references them. These are legacy publics that shadow the actual working private variables.

**P0-05**: Extract the duplicated mid-air climb logic from `_handle_jumping()` (lines 552-562) and `_handle_falling()` (lines 603-613) into a new helper function `_try_airborne_climb() -> bool`. Place it under the PHYSICS HELPERS section.

**P0-06**: Add `.gdignore` files (empty files named `.gdignore`) in: `mycelium/` (or `Mycelium/`), `production/`, `docs/`, `.claude/`, `.github/`. This prevents Godot from scanning non-engine directories.

**P0-07**: Fix the stale progress tracker in `design/gdd/systems-index.md`. Update "Design docs started: 0" and "Design docs reviewed: 0" to reflect the actual counts (8 started, 8 reviewed, 8 approved).

**For each task**:
1. Read the relevant file(s) FIRST
2. Explain what you're about to change and why
3. Make the change
4. Verify the change is correct (re-read the file, run any applicable checks)
5. Write a mycelium note on each changed file

---

### PRIORITY 2: VERIFY HOOKS END-TO-END

After Priorities 0 and 1 are complete, do a full verification pass on the hook system:

1. Trigger a Write operation and confirm PreToolUse and PostToolUse hooks fire
2. Check that `production/session-state/.mycelium-touched` is being populated
3. Run `bash .claude/hooks/detect-gaps.sh --force` and review output
4. Confirm the session-start hook produces correct, complete output

Document any issues found. Fix them if possible; flag them for the next session if not.

---

### PRIORITY 3: GATE 1 DISPOSITION (If Time Permits)

If Priorities 0-2 are complete and there is time remaining:

1. Review the GATE 1 status in `PLAYTEST-002.md`
2. The audit recommends deferring AC-T08 (camera) and stealth radius to GATE 2 — these are not traversal-feel questions, they're polish/NPC-dependent questions
3. If the project owner agrees with these deferrals, the only remaining GATE 1 item is the slide rhythm re-test (P1-01 from URGENTPLAN.md)
4. Do NOT make the GATE 1 call yourself — present the disposition to the project owner for their decision

---

## LOCKED CONSTRAINTS — DO NOT VIOLATE

These are non-negotiable decisions from prior sessions. Do not re-litigate them.

1. **BONNIE never dies.** Non-negotiable.
2. **No auto-grab on ledges.** Pure parry only. Non-negotiable.
3. **DI-001 — Directional Pop**: LOCKED. Do not change LEDGE_PULLUP behavior.
4. **DI-003 — E Claw Brake**: LOCKED. Do not change SLIDING brake behavior.
5. **Zone 8 SQUEEZING implementation**: LOCKED. SqueezeShape position=(0,14) MUST NOT change.
6. **GL Compatibility renderer**: `gl_compatibility` only. Do not switch renderers.
7. **Prototype is throwaway**: `BonnieController.gd` is not production code. Do not over-engineer fixes in the prototype — make them correct and minimal.
8. **720x540 viewport, nearest-neighbor filtering, 60fps target**: LOCKED.
9. **F5 does not launch on macOS**: Use Play button or Cmd+B.

---

## SESSION DEPARTURE CHECKLIST

Before ending this session, you MUST:

1. Write mycelium notes on HEAD summarizing everything done this session
2. Write mycelium notes on every file you changed
3. Update `NEXT.md` with Session 007 results and Session 008 handoff
4. Update `DEVLOG.md` with session summary
5. Update `CHANGELOG.md` with concrete changes
6. Verify all hooks are functioning
7. Stage and commit all changes with descriptive commit message
8. Confirm the `.mycelium-touched` tracking file reflects all edited files

---

*This directive was authored by the project's second-in-command based on a comprehensive audit of the full repository. Every task has been verified against the actual codebase. Follow it precisely.*
