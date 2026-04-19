# Bonnie traversal prototype — art tree

## Layout

| Path | Purpose |
|------|---------|
| `ART-BRIEF.md` | Producer contract: grid, Tier-A states, naming, done bar. |
| `_critique/` | Direction, critiques, intent, verification stills (`verification-013/`). |
| `env/` | Aseprite sources (tilesets, parallax). |
| `bonnie/` | Aseprite sources + optional generator helpers (`*.py`, `*.lua`) — **not** imported by Godot at runtime. |
| `export/` | PNG / JSON / GPL shipped into Godot via `res://prototypes/bonnie-traversal/art/export/`. |

## Generator helpers (`bonnie/*.py`, `*.lua`)

These scripts support batch layout or tier grids. They are **offline tooling**. Document any command you use to regenerate artifacts in a commit message and in `mycelium.sh note` on the touched export paths.

## Integration handoff

See **`../IMPORT-GODOT.md`** (repo-relative: `prototypes/bonnie-traversal/IMPORT-GODOT.md`) for `SpriteFrames`, texture paths, and JSON strip truth.
