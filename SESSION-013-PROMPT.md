# Session 013 — Opening brief (integration + Sprint 1 audio + studio tooling)

**Status — Session 013 closed (2026-04-19):** Phases **A–E** complete on `main` (fast-forward from `art/bonnie-mvp-1` through **`d3d2247`**, including **`chore: ignore and untrack AI-STUDIO-101.code-workspace`**) — TileMap **`surface`/`terrain`** + semisolid row, **32×32** rigid crate collision + scaled sprite, **Bonnie** strip locomotion + semisolid **`collision_mask`**, **parallax** + env **`Sprite2D`** (one **SoftLandingPad** `ColorRect` greybox retained per lock), **Michael + Christen** NPC exports + in-scene **`AnimatedSprite2D`**, **`verification-013/*.png`** (five **720×540** composites via **`tools/composite_verification_013.py`**), **`PLAYTEST-004.md`**, **S1-05** `AudioManager` + GUT, **`gdcli scene validate`** clean on touched scenes, **GUT** `res://tests/unit` **9/9**. **`AI-STUDIO-101.code-workspace`** is **gitignored** and **not tracked** (local editor config only). Optional: in-editor **`tools/capture_verification_013.gd`** if framebuffer grabs are needed later.

**Read first:** `NEXT.md`, `CLAUDE.md`, `.cursor/rules/claude-game-studio-bridge.mdc`, `prototypes/bonnie-traversal/art/_critique/round-2-intent.md` (Round 3 P0).

## Repo paths (canonical)

| Artifact | Path |
|----------|------|
| Session brief (this file) | `SESSION-013-PROMPT.md` |
| Art brief + exports | `prototypes/bonnie-traversal/art/` |
| Import / pivots / strip truth | `prototypes/bonnie-traversal/IMPORT-GODOT.md` |
| Prototype scene | `prototypes/bonnie-traversal/TestLevel.tscn` |
| Bonnie scene | `prototypes/bonnie-traversal/BonnieController.tscn` |
| Critique + verification PNGs | `prototypes/bonnie-traversal/art/_critique/` (still images: `verification-013/`) |
| Playtest note | `prototypes/bonnie-traversal/PLAYTEST-004.md` |
| Audio GDD + sprint | `design/gdd/audio-manager.md`, `production/sprints/sprint-1.md` |
| Audio autoload | `src/core/audio/AudioManager.gd`, `AudioEventBus.gd` |
| Mycelium | `./mycelium.sh`, `mycelium/scripts/context-workflow.sh`, `mycelium/scripts/compost-workflow.sh` |

## Dependency order (do not parallelize blindly)

1. **Phase A** (IMPORT-GODOT + JSON/PNG truth) before trusting any SpriteFrames indices.  
2. **Phase B** (TileMap + collision + custom data) before verification stills that claim affordances.  
3. **Bonnie + NPC + crate** can follow TileMap baseline; **one owner** should serialize edits to `TestLevel.tscn` to reduce merge pain.  
4. **Phase D (S1-05)** in parallel **only** if the worker stays in `src/core/audio/` + minimal `project.godot` bus lines — **avoid** `TestLevel.tscn` until scene integration lands or you explicitly sequence.  
5. **Phase E** (captures + PLAYTEST-004 + compost) after visible integration.

## Locked decisions (from producer Q&A)

