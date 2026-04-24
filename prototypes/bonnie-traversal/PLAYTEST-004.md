# PLAYTEST-004 — Sprint 1 core loop (production apartment)

**Build:** `main` @ production `test_apartment.tscn`  
**Tester:** Agent (Layer 1 + headless); **human still required** for traversal AC spot-checks and meter/NPC visual sign-off  
**Date:** 2026-04-23  
**Environment:** Godot 4.6.2, 720×540, keyboard

## Session goal

Validate Sprint 1 Must-Haves **S1-09** (traversal AC-T01–T08), **S1-10** (AC-T08 camera), **S1-11–S1-18** per [production/sprints/sprint-1.md](../../production/sprints/sprint-1.md). **Do not mark sprint rows Done in-repo until this checklist is filled with PASS/FAIL evidence.**

## Agent-run evidence (2026-04-23)

| Gate | Result | Evidence |
|------|--------|----------|
| GUT `tests/unit` | **PASS** | 40/40 tests, 5.767s, exit 0 |
| `gdcli-godot script lint` | **PASS** | `error_count: 0` |
| Headless `test_apartment.tscn` | **PASS** | `--quit-after 8`, `--quit-after 15`, `--quit-after 125` — no script errors, exit 0 |
| Camera subsystem (AC-T08 surrogate) | **PASS** | `test_bonnie_camera_production.gd` — 3/3 (lookahead / config) |

**In-editor (F5) not executed by agent:** placeholder visuals, prop bumps, OOB respawn feel, and subjective AC-T01–T07 still need a human row below.

## Preconditions

- [x] `godot --headless --path . -s addons/gut/gut_cmdln.gd -- -gdir=res://tests/unit -gexit` — all green (**40/40, 2026-04-23**)
- [x] `npx -y gdcli-godot script lint` — 0 errors (**2026-04-23**)
- [x] `godot --headless --path . res://scenes/production/test_apartment.tscn --quit-after 8` — no errors (**2026-04-23**)

## Traversal (AC-T01–T08) — S1-09 / S1-10

| AC | Result | Notes |
|----|--------|-------|
| AC-T01 | **PENDING** | Human F5 per [bonnie-traversal.md](../../design/gdd/bonnie-traversal.md) §AC-T01; no frame-level harness in this run. |
| AC-T02 | **PENDING** | Human F5; automated: `test_input_system.gd`, config loads. |
| AC-T03 | **PENDING** | Human F5. |
| AC-T04 | **PENDING** | Human F5. |
| AC-T05 | **PENDING** | Human F5. |
| AC-T06 | **PENDING** | Human F5. |
| AC-T06b | **PENDING** | Human F5. |
| AC-T07 | **PENDING** | Human F5. |
| AC-T08 (camera) | **PASS (automated surrogate)** | `test_bonnie_camera_production.gd` 3/3; full AC wording still needs human confirm on `test_apartment.tscn`. |

## NPC / social (spot-check)

| Area | Result | Notes |
|------|--------|-------|
| Michael REACTING ×2 | **PENDING** | Human F5 + social/chaos drive; headless did not assert NPC reactions. |
| Charm during RECOVERING | **PENDING** | Human F5. |
| Christen appears after ~120s | **PARTIAL** | Long headless run exited 0 (`CHRISTEN_ARRIVAL_SEC` in `test_apartment_root.gd`); visibility/timer not asserted in automation — human should confirm in-editor. |

## Meter / UI

| Check | Result | Notes |
|-------|--------|-------|
| Chaos + social fills visible | **PENDING** | Human F5 (`ChaosMeterUI` bottom-right). |
| 6+ meter visual states distinguishable | **PENDING** | Human F5. |
| FED / overwhelm behaviour per design | **PENDING** | Human F5 + design reference. |

## Verdict

- **PASS / FAIL / BLOCKED:** **BLOCKED** for full Sprint 1 traversal/social/UI sign-off — **Layer 1 automated gates PASS**; **AC-T01–T07, NPC spot-checks, meter rows remain PENDING** until human PLAYTEST.
- **Blockers:** In-editor validation (F5) on `test_apartment.tscn` to close PENDING rows; optional: remove or archive debug NDJSON instrumentation in `BonnieController.gd` / `test_apartment_root.gd` after green human run.
- **Sign-off for marking S1-09 / S1-10 / S1-11–S1-18 Done in sprint-1:** _Deferred — replace with name/date after human closes PENDING rows above._
