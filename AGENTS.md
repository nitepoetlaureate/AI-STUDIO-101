# AGENTS.md

## Cursor Cloud specific instructions

### Project overview

BONNIE! is a Godot 4.6.2 GDScript 2D pixel art game (sandbox chaos/puzzle). The repo also houses the "Claude Code Game Studios" agent framework, but the primary development artifact is the Godot project.

### Running the game

```bash
godot --path /workspace
```

The main scene is `res://scenes/production/test_apartment.tscn`. Controls: WASD movement, Space jump, Shift sneak, E grab, F interact.

### Running unit tests (headless)

```bash
godot --headless --path /workspace -s addons/gut/gut_cmdln.gd -- -gdir=res://tests/unit -gexit
```

All 40 tests across 15 scripts should pass. GUT addon is vendored in `addons/gut/`.

### Linting / static checks

```bash
npx -y gdcli-godot doctor
```

There is no separate GDScript linter configured; `gdcli doctor` validates Godot binary presence, project file, and `.gd` file detection.

### Important caveats

- **Bootstrap required after fresh clone**: Before the first run or test, execute `godot --headless --path /workspace --import` to let Godot discover all `class_name` declarations and import assets. Without this, autoloads fail with "Parse Error: Could not find type" errors.
- **No package manager lockfiles**: This project has zero `package.json`, `requirements.txt`, etc. The only external dependency is the Godot 4.6.2 engine binary and optionally Node.js 20 for `npx -y gdcli-godot`.
- **Headless mode**: All tests and the project bootstrap run headless. Running the game with a GUI requires `DISPLAY=:1` (already set in Cloud Agent VMs).
- **CI reference**: `.github/workflows/godot-ci.yml` is the canonical CI pipeline definition — it downloads Godot 4.6.2, bootstraps, runs GUT, and runs gdcli doctor.