| Topic | Decision |
|-------|----------|
| Merge to `main` | **Only after** integration is visibly done (tiles + Bonnie + parallax + verification + PLAYTEST-004), then your review. |
| Branch hygiene | **Rebase `art/bonnie-mvp-1` onto `main`** before heavy work; resolve conflicts early. |
| Cursor ↔ Claude | Enable **Third-party skills** in Cursor so `.claude/settings.json` hooks run; **plus** `.cursor/hooks.json` for `afterFileEdit`, `subagentStart`, `beforeShellExecution` (gdcli). |
| Mycelium | **Manual review** gates commits; each reviewed commit gets **`mycelium.sh note HEAD -k context`**. Run **`mycelium/scripts/compost-workflow.sh`** in Session 013. |
| TestLevel | **TileMapLayer** + **16×16** repeating tiles; **physics collision on TileMap**; **custom data on tiles** this session (floor / wall / one-way semantics). |
| Crate | **32×32** rigid body + sprite; **retune** level geometry that assumed 20×20. |
| Bonnie | **`AnimatedSprite2D` + `.tres` `SpriteFrames`**; **full Tier-A** mapping per **`IMPORT-GODOT`** after JSON/doc reconciliation; **hold last frame** where clip missing. |
| Round 3 | MCP edits allowed on `.aseprite` / exports; **soft-landing** + **platform-edge** micro-read; **reconcile IMPORT-GODOT ↔ JSON/PNG**. |
| Parallax | **In** Session 013. |
| RGBA | **Yes** for this pass. |
| NPCs | **Michael + Christen**, **idle ≥ 4 frames**, **`export/npc/michael-{16,24,32}px/`** (and christen); **Christen visible** in `TestLevel.tscn`. |
| Verification | **`art/_critique/verification-013/*.png`** + **`PLAYTEST-004.md`**; **one leftover greybox** acceptable. |
| Audio (parallel) | **S1-05** on branch per sprint; **placeholder + `docs/CREDITS.md`** for non-original samples. |
| gdcli | **Shell only** `/usr/local/bin/npx -y gdcli-godot …`; **`scene edit` allowed** — mycelium workflow **mandatory** (see bridge rule). |

## Phase A — Docs truth (P0)

1. Re-stat `bonnie-locomotion-sheet.png` + `bonnie-locomotion-sheet.json`; rewrite **`IMPORT-GODOT.md`** §3–§4 (strip size, cel count, `frameTags`, index table).  
2. Ensure **`NEXT.md`** reflects Session 013 priorities and branch name.

## Phase B — Godot integration

1. Build **TileSet** with collision + **custom data** (floor vs wall vs one-way). Replace `TestLevel` `ColorRect` fills (except the one allowed greybox).  
2. **32×32** crate: `RigidBody2D` + interaction impulse (prototype-level “finally interactive”).  
3. **Bonnie** `SpriteFrames` `.tres` + `AnimatedSprite2D` + state→clip table in prototype controller (no `class_name` on production Bonnie — stay under `prototypes/` or glue without violating ADR).  
4. **Parallax** backdrop node(s) from exports.  
5. **NPC** sprites placed in scene (static or minimal `AnimationPlayer`).

## Phase C — Round 3 art + exports

MCP/Aseprite as needed; re-export; update **`IMPORT-GODOT`** env inventory.

## Phase D — Parallel audio (subagent or second agent)

Implement **`AudioManager.gd`** per `design/gdd/audio-manager.md` + `production/sprints/sprint-1.md` **S1-05**; buses + API stubs filled; GUT if sprint demands.

## Phase E — Proof + merge prep

1. Five **1×** verification poses into `art/_critique/verification-013/`.  
2. **`PLAYTEST-004.md`** short note.  
3. **`gdcli scene validate`** on touched scenes.  
4. **`CHANGELOG.md` / `DEVLOG.md`** entries.  
5. Merge to `main` **after your review**. **Done** — producer-approved merge **2026-04-17**.

## Subagent dispatch (recommended)

Spawn **parallel** `Task` workers with narrow briefs, e.g.:

- **`godot-gdscript-specialist`:** TileSet + TileMapLayer + custom data + collision only.  
- **`technical-artist`:** Bonnie `SpriteFrames` `.tres` + import paths + pivot.  
- **`gameplay-programmer`:** Crate 32×32 + impulse + retune positions.  
- **`ui-programmer` or `writer`:** PLAYTEST-004 + verification captions.  
- **`godot-gdscript-specialist` (second):** S1-05 AudioManager (if isolated from scene merge conflicts).

Orchestrator merges order: **doc fix → TileMap → Bonnie → NPC → crate physics → audio → verification → compost → merge**.
