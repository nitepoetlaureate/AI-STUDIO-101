# Game Concept: BONNIE!

*Created: 2026-04-05*
*Status: Draft*

---

## Elevator Pitch

> You are BONNIE — a big black cat with an attitude, a traumatic relationship with
> indoor plumbing, and an unshakeable belief that you deserve tuna. Navigate dense,
> reactive environments filled with humans who have their own problems, engineer
> cascading chaos until somebody feeds you, and play it completely cool while
> everything burns.

---

## Core Identity

| Aspect | Detail |
|---|---|
| **Genre** | Sandbox chaos / puzzle game — 2D pixel art |
| **Platform** | PC (primary, Steam) |
| **Target Audience** | See Player Profile section |
| **Player Count** | Single-player |
| **Session Length** | 30–60 min per level; wandering encouraged |
| **Monetization** | Premium |
| **Estimated Scope** | Medium (6–12 months solo) |
| **Comparable Titles** | Haunting Starring Polterguy, Untitled Goose Game, Donut County |

---

## Core Fantasy

> You are a cat. You are not sorry about any of it.

You inhabit a dense, reactive world full of humans who have their own problems —
and BONNIE is about to become one of them. The fantasy isn't destruction for its
own sake — it's the *specific pleasure of being a cat*: reading a room, identifying
the one thing that will set someone off, doing it with complete nonchalance, and
then grooming yourself while they deal with the aftermath. Sometimes the chaos is
elegant and orchestrated. Sometimes you're hanging from a curtain rod wondering how
it came to this. Both feel exactly right.

BONNIE makes people happy AND angry. She rubs on people, meows at them, earns their
love — and then destroys their apartment. The relationship is real in both directions.
That back-and-forth is how the chaos meter fills.

---

## Unique Hook

> It's like Haunting Starring Polterguy, AND ALSO BONNIE has real physics, real
> personality, and real momentum — traversal IS the mechanic, the environments are
> dense Philadelphia-rooted sandboxes, every NPC has Maniac Mansion-depth
> personality, and people actually *talk*. You're not clicking highlighted objects.
> You're *being a cat.*

**The replayability promise**: Unlike games where the solution is always the same
(Untitled Goose Game's charm couldn't sustain replay because the script was fixed),
BONNIE's systems are stuffed with variables. NPC behavior, cascade potential, object
physics, movement style, social vs. chaos approach — no two runs feel identical
because no two players move through a space the same way.

---

## Player Experience Analysis (MDA Framework)

### Target Aesthetics

| Aesthetic | Priority | How We Deliver It |
|---|---|---|
| **Sensation** | 2 | Lush pixel art, parallax backgrounds, snappy physics, crunchy vocal samples, satisfying SFX on every interaction |
| **Fantasy** | 3 | You are a chaotic cat who always wins. BONNIE's personality IS the character fantasy |
| **Narrative** | 6 | Light character arc — BONNIE goes from stray to notorious. Environments tell stories. NPCs speak in SNES-style text + vocal samples |
| **Challenge** | 7 | Soft challenge — the puzzle is reading NPCs and engineering chaos chains, never punishing execution |
| **Fellowship** | N/A | Single player |
| **Discovery** | 4 | Dense environments reward patience. NPC behaviors, hidden spaces, secret interactions, discoverable mini-games, pest systems |
| **Expression** | 1 | Player style emerges from traversal and social/chaos balance. Every playthrough takes a different path to fed |
| **Submission** | 2 | Cozy at baseline. Low stakes. You can wander indefinitely eating bugs and mice. The game waits for you |

### Key Dynamics (What Players Will Do)

- Spend long periods in recon mode — slinking around, reading NPCs, mapping the
  environment before committing to a chain
- Discover that rubbing on someone first (earning goodwill) makes the eventual chaos
  hit differently — mechanically and comedically
- Try to engineer NPC cascades intentionally, then discover accidental ones are funnier
- Stumble into a discoverable mini-game mid-level and be genuinely surprised
- Share "watch what happens when I do this" moments — this is a game people will
  watch being played
- Find BONNIE's hidden survival loop (bugs, mice, trash) and briefly consider just
  doing that forever

### Core Mechanics

1. **Expressive traversal** — BONNIE moves with momentum, clumsiness, and style.
   Running has carry-through. Jumps are sometimes magnificent, sometimes disastrous.
   Running, climbing, squeezing, rubbing, sitting, and staring are all verbs.
   Presence is a mechanic before direct interaction is.

