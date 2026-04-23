# Session 017 — Plan mode handoff: close Sprint 1 gaps (no false “Done”)

**Use this message to start the next chat in Plan mode.** Goal: produce an **execution plan** that drives **all remaining Sprint 1 Must-Haves** toward **honest Done** with **GUT + gdcli evidence** — not narrative closure.

---

## 0) Git push (human — blocked from agent remote)

`git push origin main` may fail with:

`refusing to allow an OAuth App to create or update workflow .github/workflows/godot-ci.yml without workflow scope`

**Fix:** push using credentials with **`workflow`** scope (PAT) or **SSH**, or temporarily remove/rename the workflow from the commit set (not recommended). Local `main` tip at last agent commit should be **`07dce9f`** (or newer if you committed after).

---

## 1) Hard truth — what is NOT complete (do not defer)

Cross-check [`production/sprints/sprint-1.md`](production/sprints/sprint-1.md) **Must Have** rows with [`docs/SCAFFOLD-REGISTER.md`](docs/SCAFFOLD-REGISTER.md).

| ID | Declared status | Reality |
|----|-----------------|--------|
| **S1-08** | Done | **Data files** exist; does **not** mean gameplay systems 11–16 are implemented. |
| **S1-09** | In progress | Code + LOS landed; sprint **Done** requires **AC-T01–T08** in **S1-17** apartment + human sign-off + prototype archive rule. |
| **S1-10** | In progress | Camera follow + GUT landed; **all AC-T08** / polish **not** proven. |
| **S1-11 – S1-13, S1-15 – S1-16** | Pending | **Scaffolds** or stubs — **must become substantive** per GDD + AC rows. |
| **S1-14** | In progress | **Thin** `ChaosMeter` + one GUT; sprint text still implies bus/meter contract — **S1-15** is the real meter. |
| **S1-17 – S1-18** | Pending | **No** production test apartment; **`run/main_scene`** still prototype per **ADR-001**. |

**Should Have (S1-19–S1-24):** all Pending — schedule after Must-Haves or in parallel only where sprint allows.

---

## 2) Plan mode mandate for the next agent

1. **Reconcile “Done” vs evidence**  
   For every sprint row marked **Done** or **In progress**, list **proof**: tests, scenes, AC IDs, or explicit gap.

2. **Single critical path**  
   Per sprint: `S1-09 closure → S1-11 → S1-12 → S1-15 → S1-16 → S1-17 → S1-18` (with **S1-10** parallel polish, **S1-13** / **S1-14** as specified in dependencies). Output a **ordered backlog** with **parallel tracks** only where there is **no shared merge conflict**.

3. **No silent deferrals**  
   Replace “TBD”, “optional”, “document deferral” with either **in-scope work** or a **producer-signed** exception recorded in **Mycelium** + sprint row footnote.

4. **CI**  
   After push works: confirm **GitHub Actions `godot-ci`** green. Extend plan if **gdcli script lint** on `src/**/*.gd` is required for your bar.

5. **Deliverable from Plan mode**  
   A **CreatePlan** (or equivalent) with atomic tasks, owners (`godot-gdscript-specialist`, `ui-programmer`, `qa-tester`), and **verification** per task (GUT / scene / human AC).

---

## 3) Read-first stack (next implementation session)

1. [`production/sprints/sprint-1.md`](production/sprints/sprint-1.md) — Must Have table + AC text  
2. [`docs/SCAFFOLD-REGISTER.md`](docs/SCAFFOLD-REGISTER.md)  
3. [`design/gdd/npc-personality.md`](design/gdd/npc-personality.md) — **S1-11**  
4. [`design/gdd/bidirectional-social-system.md`](design/gdd/bidirectional-social-system.md) — **S1-12**  
5. [`design/gdd/chaos-meter.md`](design/gdd/chaos-meter.md) — **S1-15**  
6. [`design/gdd/chaos-meter-ui.md`](design/gdd/chaos-meter-ui.md) — **S1-16**  
7. [`design/gdd/interactive-object-system.md`](design/gdd/interactive-object-system.md) — **S1-13**  
8. [`SESSION-015-PROMPT.md`](SESSION-015-PROMPT.md) — LOS (for NPC / level integration)  
9. [`docs/architecture/ADR-001-production-architecture.md`](docs/architecture/ADR-001-production-architecture.md) — layering, `main_scene`  
10. [`CLAUDE.md`](CLAUDE.md) — collaboration / Mycelium paths  

---

## 4) Opening line to paste into the next chat (Plan mode)

Copy from the block below:

```
Plan mode. Read SESSION-017-HANDOFF.md and execute its mandate.

Constraints:
- Do not mark any sprint row Done without listing GUT and/or AC evidence.
- Close S1-11 through S1-18 per production/sprints/sprint-1.md; scaffolds in docs/SCAFFOLD-REGISTER.md must be replaced with real behavior or explicitly blocked with producer sign-off.
- I will push git myself if workflow scope blocks the agent; plan should assume main includes commit 07dce9f (S1-10 camera + thin ChaosMeter + CI file).

Deliver: a single execution plan with atomic tasks, verification per task, and parallelization graph. No optional deferrals unless named as producer exceptions.
```

---

*Written for handoff after local work through **S1-10** slice + **S1-14** thin meter + CI/guardrail docs.*
