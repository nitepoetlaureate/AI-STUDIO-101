# Technical Preferences

<!-- Populated by /setup-engine. Updated as the user makes decisions throughout development. -->
<!-- All agents reference this file for project-specific standards and conventions. -->

## Engine & Language

- **Engine**: Godot 4.6
- **Language**: GDScript (primary), C++ via GDExtension (performance-critical only)
- **Rendering**: Godot 2D renderer (CanvasItem / CanvasLayer)
- **Physics**: Godot Physics 2D — CharacterBody2D for BONNIE, RigidBody2D for physics objects
  (Jolt is 3D-only and not relevant to this project)

## Performance Philosophy

> **Design target: the most beloved cult classic 2D game ever made for the Sega Dreamcast.**
>
> BONNIE should run at full fidelity on any modern computer — including low-end machines
> with integrated graphics, 4GB RAM, and a 2GHz CPU. If a device can run a browser,
> it can run BONNIE. Resource efficiency is not an optimization pass; it is a first-class
> design constraint from day one.
>
> Nothing about BONNIE's aesthetic goals requires modern GPU hardware.
> Discipline now prevents suffering later.

## Performance Budgets

- **Target Framerate**: 60fps locked
- **Frame Budget**: 16.6ms total (all subsystems must fit)
- **Internal Render Resolution**: 720×540 (4:3) — Dreamcast-era proportions, integer-scales
  cleanly to 1440×1080 (2×) and 2880×2160 (4×). Pillarboxed on 16:9 monitors.
  Rendered with nearest-neighbor filtering — no blur, perfect pixels at any display size.
  *Scaling to 4K costs essentially nothing: the GPU renders 720×540 regardless of monitor size.*
- **Aspect Ratio**: 4:3 locked. Pillarbox on widescreen displays (black bars on sides).
- **Stretch Mode**: Godot `viewport` + `keep` — integer scale preferred, GPU handles upscale.
- **Draw Calls**: ≤50 per frame (batched sprites, atlased textures)
- **Memory Ceiling**: 256MB total application memory
- **Texture / VRAM Budget**: 64MB — every sprite sheet must earn its bytes
- **Target Hardware Floor**: Integrated graphics (Intel HD / AMD Vega iGPU),
  4GB system RAM, any CPU from 2013 or later. Runs on anything that runs a browser.
- **Audio**: Compressed OGG (music streams), short uncompressed WAV (SFX) — no uncompressed music in repo

## Naming Conventions

- **Classes**: PascalCase — `BonnieController`, `NpcPersonality`, `ChaosManager`
- **Variables/Functions**: snake_case — `chaos_meter`, `get_tolerance()`, `on_npc_reacted()`
- **Signals**: snake_case past tense — `chaos_threshold_reached`, `npc_reacted`, `fed_triggered`
- **Files**: snake_case matching class — `bonnie_controller.gd`, `npc_personality.gd`
- **Scenes**: PascalCase matching root node — `BonnieController.tscn`, `NpcGrumpyOwner.tscn`
- **Constants**: UPPER_SNAKE_CASE — `MAX_CHAOS`, `BASE_TOLERANCE`, `SEMITONE_PITCH_RANGE`

## Testing

- **Framework**: GUT (Godot Unit Testing addon)
- **Minimum Coverage**: [TO BE SET — target 70% on game logic systems]
- **Required Tests**: Chaos meter logic, NPC state machines, cascade trigger conditions,
  physics edge cases (momentum/clumsiness system)

## Forbidden Patterns

- Singletons for mutable game state — use signals or dependency injection
- `$NodePath` string lookups in `_process()` — use `@onready var` cached references
- Untyped `Array` or `Dictionary` — use typed variants (`Array[NpcState]`, `Dictionary[String, float]`)
- String literals in AnimationPlayer calls — use StringName: `$AnimPlayer.play(&"bonnie_run")`
- Uncompressed music assets in the repository
- Physics queries every frame without need — cache results where possible
- Any post-processing effect that requires a discrete GPU

## Allowed Libraries / Addons

- **GUT** — Godot Unit Testing (testing framework)
- [Additional addons: propose via /architecture-decision before adding]

## Art Pipeline

- **Source Format**: Aseprite (.aseprite) — canonical format for all sprites, tilesets, and animations. Never commit flattened PNGs as source.
- **Export Target**: PNG sprite sheets + JSON animation data → Godot SpriteFrames resource
- **Aseprite CLI**: `aseprite -b --sheet output.png --data output.json input.aseprite`
  Scriptable via Lua for batch operations and automation
- **Aseprite MCP**: Research available MCP servers; configure in `.claude/settings.local.json` if found.
  Fallback: CLI-only pipeline is fully functional without MCP.
- **RetroDiffusion**: Local pixel art generation via RetroDiffusion model weights (SD 1.5 fine-tuned).
  **NOT** the retrodiffusion.ai cloud API — local model only.
- **ComfyUI hosting**: Private HuggingFace Space (custom Docker: ComfyUI + Tailscale client +
  RetroDiffusion model weights). The Space joins the Tailnet as a node; all Tailnet devices
  access ComfyUI at `http://[space-tailscale-ip]:8188`. The Aseprite RetroDiffusion extension
  connects to this address as if it were localhost. No public tunnel required.
- **Generation constraints**: Canvas ≤256px, steps 15–20 (CPU-only HF Space optimization)
- **GPU upgrade path**: Same Docker container, GPU-enabled HF Space tier — zero code changes required
- **Asset naming**: All exported assets use snake_case matching their GDScript class names
  (e.g., `bonnie_run.png`, `npc_grumpy_owner.aseprite`)

## Architecture Decisions Log

<!-- Quick reference linking to full ADRs in docs/architecture/ -->
- [No ADRs yet — use /architecture-decision to create one]