2. **Bidirectional social system** — BONNIE can be charming OR chaotic, and both
   fill the chaos meter in different ways. Rubbing on people, meowing, earning
   affection builds goodwill; chaos burns it and triggers reactions. The meter
   requires creativity across both axes — you can't just smash your way to fed.

3. **Reactive NPC system** — Each human has a personality profile, chaos tolerance,
   behavioral routine, and relationships to other NPCs. Cascade potential is baked
   into the NPC model: what A does affects what B does. Some feed when pushed far
   enough. Some need to be driven out. Some are antagonists to be trapped and
   humiliated. All of them *talk* — SNES-style text dialogue with crunchy
   Genesis/SNES vocal samples for exclamations and reactions.

4. **Environmental chaos system** — Every object is potentially interactive.
   Proximity affects objects. BONNIE's body makes things happen. Environmental
   sound design is responsive — a big mess getting made sounds like a big mess.

5. **Chaos meter** — Visible but hard to fill. Requires genuine creativity — positive
   social interactions, object destruction, NPC cascade engineering, and pest hunting
   all contribute in different ways. Scraps get you to the baseline. Real feeding
   requires going further. The meter doesn't reward brute-force smashing — it rewards
   reading the room.

6. **Antagonist / trap system** — Cat-hating NPCs who chase BONNIE. Counter-play is
   engineering their spectacular humiliation (Home Alone logic). Accidentally foiling
   crimes makes you a hero. Heroes feed you faster.

7. **Pest / survival system** — Mice, bugs, cockroaches, trash. BONNIE can survive
   indefinitely avoiding the main loop. The pounce-and-catch feels good in isolation.
   Mousing is a real mechanic, not a side note. Contributes to chaos meter.

8. **Discoverable mini-games** — Found organically mid-play rather than announced
   between levels (à la Yo! Noid's whack-a-mole screens, Nightshade's building rescue
   segments). Fixed occurrences in the game but the player stumbles into them. BONNIE
   has nine lives — some mini-games are triggered by near-disaster. See Mini-Games
   section below.

---

## NPC Dialogue and Audio

NPCs are not silent props. They have opinions, routines, and reactions — and they
*express them*.

- **Dialogue**: SNES-style text boxes with character voice. NPCs comment on BONNIE,
  on each other, on the chaos unfolding. Some have catchphrases. Some change what
  they say based on what's happened.
- **Vocal samples**: Crunchy Genesis/SNES-style digitized exclamations — surprise,
  anger, delight, fear. Used for punctuation, not narration. Think MK's "FIGHT!" or
  the Simpsons arcade's character voices — short, expressive, era-appropriate.
- **Environmental audio**: When a big mess is getting made, it should *sound* like a
  big mess is getting made. SFX is load-bearing for control feel and chaos feedback.
- **BONNIE's sounds**: Meows, chirps, thuds, the specific sound of a cat absolutely
  destroying something at 3am.

---

## Mini-Games

Mini-games are *discovered*, not announced. They appear at fixed points in the game
but feel organic to BONNIE's world — a natural thing that just happened.

**Design reference**: Yo! Noid's whack-a-mole bonus screens; Nightshade's building
rescue and impending-doom escape sequences. Short, expressive, tonally consistent,
with a bonus/powerup reward.

**Nine lives framing**: Some mini-games are triggered by near-disaster — BONNIE
getting into trouble activates a sequence she has to escape from. She's a cat. She
has nine lives. This is fine.

### Confirmed Mini-Games (Working)

| ID | Trigger | Description | Reward |
|---|---|---|---|
| MG-01 | Discovered in environment | BONNIE vs. giant roaches and mice — Yo! Noid-style, they pop from holes, she eats them before time runs out | Bonus chaos points + powerup |

### Mini-Games (TBD — develop in production)
- Laser pointer wall-jump ("slam dunk contest" format — BONNIE launching herself
  at a brick wall for maximum height)
- Making biscuits (kneading) on the owner while they're lying on the floor —
  timing/rhythm based
- Additional escape/survival sequences tied to the nine-lives framing
- Others to be discovered in development

---

## End-of-Level Payoff Structure

Every level ends with a **unique, hand-crafted feeding cutscene**.

**Structure**:
1. Chaos threshold met — BONNIE's body language shifts. Maximum nonchalance.
   *yea whateverrrrr.*
2. A human finally breaks and gets the food. The specific circumstances are
   level-unique (who feeds her, how, what they had to go through to do it).
