# Session 017 — Plan mode handoff: close Sprint 1 gaps (no false “Done”)

**Use this message to start the next chat in Plan mode.** Goal: produce an **execution plan** that drives **all remaining Sprint 1 Must-Haves** toward **honest Done** with **GUT + gdcli evidence** — not narrative closure.

---

## 0) Git / GitHub

**Current assumption:** `main` is **pushed** and GitHub matches local (PAT with **Workflows** or **SSH**). Use this doc as-is for the next session.

**If push fails again** with:

`refusing to allow an OAuth App to create or update workflow .github/workflows/godot-ci.yml without workflow scope`

use HTTPS with a PAT that includes **workflow** / **Workflows: write**, or **SSH**, or see prior session notes — do not strip `.github/workflows` from history as a workaround.

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

Copy from the block below. **After** you approve the plan that comes back, open **Agent mode** (same or new chat per your workflow) and instruct the agent to execute that plan with verification per task.

```
Plan mode. Read SESSION-017-HANDOFF.md (sections 1–3) and treat it as authoritative alongside production/sprints/sprint-1.md, docs/SCAFFOLD-REGISTER.md, docs/architecture/ADR-001-production-architecture.md, and CLAUDE.md.

Context: Git is set up; main is pushed to GitHub. Sprint 1 still has large gaps between declared status and real acceptance (see SESSION-017 gap table). CI may be green while gameplay Must-Haves remain incomplete.

Mandate:
1. Reconcile every Must-Have row (Done / In progress) with evidence: scenes, scripts, GUT tests, AC IDs — or an explicit gap.
2. Produce one ordered critical path: S1-09 closure through S1-18 per sprint dependencies (S1-10 polish parallel; S1-13 / S1-14 per docs), with parallel tracks only where merge-safe.
3. No silent deferrals: “optional” or TBD becomes in-scope work or a named producer exception (Mycelium + sprint footnote).
4. CI: confirm GitHub Actions godot-ci is green on main; include gdcli/script lint in the plan if that is the project bar.
5. Deliverable from Plan mode: an execution plan with atomic tasks and verification steps (GUT / scene / human AC) per task. Do not mark any row Done without proof.

After the plan is approved, execute in Agent mode: replace scaffolds in SCAFFOLD-REGISTER with substantive behavior for S1-11–S1-18 (and finish S1-09 Done, S1-10 AC-T08, S1-14 vs S1-15 split per planning docs). Update sprint-1 and SCAFFOLD-REGISTER only when evidence matches.
```

**Optional one-liner:** Plan mode — read SESSION-017-HANDOFF.md and production/sprints/sprint-1.md; produce an execution plan to close S1-09 through S1-18 with GUT/AC evidence only; main is already on GitHub.

---

*Written for handoff after local work through **S1-10** slice + **S1-14** thin meter + CI/guardrail docs.*
