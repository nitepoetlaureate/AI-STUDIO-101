# Minimal plan: S1-14 ChaosEventBus → S1-15 ChaosMeter (closure of sprint AC)

**Goal:** Satisfy **`production/sprints/sprint-1.md`** **S1-14** GUT clause: manual emit on **`ChaosEventBus.object_chaos_event`** moves **`chaos_fill`** on **`ChaosMeter`**, and sets up **S1-15** to extend the same subscription pattern.

## Phase 1 — S1-14 (thin, test-driven)

1. **`ChaosMeter.gd`** (non-autoload `Node`):
   - Load `res://assets/data/chaos_meter_config.tres` in `_ready()`.
   - Subscribe: `ChaosEventBus.object_chaos_event.connect(_on_object_chaos_event)`.
   - Implement `_on_object_chaos_event(value: float)` → add to an internal **`chaos_fill`** clamped to **`chaos_fill_cap`** from config (or raw increment per sprint AC wording — match **`chaos-meter.md`** when implementing S1-15 fully).
   - Expose **read-only** getter(s) for tests: `get_chaos_fill_for_test()` or `chaos_fill` property documented test-only.
2. **GUT** `tests/unit/test_chaos_event_bus_meter.gd`:
   - Instantiate `ChaosMeter` in a `SceneTree` (or use GUT scene pattern from existing tests).
   - `ChaosEventBus.object_chaos_event.emit(0.02)` (or sprint example value).
   - Assert `ChaosMeter` internal fill changed as expected.
3. Keep **Systems 8 & 15** otherwise silent — no new autoloads.

## Phase 2 — S1-15 (full meter)

- Replace incremental stub with **GDD formulas** (REACTING aggregation, `social_fill`, `meter_state`, invariants).
- Retain **`ChaosEventBus`** subscription; add NPC/social inputs per **`chaos-meter.md`**.
- Expand GUT: pure chaos plateau, charm gate, combined path (sprint **S1-15** row).

## Dependencies

- **S1-14** before **S1-15** in critical path only for **signal contract** stability; full NPC/social (**S1-11–S1-12**) can stub NpcState in tests until those systems exist.

## Owner split

- **gameplay-programmer:** `ChaosMeter` + test.
- **qa-tester:** AC checklist vs sprint row.