3. The feeding sequence — detailed, exciting, the emotional payoff of the whole
   level. BONNIE eats with complete dignity while the environment exists in
   whatever state she's left it in.
4. BONNIE, finished, sits. Grooms herself. The chaos was always beneath her.

The feeding cutscene is *the reward*. It should feel earned and slightly
cathartic every single time. Players should be hyped when they get that tuna.

---

## Game Pillars

**1. Every Space is a Playground**
The environment is the game. Each level is a dense, readable, reactive world with
its own personality, cast, and logic. If a space doesn't reward exploration beyond
the chaos threshold, it isn't finished.
*Design test: A player spends 20 minutes without advancing the meter and still had
fun — this pillar is working.*

**2. BONNIE Moves Like She Means It**
Traversal is expression. Controls are snappy and physical. How you move through a
space matters as much as what you interact with. Presence is a mechanic.
*Design test: Two players describe completely different paths to getting fed in the
same level — this pillar is working.*

**3. Chaos is Comedy, Not Combat**
No punishment, no real failure, no hostility. Baseline tone: Toe Jam & Earl.
Peak chaos ceiling: Tom & Jerry / Gremlins 2. Cartoon violence in strict cartoon
fashion. BONNIE always wins — the question is only how spectacular it gets.
*Design test: A player laughs at a consequence rather than groans — this pillar is
working.*

**4. People Have Their Own Problems**
Every human NPC is a person first, obstacle second. They have agendas, routines,
relationships, and triggers that pre-exist BONNIE's arrival. They talk. They react
to each other. The best chaos comes from knowing your audience.
*Design test: A player says "oh I knew she'd react like that" about an NPC — this
pillar is working.*

**5. Small World, Big Cat**
Five levels (expandable), each with a distinct identity and cast. BONNIE begins
unknown. The environments escalate in chaos density and danger as her notoriety
grows — less hospitable, more unpredictable, more of a challenge. The arc is vibe
over plot.
*Design test: The final level feels like a genuinely harder place to be a cat than
the first — this pillar is working.*

### Anti-Pillars

- **NOT a challenge game** — No punishing difficulty, no complex fail states.
  Frustration is "I don't know how yet," never "I keep dying."
- **NOT a speedrun** — We never pressure the player toward the chaos threshold.
  Wandering is the game.
- **NOT mean-spirited** — BONNIE's chaos is a cat being a cat. The humans are
  ridiculous, not victims. The relationship is warm even when it's destructive.
- **NOT mechanical environments** — Every space tells you who lives there. No
  level is just a puzzle box.
- **NOT scripted linearity** — Untitled Goose Game's limitation was a fixed script.
  BONNIE's systems are variable-stuffed. No two runs should feel identical.

---

## Inspiration and References

| Reference | What We Take From It | What We Do Differently | Why It Matters |
|---|---|---|---|
| Haunting Starring Polterguy | Reactive chaos threshold system, NPC scare/drive-out split, humor-forward loop | Full physical traversal — not a click-to-haunt interface. Much denser environments. Bidirectional social system. | Proves the "cause chaos until threshold met" loop is intrinsically fun |
| Maniac Mansion | Deep NPC personalities with agendas and relationships, multiple solutions, environmental logic, character-driven comedy | Movement-based, not menu-based. No death, no failure states. | Proves personality-driven NPCs create emergent comedy |
| Little Nemo Dream Master | Distinct visual/tonal identity per world, dreamlike internal logic, being inside a character's physical presence | BONNIE is always BONNIE — no body-swapping, same spirit of "inhabiting" each world | Proves level-as-world over level-as-stage |
| Toe Jam & Earl | Vibe-forward design, accessible surface with systemic depth, warm weirdness, unhurried pacing | Has a chaos arc and destination; Toe Jam was pure wandering | Proves cozy + chaotic can coexist |
| Streets of Rage 2 | Control feel, audio feedback quality, music as world-building | No combat — same standard of "this must feel incredible to play" | Sets the quality bar for controls and audio |
| Mega Man 2 | Distinct themed levels, tight learnable mechanics, memorable per-level identity | No combat, no lives in the traditional sense | Proves 8 (or 5) distinct worlds is the right scope |
| Nightshade | Varied gameplay textures within one experience — action, puzzle, adventure coexisting. Discoverable scenario sequences. NPCs with opinions about you that evolve mid-level ("Lampshade"). | No genre-switching — variety from NPC/environment, not mode changes | Proves hybrid gameplay feel without mechanical dissonance |
| Home Alone | Antagonist-trapping mechanic, engineered humiliation as comedy, cause-and-effect chain payoffs | No deliberate setup UI — traps emerge from environmental logic | Proves "engineering the villain's downfall" is deeply satisfying |
| GTA 1 | Threshold progression without urgency, dense sandbox, player-driven pacing | No crime, no violence — chaos toward feeding | Proves players will find objectives in dense open environments without being pushed |
| Yo! Noid | Discoverable bonus game sequences embedded in levels, whack-a-mole style mini-games with bonus/powerup rewards | Organic discovery rather than announced transitions | Proves mini-games can feel native rather than bolted on |
| The Simpsons Arcade / Mortal Kombat | Between-moment tonal breaks — mini-games as palette cleansers with strong personality | Discoverable, not mandatory pacing beats | Proves mini-games extend tone rather than interrupting it |

