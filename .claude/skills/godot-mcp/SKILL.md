---
name: godot-mcp
description: "Invoke Godot engine operations via gdcli (Godot CLI). Enables agents to validate scripts, inspect scenes, run headless, and check project state."
argument-hint: "[operation] [args]"
user-invocable: true
allowed-tools: Read, Glob, Grep, Shell
---

# Godot CLI (gdcli) — Team Reference

gdcli gives all agents headless access to Godot 4.6 operations from the terminal.
**Package**: `gdcli-godot` (npm) — **Archived by author** (mystico53/gdcli) but functional.
**Version**: 0.2.3

## CRITICAL: Shell Invocation Required

**CallMcpTool transport hangs** when invoking gdcli MCP tools (diagnosed Session 008, confirmed Session 009). All gdcli operations MUST use Shell until Cursor resolves this:

```bash
npx -y gdcli-godot <command> [args]
```

JSON output is the default when piped. Force in terminal with `--json`.

## Environment Verification

```bash
npx -y gdcli-godot doctor
```

Checks: `godot_binary` (GODOT_PATH or PATH), `project_file` (project.godot), `gd_files` (*.gd count). All must pass before other operations.

## Command Reference

### Diagnostics

| Command | Purpose |
|---------|---------|
| `doctor` | Check Godot installation and project health |

### Scripts

| Command | Purpose |
|---------|---------|
| `script lint [--file <path>]` | Check scripts for parse errors (all or one) |
| `script create <path> --extends <Type> --methods <list>` | Create GDScript with boilerplate |

### Scenes

| Command | Purpose |
|---------|---------|
| `scene list` | List all scenes with node counts |
| `scene validate <path>` | Validate scene for broken references |
| `scene create <path> --root-type <Type>` | Create new .tscn scene |
| `scene edit <path> --set <Node::property=value>` | Edit node properties |
| `scene inspect <path> [--node <name>]` | Inspect scene (nodes, resources, connections) |

### Nodes

| Command | Purpose |
|---------|---------|
| `node add <scene> <Type> <name> [--instance <tscn>] [--sub-resource <Type>] [--parent <name>] [--props <key=val;...>]` | Add node to scene |
| `node remove <scene> <name>` | Remove node and children |
| `node reorder <scene> <name>` | Reorder node (draw/process order) |

### Sub-resources

| Command | Purpose |
|---------|---------|
| `sub-resource add <scene> <Type> --wire-node <name> --wire-property <prop>` | Add sub-resource and wire to node |
| `sub-resource edit <scene> <id> --set "<property=value>"` | Edit sub-resource properties |

### Connections

| Command | Purpose |
|---------|---------|
| `connection add <scene> <signal> <from-node> <to-node> <method>` | Add signal connection |
| `connection remove <scene> <signal> <from-node> <to-node> <method>` | Remove signal connection |

### Sprites

| Command | Purpose |
|---------|---------|
| `load-sprite <scene> <name> <texture> [--sprite-type Sprite2D\|Sprite3D] [--parent <node>] [--props <key=val;...>]` | Add Sprite2D/3D with texture in one call |

### Project

| Command | Purpose |
|---------|---------|
| `project info` | Display project metadata |
| `project init` | Initialize new Godot project (creates project.godot) |

### UIDs

| Command | Purpose |
|---------|---------|
| `uid fix [--dry-run]` | Fix stale UID references (Godot 4.4+ important) |

### Documentation

| Command | Purpose |
|---------|---------|
| `docs <Class> [member]` | Look up Godot API docs |
| `docs <Class> --members` | List all methods/properties/signals |
| `docs --build` | Build/rebuild docs cache via `godot --doctool` |

### Runtime

| Command | Purpose |
|---------|---------|
| `run [--timeout <sec>] [--scene <tscn>]` | Run project headlessly (default 30s timeout) |

MCP-only (non-blocking, unavailable via Shell):

| Tool | Purpose |
|------|---------|
| `run_start` | Start headless run, returns session ID |
| `run_read` | Read output from running session |
| `run_stop` | Stop running session |

## When to Use gdcli vs. Godot Editor

| Task | gdcli | Godot Editor |
|------|-------|--------------|
| GDScript syntax check | `script lint` | |
| Validate scene loads | `scene validate` | |
| Inspect scene structure | `scene inspect` | |
| Add/edit nodes programmatically | `node add`, `scene edit` | |
| Fix stale UIDs | `uid fix` | |
| Headless test run | `run` | |
| Live playtest / feel evaluation | | Required |
| Inspector tweaking / tuning | | Required |
| Sprite/animation preview | | Required |

## Dispatch Guidance

gdcli is particularly valuable for:
- **Haiku-tier agents** that don't reliably know `.tscn` format
- **Validation workflows** — `scene validate` and `script lint` catch errors LLMs miss
- **Iterative scene editing** — avoids reading/rewriting entire files
- **Headless testing** — `run` for crash detection and log capture
- **Environment sanity** — `doctor` at session start

For Opus/Sonnet agents authoring new scenes from scratch, direct file writing may be faster (per the author's own benchmark showing ~50% speed advantage for frontier models).

## Known Limitations

- Headless mode cannot render CanvasLayer — debug HUD output will not appear
- Physics simulation requires `--timeout <n>` framing; results vary
- macOS: `DISPLAY` env not required for headless, but Rosetta may affect performance
- MCP non-blocking run tools (`run_start`/`run_read`/`run_stop`) are unavailable via Shell

## Project Integration

- Engine: Godot 4.6.2 (stable)
- Renderer: `gl_compatibility` — compatible with headless
- Physics: GodotPhysics2D — headless physics works correctly
