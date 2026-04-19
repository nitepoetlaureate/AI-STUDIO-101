# NPC export art (`res://prototypes/bonnie-traversal/art/export/npc`)

Runtime PNGs + JSON for **Michael** and **Christen** (Session 013). Sources live in `res://prototypes/bonnie-traversal/art/npc/source/` (`*-npc-v01.aseprite`).

## Files

| File | Role |
|------|------|
| `michael.png` / `christen.png` | First-frame still (icons / UI) |
| `michael-idle-sheet.png` + `michael-idle-sheet.json` | Horizontal strip + Aseprite **json-hash** for `idle` (4 frames) |
| `christen-idle-sheet.png` + `christen-idle-sheet.json` | Same for Christen |

### Multi-scale (`michael-16px/`, `michael-24px/`, `michael-32px/`, same for `christen-*`)

Nearest-neighbour scaled exports for LOD / UI. **`TestLevel`** uses the **base** (`npc/`) paths by default; swap `sheet_*_path` on `NpcIdleFromSheet` to point inside a subfolder for experiments.

`TestLevel.tscn` uses **`NpcIdleFromSheet.gd`** on `AnimatedSprite2D` nodes to build `SpriteFrames` from the sheet + JSON (same idea as Bonnie locomotion import).

## Authoring

Use **Aseprite MCP** (`user-aseprite`): see `art/npc/scripts/README.md`. Re-export after edits, then run Godot **Project → Reload Current Project** or `--import` so `.import` updates.
