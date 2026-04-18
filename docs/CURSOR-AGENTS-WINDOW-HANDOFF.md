# Cursor Agents Window — BONNIE! Sprint Handoff

Use this when continuing from **`NEXT.md` (Session 012)** with **Cursor’s Agents** UI (multiple agent tabs / parallel runs). Cursor’s exact labels evolve by version; look for **Agents**, **New agent**, and a **model** picker per agent.

---

## How many agents to start

Start **3** parallel agents unless you are solo-tinkering:

| # | Role | Why separate |
|---|------|----------------|
| **1** | **S1-05 Audio Manager** | Touches `src/core/audio/`, buses, autoload `AudioManager.gd` — isolated from level geometry. |
| **2** | **Prototype testbed** | Touches `prototypes/bonnie-traversal/TestLevel.tscn` (+ optional labels) — scene merge conflicts with audio if one agent does both. |
| **3** | **Orchestrator / hygiene** | Updates `CHANGELOG.md` / `DEVLOG.md`, Mycelium compost, `gdcli` smoke — read-mostly on `src/` gameplay code. |

Add a **4th** only if you split Audio into “buses + resources” vs “GUT + smoke tests” **after** agent 1 has a clear API.

---

## Models (per agent)

Cursor subscription controls which names appear. Use this **tiering**, not a specific vendor string:

| Agent | Tier | Reason |
|-------|------|--------|
| **1 — Audio** | **Highest you use for implementation** | Must align with `design/gdd/audio-manager.md`, autoload order, and Godot 4.6 API. |
| **2 — TestLevel** | **Mid** | Mostly `.tscn` layout, `StaticBody2D` / `RigidBody2D` / `Area2D` — repetitive; validate with `gdcli scene validate`. |
| **3 — Docs / hygiene** | **Fast / lower** | Summaries, changelog bullets, Mycelium `compost-workflow` steps — low risk. |

If you only have **one** premium tier: give it to **Agent 1 (Audio)**; run **2** and **3** sequentially afterward.

---

## Prompts (copy-paste)

**Shared prefix for all agents:**

```text
Repo: AI-STUDIO-101 (Godot 4.6, BONNIE!). Read NEXT.md and CLAUDE.md first.
Follow collaboration protocol: propose changes, avoid unrelated refactors.
gdcli: use shell `npx -y gdcli-godot …` (MCP may hang). Godot: `/usr/local/bin/godot` if on PATH.
Do not add class_name to production BonnieController until S1-09 (ADR-001).
```

---

### Agent 1 — S1-05 Audio Manager

```text
[Shared prefix]

Task: Implement Sprint 1 task S1-05 — Audio Manager per design/gdd/audio-manager.md and production/sprints/sprint-1.md.

Scope:
- Flesh out src/core/audio/AudioManager.gd (and AudioEventBus.gd if the sprint ties events there): four buses, routing, stubs → real behavior where the GDD specifies.
- Respect autoload order in project.godot (InputSystem already validates viewport on boot).
- Add or extend GUT tests only if the sprint plan calls for them; otherwise document manual test steps in DEVLOG.

Verify: npx -y gdcli-godot script lint; godot --headless --import --path . then GUT if tests touched.
```

---

### Agent 2 — Prototype validation grid (TestLevel)

```text
[Shared prefix]

Task: Expand prototypes/bonnie-traversal/TestLevel.tscn into a clearer “validation grid” (labeled zones or spatial separation) for: run/slide, squeeze under shelf, climb, rigid pushables, soft landing, parry ledges — without breaking existing AC coverage.

Constraints:
- Do not rename BonnieController prototype script paths used by run/main_scene.
- Keep SqueezeTrigger group; align Area2D footprint with actual low-ceiling geometry.
- RigidBody2D boxes must use non-zero RectangleShape2D size (e.g. 20×20).
- After edits: npx -y gdcli-godot scene validate prototypes/bonnie-traversal/TestLevel.tscn

Optional: add a short PLAYTEST-004.md checklist in prototypes/bonnie-traversal/ if the user wants written capture.
```

---

### Agent 3 — Changelog / Mycelium / smoke

```text
[Shared prefix]

Task: Hygiene only — no gameplay logic changes.

- If Agents 1–2 landed commits: add Pre-Production / session bullets to CHANGELOG.md; append DEVLOG.md session stub with date and pointers to PR/commit.
- Remind in notes: project.godot must keep display/window/stretch/aspect="keep" and rendering/textures/canvas_textures/default_texture_filter=1 or InputSystem will assert.
- If many stale Mycelium notes: suggest running mycelium/scripts/compost-workflow.sh (interactive); do not delete notes without user consent.

Verify: git diff --stat; no accidental project.godot stripping of keep/nearest lines.
```

---

## Merge order (avoid git pain)

1. Let **Agent 1** finish and merge to `main` (or open PR) **first** if they touch `project.godot` autoloads.  
2. **Agent 2** should rebase on latest `main` before pushing scene-only changes.  
3. **Agent 3** runs last on top of merged work.

If two agents must edit `project.godot`, **serialize** them — Godot merge conflicts in `[input]` and `[autoload]` are painful.

---

## When you are done

- One **primary** chat (or Agent 3) runs: `godot --headless --import --path .`, GUT if applicable, `gdcli script lint`.  
- `mycelium/mycelium.sh note HEAD -k context -m "…"` after meaningful merges (see `.claude/rules/mycelium.md`).