**Non-game inspirations:**
- Philadelphia geography — Germantown Ave, Vernon Park, the Italian Market — real
  places with real character used as direct level sources
- Sun Ra & the Arkestra (Vernon Park mural) — cosmic weird beauty as visual/tonal
  reference for Level 1
- Tom & Jerry, Ren & Stimpy, Gremlins 2 — peak chaos aesthetic ceiling
- The Ramones, The Cramps — the design sensibility. Punk economy: small, fast,
  weird, full of personality
- BONNIE herself — a real cat found under a dumpster on Germantown Ave, clumsy,
  bitey, loves you, wants tuna

---

## Target Player Profile

| Attribute | Detail |
|---|---|
| **Age range** | 25–45 primary; 18–24 secondary |
| **Gaming experience** | Mid-core; nostalgic for NES/SNES/Genesis era |
| **Time availability** | 30–60 min sessions; completion-curious but not completion-driven |
| **Platform preference** | PC, Steam |
| **Current games they play** | Untitled Goose Game, A Short Hike, Katamari Damacy, Stardew Valley |
| **What they're looking for** | A game with genuine personality and warmth that doesn't punish them. Something to share. |
| **What would turn them away** | Punishing difficulty, environments that feel mechanical, no replayability, a fixed script |

---

## Technical Considerations

| Consideration | Assessment |
|---|---|
| **Engine** | Godot 4.6 — ideal for 2D pixel art, physics-based traversal, behavior tree NPCs, lightweight PC deployment |
| **Key Technical Challenges** | NPC personality + cascade system; momentum physics tuning; chaos meter balance; vocal sample integration; variable-stuffed replay systems |
| **Art Style** | Lush, detailed pixel art with parallax backgrounds. Aseprite source art + RetroDiffusion for generation/texture assistance |
| **Art Pipeline Complexity** | High — Aseprite (.aseprite) source files → CLI export → Godot SpriteFrames. AI-assisted generation via RetroDiffusion model in ComfyUI (private HF Space + Tailscale, CPU-only). Dense environments, rich NPC animation, unique feeding cutscenes per level. |
| **Audio Needs** | Music-heavy — original chiptune score (authored by developer), crunchy SNES/Genesis-style vocal samples, responsive SFX system |
| **Networking** | None |
| **Content Volume** | 5 levels (expandable), ~6 NPC archetypes per level, ~30–50 interactive objects per level, ~3–5 hours completionist, discoverable mini-games |
| **Procedural Systems** | None — hand-crafted environments are core to the vision. Replayability comes from variable-stuffed systems, not procedural generation |

---

## Level Arc

| # | Location | Arc Beat | Tone |
|---|---|---|---|
| 1 | Germantown Ave / Vernon Park, Philly | BONNIE as a stray — fast food row, Sun Ra mural backdrop, survival and scavenging, inadvertently meets the owner | Open air, low stakes, discovery |
| 2 | The apartment | First time indoors — learning what a house cat can do | Cozy, contained, escalating |
| 3 | Vet's office | Hostile territory — BONNIE does not consent to any of this | Tension + comedy |
| 4 | K-Mart | Consumer chaos — short-fuse strangers, enormous space, antagonist energy | Big energy, fast escalation |
| 5 | Italian Market, South 9th St | BONNIE lost and surviving — hardest level, tests everything learned. Avoid psychos. Get the tuna. Lay in the sun. Be found. | Survival + warmth, reunion + tuna payoff |

*Levels 6–8: TBD. Environments escalate in chaos density and danger — less
hospitable for a cat, more unpredictable, BONNIE's notoriety felt in the world
around her.*

---

## Replayability Architecture

