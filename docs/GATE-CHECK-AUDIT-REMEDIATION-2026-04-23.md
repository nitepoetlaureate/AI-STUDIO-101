# Gate check — audit remediation (2026-04-23)

**Scope:** Post–**project audit remediation** plan execution — not a full “Production → Polish” gate.

## project-stage-detect (summary)

- **Design:** MVP GDD set present under `design/gdd/`; **`systems-index.md`** approved.
- **Production:** `src/` active; **Sprint 1** plan in `production/sprints/sprint-1.md`.
- **Prototype:** `prototypes/bonnie-traversal/` remains reference; **`run/main_scene`** still prototype per **ADR-001** until **S1-17**.
- **Tests:** GUT under `tests/unit/`; **CI** added (`.github/workflows/godot-ci.yml`) to make green runs empirical on push/PR.

**Declared stage:** `production/stage.txt` → **`Production`**.

## Gate verdict: **CONCERNS** (not FAIL)

**CI scope:** Passing **godot-ci** means **GUT** + **`gdcli doctor`** on the runner only. It does **not** mean Sprint 1 Must-Haves are complete, **S1-09 Done**, or **AC-T** signed off — see **`production/sprints/sprint-1.md`**.

| Area | Status | Notes |
|------|--------|-------|
| Milestone B (Session 015 LOS + docs) | **PASS** | Inventory + §10 + drift fixes landed earlier; SESSION-015 row Session 014 corrected in this pass. |
| Data parity (`assets/data`) | **PASS** | **`chaos_meter_ui_config.tres`** added; sprint tree + **S1-08** row reconciled. |
| Doc / onboarding | **PASS** | **`NEXT.md`** split “approved design” vs “implementation gaps”; **`docs/SCAFFOLD-REGISTER.md`** added. |
| Empirical CI | **CONCERNS** | Workflow: **`curl -L`** on Godot zip + **`--quit-after 2`** bootstrap before GUT. Confirm green on GitHub. **`gdcli script lint`** on every `src/**/*.gd` is **deferred** (cost + noise); run locally / pre-commit — see **Recommended next actions**. |
| Sprint 1 gameplay completeness | **CONCERNS** | **S1-10** camera slice landed **2026-04-23**; **S1-11–S1-13, S1-15–S1-16** still largely scaffolds — see scaffold register. |
| S1-14 AC | **CONCERNS** | Thin **`ChaosMeter`** subscribe + **`test_chaos_event_bus_meter.gd`** landed **2026-04-23**; full **S1-15** formulas + sprint “Done” still pending. |

**FAIL** would apply if: CI permanently red, ADR layering broken, or sprint marked Done without tests.

## Recommended next actions

1. Confirm **godot-ci** is green on GitHub after push; fix URL or import steps if the runner differs from local macOS.
2. Run **`npx -y gdcli-godot script lint --file <path>`** locally on changed `.gd` (full-tree lint not in CI by design unless added later).
3. Continue **S1-15** chaos formulas and **S1-11+** per critical path; update **`docs/SCAFFOLD-REGISTER.md`** when scaffolds graduate.
