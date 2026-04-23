# Session 016 — S1-10 Camera (production) + empirical baseline

**Status:** **Implementation landed (2026-04-23)** — production **`BonnieCamera`** + **`BonnieCameraConfig`** + **`bonnie_camera_config.tres`** + scene wiring + GUT. **Polish / full AC-T08** may still need human playtest.  
**Milestone anchor:** **Milestone B** — Session 015 LOS + traversal slice remains the last closed vertical slice; **S1-09 “Done”** still requires human **AC-T01–T08** in **S1-17** apartment per sprint. **Milestone A** (full Sprint 1 Must-Haves) is **not** claimed.

**CI guardrail:** A green [`.github/workflows/godot-ci.yml`](.github/workflows/godot-ci.yml) run proves **headless GUT + `gdcli doctor` only**. It does **not** close **S1-09 Done**, **S1-11–S1-18**, or substitute **human AC-T**. See [`production/sprints/sprint-1.md`](production/sprints/sprint-1.md) and [`docs/GATE-CHECK-AUDIT-REMEDIATION-2026-04-23.md`](docs/GATE-CHECK-AUDIT-REMEDIATION-2026-04-23.md).

---

## Read first

| # | Path | Why |
|---|------|-----|
| 1 | [`NEXT.md`](NEXT.md) | Handoff + implementation gaps |
| 2 | [`production/sprints/sprint-1.md`](production/sprints/sprint-1.md) | **S1-10** row, deps (**S1-09**), frame order |
| 3 | [`design/gdd/camera-system.md`](design/gdd/camera-system.md) | Look-ahead table, vertical framing, ledge bias, zoom |
| 4 | [`docs/SCAFFOLD-REGISTER.md`](docs/SCAFFOLD-REGISTER.md) | **`BonnieCamera.gd`** is a scaffold today |
| 5 | [`docs/architecture/ADR-001-production-architecture.md`](docs/architecture/ADR-001-production-architecture.md) | Layering: `gameplay/camera`, no `ui` imports |
| 6 | [`SESSION-015-PROMPT.md`](SESSION-015-PROMPT.md) | LOS rig API Bonnie exposes (`get_los_*` optional for camera; primary contract is position + state) |
| 7 | [`src/gameplay/bonnie/BonnieController.gd`](src/gameplay/bonnie/BonnieController.gd) | Signals: `state_changed`, movement; camera reads Bonnie node |
| 8 | [`.github/workflows/godot-ci.yml`](.github/workflows/godot-ci.yml) | CI must stay green after changes |

---

## Goal

1. Replace [`src/gameplay/camera/BonnieCamera.gd`](src/gameplay/camera/BonnieCamera.gd) scaffold with **production** `Camera2D` behavior matching **camera-system.md** MVP scope needed for **AC-T08** and sprint **S1-10** row: state-scaled **look-ahead**, **vertical framing** (cat’s-eye), **smooth reversal** (no whip), **ledge approach bias** hook (radius + offset — can align with traversal GDD constants via config Resource).
2. **Data-driven tuning:** add `BonnieCameraConfig` **Resource** + `assets/data/bonnie_camera_config.tres` (or extend an existing config only if ADR/sprint already allows — prefer dedicated Resource per camera GDD §7 knobs).
3. **Wiring:** production scene [`scenes/gameplay/BonnieController.tscn`](scenes/gameplay/BonnieController.tscn) (or parallel camera scene) — `Camera2D` child or sibling per project convention; **do not** break `run/main_scene` prototype until **S1-17** unless you add a parallel “production boot” scene for manual QA (**ADR-001**).
4. **Tests:** GUT smoke — camera global position moves toward look-ahead when Bonnie velocity is non-zero (headless tolerances); or state-transition triggers expected offset change. Follow existing [`tests/unit/test_bonnie_controller_production.gd`](tests/unit/test_bonnie_controller_production.gd) patterns.
5. **Verification:** `godot` GUT + `npx -y gdcli-godot doctor` + `script lint --file` on touched `.gd`.

---

## Non-goals (this session)

- Full **recon zoom** polish if it balloons scope — ship analog zoom skeleton + config hooks if timeboxed.
- **S1-17** apartment assembly.
- **S1-11+** NPC/social/chaos implementation.

---

## Deliverables

- [x] Substantive **`BonnieCamera.gd`** (+ **`BonnieCameraConfig.gd`** / **`bonnie_camera_config.tres`**).
- [x] Scene wiring — see **Integration** below.
- [x] **GUT** — [`tests/unit/test_bonnie_camera_production.gd`](tests/unit/test_bonnie_camera_production.gd).
- [x] **`CHANGELOG.md`** / **`DEVLOG.md`** + **Mycelium** context on closure commit.

### Integration

- [`scenes/gameplay/BonnieController.tscn`](scenes/gameplay/BonnieController.tscn): child **`BonnieCamera`** (`Camera2D` + [`BonnieCamera.gd`](src/gameplay/camera/BonnieCamera.gd)), default config from **`res://assets/data/bonnie_camera_config.tres`**.
- **`run/main_scene`** remains prototype per **ADR-001**; open production scene in editor or instantiate `BonnieController.tscn` in tests to exercise the camera.

---

## Process

- [`CLAUDE.md`](CLAUDE.md) collaboration: user approves writes/commits unless orchestrator policy overrides — align with **sprint B2** before batch merge.
- Branch naming: `feature/s1-10-camera` (see **CLAUDE.md** studio naming).

---

## Evidence — Milestone B (reference)

- Session 015 closure: [`SESSION-015-PROMPT.md`](SESSION-015-PROMPT.md) **Closed**; consumer inventory + §10 hard cutover.
- Audit remediation: [`docs/GATE-CHECK-AUDIT-REMEDIATION-2026-04-23.md`](docs/GATE-CHECK-AUDIT-REMEDIATION-2026-04-23.md) (**CONCERNS** — scaffolds + S1-14 GUT still open).
- CI: `.github/workflows/godot-ci.yml`.
