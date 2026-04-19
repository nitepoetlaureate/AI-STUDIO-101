# Playtest Report — PLAYTEST-004: Session 013 integration gate

## Session Info

- **Date**: 2026-04-17
- **Build**: HEAD (Session 013 — TileMap + semisolid + env sprites + NPC MCP exports + Bonnie locomotion)
- **Duration**: Automated validation + doc pass (no full manual play session)
- **Tester**: Integration pass (Cursor agent + Godot 4.6 headless)
- **Platform**: macOS / Godot 4.6
- **Test Type**: Session 013 **Phase B/E** closure — scene load, GUT, import handoff

---

## Scope

**In scope:** `TestLevel.tscn` integration (TileMap floor + semisolid demo row, `Sprite2D` platform fills, crate art, parallax, `AnimatedSprite2D` NPCs), `BonnieController` locomotion + semisolid `collision_mask`, `IMPORT-GODOT.md` NPC + TestLevel truth, multi-scale NPC exports (`*-16px/`, `*-24px/`, `*-32px/`), `verification-013/` stills (**real export pixels** via `tools/composite_verification_013.py`; `tools/capture_verification_013.gd` remains for future **visible** Godot runs where `ViewportTexture.get_image()` works).

**Out of scope:** Chaos meter / charm full-loop play (Sprint S1-18 gameplay), subjective audio mix / feel pass (S1-05 API is in; assets optional).

---

## Automated checks

| Check | Result |
|-------|--------|
| `godot --headless --path . -s res://tools/boot_test_level_once.gd` | Pass (clean load) |
| GUT `res://tests/unit` (`gut_cmdln.gd` `-gdir=… -gexit`) | **9/9** (2026-04-17) |
| `gdcli scene validate` on `TestLevel.tscn`, `BonnieController.tscn` | **Pass** (0 issues, 2026-04-17) |

---

## Findings

1. **Headless viewport capture** — `ViewportTexture.get_image()` stays **broken** under the **dummy** display driver (even with a `SubViewport`). **verification-013** PNGs are **720×540 composites** built from shipped **`art/export/**` PNGs** (parallax, ground tile, Bonnie strip, NPC strips) via **`python3 tools/composite_verification_013.py`** — real game art pixels, not solid-colour stubs. For a **single true framebuffer** still, run the project in-editor and extend `capture_verification_013.gd` as needed.
2. **Semisolid** — Implemented via TileSet **physics layer 2** + **one-way** polygon + Bonnie **`velocity.y`** gate on `collision_mask`. Feel and margin tuning need **human** play (apex hop, edge pops).
3. **NPC art** — Throwaway MCP pixel blocks; **16 px** path wired in-scene; **24/32** folders exist for LOD / UI experiments per `IMPORT-GODOT.md` §3.5.

---

## Checklist

- [x] Session metadata filled in
- [ ] Core loop / meter / charm flows (S1-18) — **deferred**; prototype traversal only
- [x] Findings and severity logged (this section)

---

## Scene note (updated)

`TestLevel.tscn` **NPCs** use **`AnimatedSprite2D`** + **`NpcIdleFromSheet.gd`** with `res://.../art/export/npc/*-idle-sheet.{json,png}` (default **16 px**). **`SoftLandingPad`** retains a **single `ColorRect` greybox** per Session 013 allowance.
