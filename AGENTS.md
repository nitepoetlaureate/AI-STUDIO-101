## Cursor Cloud specific instructions

### Project overview

This is **BONNIE!**, a Godot 4.6 (GDScript) 2D sandbox chaos/puzzle game in pre-production.
See `README.md` for full context, `CLAUDE.md` for studio architecture, and `design/gdd/game-concept.md` for the game concept.

### Running the game and tests

| Task | Command |
|------|---------|
| **Import assets** (required after fresh clone or Godot upgrade) | `godot --headless --path . --import` |
| **Run unit tests** (GUT 9.6.0, 15 scripts / 40 tests) | `godot --headless --path . -s addons/gut/gut_cmdln.gd -- -gdir=res://tests/unit -gexit` |
| **Bootstrap / smoke-run** (headless, 2 frames) | `godot --headless --path . --quit-after 2` |
| **Validate project structure** | `npx -y gdcli-godot doctor` |

### Gotchas

- **Import before first test run:** GUT's `class_name` types (`GutTest`, `GutMain`, etc.) are not available until you run `godot --headless --path . --import`. The CI workflow does this as a "bootstrap" step before tests.
- **Script parse errors on headless run are expected:** The project is in pre-production and some autoload scripts reference types (`InputSystemConfig`, `BonnieTraversalConfig`, `NpcState`, etc.) that only resolve when the full editor import cache is populated. The headless `--quit-after 2` run logs these errors but exits 0. Unit tests still pass because they import dependencies explicitly.
- **No linter beyond GDScript:** There is no separate lint step; GDScript compile errors surface during `godot --import` and during test runs. `gdcli doctor` validates binary + project structure.
- **No package manager:** This is a pure Godot project — no `package.json`, `requirements.txt`, or `Dockerfile`. The GUT addon is vendored in `addons/gut/`.
- **Node.js is only needed for `gdcli-godot`:** Install Node.js 20 if you need `npx -y gdcli-godot doctor` or scene editing via gdcli.
- **Mycelium directory is empty:** The `mycelium/` directory referenced in `CLAUDE.md` exists but contains no scripts. Mycelium commands will fail silently; this does not block game development or testing.