BONNIE's systems are variable-stuffed by design. The goal: no two runs feel
identical. Variables that change across playthroughs:

- **Movement style** — runner / climber / pure cat produce different interactions
- **Social vs. chaos approach** — earning NPC goodwill first vs. going straight to
  destruction produces different cascade chains
- **NPC state entering cascades** — what an NPC was already doing affects how they
  react
- **Object interaction order** — the same five objects triggered in different orders
  produce different outcomes
- **Mini-game discovery** — not all players find them; when they do, context varies
- **Pest hunting integration** — players who engage the mouse/bug system create
  different environmental states

---

## Risks and Open Questions

### Design Risks
- NPC personality system complexity may balloon — needs strict per-NPC scope limits
- Chaos meter tuning is sensitive: too easy = no satisfaction, too hard = directionless frustration
- Bidirectional social system (charm vs. chaos) needs clear feedback so players understand both axes work
- Mini-game discoverability balance: too hidden = missed; too obvious = not a surprise

### Technical Risks
- Physics-based traversal feel in Godot 4.6 — needs early prototype to validate
- NPC behavior tree performance with multiple active agents — needs profiling
- Vocal sample integration and audio responsiveness in Godot — tooling setup has unknowns
- Aseprite + RetroDiffusion pipeline integration — tooling unknowns

### Market Risks
- Audience is passionate but niche — positioning should emphasize cozy chaos /
  Untitled Goose Game adjacent, not "cat game" broadly
- Philadelphia specificity is a genuine differentiator; lean into it

### Scope Risks
- Dense hand-crafted environments are art-intensive for a solo developer
- Unique feeding cutscenes per level (5+) require significant animation work
- Solo dev across art, music, code, and design is the primary bottleneck

### Open Questions

| Question | How to Resolve |
|---|---|
| Chaos meter visual design — how is it presented? | Early prototype + playtesting |
| NPC relationship persistence — do cascades reset? Can they be re-triggered? | NPC design sprint (use /design-system) |
| Does BONNIE gain anything between levels beyond narrative notoriety? | Design decision needed before Level 3 |
| Vocal sample sourcing and legal clearance | Audio direction sprint |
| Feeding cutscene format — animated in Godot, pre-rendered, or Aseprite flipbook? | Technical prototype |

---

## MVP Definition

**Core hypothesis**: The combination of expressive physical traversal + bidirectional
social NPC system creates emergent comedy that makes players want to replay the same
environment multiple times via different approaches.

**Required for MVP:**
1. BONNIE movement with momentum physics (run, jump, climb, proximity interaction,
   clumsiness system)
2. One environment (Level 2: the apartment) with ~15 interactive objects
3. Two NPCs with distinct personality profiles, tolerances, bidirectional
   social/chaos reactions, and cascade potential
4. Visible chaos meter
5. Fed animation: BONNIE eating with complete dignity

**Explicitly NOT in MVP:**
- Multiple levels
- Antagonist/trap system
- Pest mechanics
- Mini-games
- Dialogue / vocal samples (placeholder sound)
- Notoriety arc
- Parallax backgrounds (placeholder)
- Feeding cutscenes (placeholder animation)

### Scope Tiers

| Tier | Content | Features | Timeline |
|---|---|---|---|
| **MVP** | 1 level, 2 NPCs, core traversal | Movement, bidirectional social system, chaos meter, fed payoff | 4–6 weeks |
| **Vertical Slice** | Levels 1–2, full NPC system, antagonist mechanic, dialogue | All core systems, vocal samples, 1 mini-game | 3–4 months |
| **Alpha** | All 5 levels rough | All systems, rough art, full score | 6–8 months |
| **Full Vision** | 5 levels polished | All features, full cutscenes, polished art/audio | 10–14 months |

---

## Next Steps

- [ ] Run `/setup-engine godot 4.6` to configure engine and populate version-aware reference docs
- [ ] Run `/design-review design/gdd/game-concept.md` to validate completeness
- [ ] Run `/map-systems` to decompose BONNIE into individual systems with dependencies and priorities
- [ ] Run `/design-system` to author per-system GDDs (NPC personality system first)
- [ ] Run `/architecture-decision` for first technical decisions (scene structure, physics approach, NPC behavior architecture)
- [ ] Run `/prototype` on the core traversal mechanic — validate momentum feel in Godot 4.6
- [ ] Run `/playtest-report` after MVP prototype to validate core hypothesis
- [ ] Run `/sprint-plan new` to plan Sprint 1
