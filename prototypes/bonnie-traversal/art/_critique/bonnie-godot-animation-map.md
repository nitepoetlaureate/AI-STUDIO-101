# Bonnie — Aseprite tag → `BonnieController.State` (round 1 v2)

Until `IMPORT-GODOT.md` exists, use this one-line map when wiring `SpriteFrames` / `AnimationPlayer`: **Godot state → Aseprite `frameTags[].name`**.

`State.IDLE` → `idle` · `State.SNEAKING` → `sneak` · `State.WALKING` → `walk` · `State.RUNNING` → `run` · `State.SLIDING` → `slide` · `State.JUMPING` → `jump_up` / `jump_apex` / `jump_down` / `double_jump` (phase) · `State.FALLING` → `jump_down` (reuse fall read until split) · `State.LANDING` / skid → `land_skid` · `State.CLIMBING` → `climb` · `State.SQUEEZING` → `squeeze` · `State.DAZED` → `dazed` · `State.ROUGH_LANDING` → `rough_landing` · `State.LEDGE_PULLUP` → `ledge_cling` then `ledge_pull` (two-beat) · wall jump (from climb) → `wall_jump`.
