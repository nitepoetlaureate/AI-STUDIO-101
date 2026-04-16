---
name: godot-mcp
description: "Invoke Godot engine operations via the Godot CLI MCP. Enables agents to run builds, export scenes, validate GDScript, and check project state from within Claude Code tool calls."
argument-hint: "[operation] [args]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Bash
---

# Godot CLI MCP — Team Reference

The Godot CLI MCP gives all agents headless access to Godot 4.6 operations
from within Claude Code. This replaces the need for the user to manually
launch Godot for validation tasks.

## Available Operations

> **Note**: This MCP was set up in Session 007. Update this section with the
> actual MCP tool names and signatures after installation.

### Validation
```bash
# Check GDScript syntax (no scene required)
godot --headless --check-only --script <path/to/script.gd>

# Run GUT tests headlessly
godot --headless --path . -s addons/gut/gut_cmdln.gd -gdir=tests/unit
```

### Export / Build
```bash
# Export for macOS (requires export templates)
godot --headless --export-release "macOS" ./builds/bonnie-macos.zip
```

### Scene validation
```bash
# Open a scene and immediately quit (catches import errors)
godot --headless --path . --scene prototypes/bonnie-traversal/TestLevel.tscn --quit
```

## When to Use Godot MCP

| Task | Use MCP | Use Godot Editor |
|------|---------|------------------|
| GDScript syntax check | ✅ | |
| Run unit tests (GUT) | ✅ | |
| Validate scene loads | ✅ | |
| Export builds | ✅ | |
| Live playtest / feel evaluation | | ✅ |
| Inspector tweaking / tuning | | ✅ |
| Sprite/animation preview | | ✅ |

## Hooks Integration

The `validate-commit.sh` hook can invoke the MCP for pre-commit GDScript
validation. See `.claude/hooks/validate-commit.sh` for integration points.

## Godot 4.6 CLI Flags (Verified)

```
--headless          Run without display server (required for CI/server)
--check-only        Parse GDScript without executing (syntax check)
--path <dir>        Project root (required if not in project dir)
--scene <path>      Open a specific scene on launch
--quit              Quit after initialization
--quit-after <n>    Quit after N frames (useful for render tests)
-s <script>         Run a script on launch
```

## Known Limitations

- Headless mode cannot render CanvasLayer — debug HUD output will not appear
- Physics simulation requires `--quit-after <n>` framing; results vary
- macOS: `DISPLAY` env not required for headless, but Rosetta may affect performance
- GUT tests must be run with the GUT CLI runner, not the editor plugin

## Project Integration Notes

- Engine: Godot 4.6 (pinned 2026-02-12)
- Renderer: `gl_compatibility` — confirmed compatible with headless
- Physics: GodotPhysics2D — headless physics works correctly
- The `--headless` flag is already in `.claude/settings.json` as an allowed Bash command
