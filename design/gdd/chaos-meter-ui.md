# System GDD: Chaos Meter UI

> **Status**: Approved
> **Author**: game-designer + ux-designer
> **Created**: 2026-04-17
> **System #**: 23
> **Priority**: MVP
> **Implements Pillars**: 3 (Chaos is Comedy, Not Combat), 1 (Every Space is a Playground)

---

## 1. Overview

The Chaos Meter UI is the visual layer that communicates the Chaos Meter's internal
state (System 13) to the player at every frame. It is a read-only display: it owns
no game state, it modifies nothing, and it holds no logic beyond translating the four
values it receives from System 13 into pixel art, color, animation, and audio signals.

The widget takes the form of a **pixel art cat food bowl** anchored to the bottom-right
corner of the viewport. The bowl fills from the bottom up in two visually distinct
layers: a deep indigo chaos fill (bottom, capped at 55% of total fill height) and a
warm amber social fill (top, occupying the remaining 45%). At every moment, the bowl
tells the player how close BONNIE is to being fed — not by displaying a number, but by
showing how full the bowl is.

The most important design constraint on this system is stated in System 13 §3.1 rule 8
and must be honored by every visual and audio decision made here: **the meter does not
count down and does not punish.** The bowl never empties on its own. It never flashes
red. It never looks threatening. It is a progress indicator shaped like the prize —
a bowl that fills up until it is full, and then someone feeds BONNIE.

The second most important design constraint is teaching the HOT plateau without text.
When pure chaos has been exhausted (chaos_fill at its cap), the lower bowl layer freezes
while the upper bowl layer begins to subtly animate — inviting the player's eye to the
zone that still has room. This is the social axis becoming legible: not through a
tutorial, but through the bowl visually asking "what goes here?"

---

## 2. Player Fantasy

> *The bowl isn't filling itself. You're filling it.*

The chaos meter UI delivers the fantasy of **visible progress toward a known, earnable
reward** — without the anxiety of a timer or the threat of failure. The bowl is always
in the corner of the player's eye. It never shouts. It never panics. When BONNIE knocks
something off a shelf, the bottom layer rises slightly. When she rubs Michael's leg in
exactly the right moment, the warm amber layer rises noticeably more. Both axes show up
in the same bowl. The relationship between the two is spatial and immediate.

### Three Moments the UI Must Deliver

**The first chaos spike.** BONNIE knocks something. The chaos fill rises visibly —
satisfying, direct, unmistakable. The bowl is responding. The player understands:
"chaos fills that part."

**The plateau realization.** The chaos fill has stopped moving. It's clearly full —
packed, static. The player watches. Nothing. More chaos. Still nothing. But the upper
portion of the bowl is doing something subtle — shimmering slightly, waiting. The player
leans in. Something different must go there.

**The social payoff.** BONNIE rubs Michael's leg during his VULNERABLE window. The amber
layer jumps — visibly more than a chaos event moved the chaos layer. The player sees the
efficiency of the levity path without being told about it. They feel clever. They do it
again.

### Aligned MDA Aesthetics

| Aesthetic | Priority | How This UI Delivers It |
|-----------|----------|-------------------------|
| **Expression** | 1 | The bowl pattern (how much chaos vs. social fill) is a visual record of the player's approach — two playthroughs look different in the bowl |
| **Discovery** | 4 | The HOT plateau visual teaches the social axis without a tutorial — the aha moment is self-authored |
| **Submission** | 2 | The bowl never threatens. It waits. The player can ignore it. The cozy baseline holds. |

---

## 3. Detailed Design

### 3.1 Visual Form: The Food Bowl

**Decision**: The meter takes the form of a **pixel art cat food bowl** — the same
object BONNIE is trying to fill. This is the strongest choice because:

- **Thematic closure**: The goal is to be fed. The meter is shaped like the vessel
  that will hold the food. Filling the bowl = winning the level.
- **Not a health bar**: A round-bottomed, distinctly food-bowl-shaped vessel cannot
  be mistaken for a health indicator. Health bars are horizontal rectangles. The bowl
  is immediately read as "progress toward something good," not "remaining life."
- **Dual-fill readability**: A bowl naturally accommodates two stacked fill layers —
  the bottom layer settles first, the top layer fills in above it. The visual logic
  matches the mechanical logic of chaos_fill + social_fill.
- **HOT plateau legibility**: A half-full bowl with a packed bottom and an empty,
  shimmering top half is immediately comprehensible. The space is obviously there.
  Something should go in it.
- **Pillar 3 tone**: A cat food bowl is inherently comedic and warm. It reads as
  invitation rather than threat. It supports the "Chaos is Comedy, Not Combat" pillar
  in its basic shape.

The bowl is rendered entirely in pixel art at native 720×540 resolution, with
nearest-neighbor filtering. It is positioned in a fixed screen-space layer (CanvasLayer
above the game world) — it does not scroll with the camera.

### 3.2 Component Split: Two Fill Layers

**Decision**: Show both components separately within the same bowl.

The fill area of the bowl is divided into two **fixed zones**:
- **Chaos fill zone**: the bottom 55% of the fill area (aligned with `chaos_fill_cap`)
- **Social fill zone**: the top 45% of the fill area (aligned with `social_fill_weight`)

The two zones are separated by a **1-pixel cap line** embedded in the bowl interior.
This is a thin horizontal line, warm-cream in color, subtly distinguishable from both
fill colors without being harsh or prominent.

**Why show the split rather than a unified bar?**

Showing the split is hypothesized to teach the system significantly faster than a unified
bar (pending playtest validation): if the fill stalls at 55% and the upper zone is visibly
empty, the player has all the information they need — "the bottom section is full,
the top section is not." They don't need to be told a cap exists. They see the cap.

The additional visual complexity is acceptable because:
- It is communicated spatially (bottom half vs. top half), not numerically
- The two zones remain part of the same bowl — one widget, not two
- The split is reinforced by texture and color (not just height), creating redundant
  readability channels for colorblind players

**Fill layers visual specification:**

| Layer | Maps To | Fill Direction | Color | Texture |
|-------|---------|---------------|-------|---------|
| Chaos fill | `chaos_fill / chaos_fill_cap` | Bottom → up | Deep indigo (`#2D1F5E`) | Coarse 2-pixel noise pattern; animated in WARMING/HOT, static (packed) from CONVERGING onward |
| Social fill | `social_fill / social_fill_weight` | Chaos layer top → up | Warm amber (`#E8A042`) | Smooth gradient with 1-pixel sparkle particles cycling through fill area |

The chaos layer fills from the bottom of the bowl's fill area upward. The social layer
fills directly above the chaos layer, from the cap line upward. They are always stacked
— there is no gap between them.

### 3.3 Chaos Cap Communication (The Critical UX Challenge)

The "chaos is capped" visual signal must fire when chaos_fill actually reaches its cap —
at **CONVERGING entry** (`meter_value >= 0.55`), NOT at HOT entry (`meter_value >= 0.40`).
During HOT state (0.40–0.54), chaos is still building. Showing a "packed" texture while
the fill is still visibly rising would directly contradict the visual.

#### HOT State Visuals (meter_value 0.40–0.54): "Chaos Is Nearing Full"

During HOT, chaos_fill is approaching but has not reached its cap. The visual signals
this escalation without claiming the cap has been hit:

1. **Chaos fill texture accelerates**: The animated 2-pixel noise pattern increases its
   cycle rate — noise cells shift every 4–6 frames (vs. 8–12 in WARMING), suggesting
   faster, more intense chaos accumulation. The texture remains visibly animated.

2. **No cap line changes, no sparkles**: The cap line stays at its default warm-cream.
   The social fill zone does not yet animate. The player's attention stays on the rising
   chaos fill — which is still the active axis.

#### CONVERGING State Visuals (meter_value >= 0.55): "Chaos Is Done — Try Something Different"

**Context**: When `meter_state` transitions to CONVERGING, `chaos_fill` has reached
`chaos_fill_cap = 0.55`. The chaos zone is physically full. The player can trigger
unlimited additional chaos events and the bottom layer will not move. This is the
game's primary design signal: *try something different.*

**Visual changes entering CONVERGING state** (triggered on CONVERGING entry):

1. **Chaos fill texture freezes**: The animated noise pattern transitions from the
   "turbulent" state to the "packed" state (noise cells frozen, static, as if
   compressed solid). This transition takes 4 frames. The chaos fill is now visually
   "done" — it communicates "no more room here."

2. **Cap line brightens**: The 1-pixel cap line shifts from default warm-cream to a
   slightly brighter, warm-white (`#F5E6C8`). This draws the eye to the boundary
   without being loud. Duration: instant on state entry.

3. **Social fill zone begins invitation animation**: The empty space in the social fill
   zone above the cap line starts a slow **shimmer cycle** — individual 1-pixel warm
   amber dots appear, hang for 4–6 frames, then fade. The density is low (2–4 sparkles
   active at any time across the entire 16×29 social zone pixel area). The cycle period
   is 48 frames (~0.8 seconds). This creates a "breathing" effect — the space is alive
   and waiting.

4. **No color changes to the bowl frame**: The outer bowl frame and base do not change
   color. The signal is entirely inside the fill area. The bowl itself remains neutral.

**What the player reads without text:**
- Bottom zone: full, packed, not moving
- Top zone: empty, slightly animated, clearly a different zone
- Interpretation: the bottom is finished; something fills the top

This is the social axis becoming legible. The player will naturally attempt something
different within the observable playtest target of < 5 minutes in the plateau state
(System 13 §3.6 balance table). If they perform a charm interaction, the social layer
responds immediately and visibly — the confirmation is instantaneous.

**Accessibility note**: In `reduced_motion` mode, the social zone sparkles are disabled.
A static 1-pixel dimple pattern distinguishes the empty social zone from the empty space
above the bowl. The cap line brightening still occurs (static color only).

### 3.4 FEEDING Imminent Signal

**Trigger**: `meter_state == FEEDING` (`meter_value >= 0.95`)

**Visual changes:**
1. The entire bowl frame (the pixel art outline and base of the bowl) gets a **warm
   highlight rim** — a 1-pixel inner glow on the bowl's interior wall edges, rendered
   in bright amber (`#FFD166`). This outlines the inside of the bowl shape, making the
   whole vessel feel lit from within.
2. The social fill sparkles increase in density — from 2–4 active sparkles to 6–8,
   cycle period shortens to 24 frames (~0.4 seconds). The social fill area is buzzing.
3. The bowl undergoes a very subtle vertical "vibration" — a periodic 1px vertical
   pulse (see §3.9 for authoritative frame timing). This reads as anticipation, not
   danger. In `reduced_motion` mode, this is disabled.

**Audio**: On entering FEEDING state, the audio event system receives
`chaos_meter_ui_state_changed(MeterState.FEEDING)`. The audio system plays the FEEDING
anticipation cue — a short, rising musical motif (2–3 notes, warm and food-adjacent
in tone). This is distinct from the ambient state layers and plays once on entry.

**What the player reads**: The bowl is about to tip. BONNIE is about to get fed.
Something is imminent. The visual escalation is warm and exciting, not threatening.

### 3.5 Chaos Overwhelm UX

**Context**: The chaos overwhelm FED path fires when `chaos_event_count` on Michael or
Christen crosses their overwhelm threshold (8 and 7 respectively), with `meter_value`
still in HOT state (~55%). This is the "attrition win" — the NPC feeds BONNIE not
because they want to, but because they're broken.

**Design decision: the overwhelm path receives NO FEEDING visual signal.**

When overwhelm FED triggers:
- `meter_value` is still ~0.55
- `meter_state` is still `HOT`
- System 23 never enters the FEEDING visual state
- The bowl does not animate toward full
- The warm glow and vibration never fire
- The anticipation audio cue never plays

The level transitions to the feeding cutscene from a HOT-state bowl. The bowl is
half-full. The crescendo never happened. The player got what they wanted — but the bowl
didn't finish filling. This is the anti-reward: the UI withholds the satisfying FEEDING
signal that the charm path earns.

**What the player reads**: The level ended, but the bowl is still half empty. Something
didn't happen the right way. Players who have seen the charm path's FEEDING state will
immediately notice the absence. Players on their first overwhelm run will feel an
unresolved quality to the ending — the level is over but the bowl didn't fill.

This is intentional. The charm path produces the full bowl, the warm glow, the
anticipation crescendo. The overwhelm path produces an abrupt cut. The feeding
cutscene handles the emotional distinction (exasperated dialogue vs. warm dialogue) —
the UI's contribution is simply silence where there should have been a signal.

> **Flag for user review**: An alternative approach is a brief "surge" animation where
> the bowl rapidly fills and immediately cuts to the cutscene (a compressed version of
> the FEEDING signal). This would make the overwhelm win feel more impactful at the cost
> of reducing the design distinction between the two paths. Recommend playtesting both
> in the first prototype session.

### 3.6 Screen Position

**Decision**: Bottom-right corner of the viewport, fixed in screen space.

The bowl widget is anchored at `(viewport_width - meter_margin_right - meter_widget_width,
viewport_height - meter_margin_bottom - meter_widget_height)`. With default values
(see §7), this places the bottom-right corner of the widget at 8px from the viewport's
right edge and 8px from the viewport's bottom edge.

**Rationale:**
- **Bottom-right is visually unambiguous**: The primary play area center, NPC interaction
  zones, and BONNIE herself occupy the horizontal and vertical midpoints of the screen.
  Bottom-right is the convention for a "here is your progress" indicator (established
  by hundreds of games) and does not compete for attention with the action.
- **Vertical bowl reads correctly in this position**: A bowl filling upward in the
  bottom-right is semantically sensible — it's sitting on the floor, where a food bowl
  lives. The metaphor is grounded.
- **Out of NPC body language territory**: NPC goodwill tier animations are character-
  level and read across the full character sprite. The bottom-right corner is as far
  from most NPC sprite positions as possible in a 720×540 scene.

The bowl does not move, scroll, or change position based on camera state. It is a
CanvasLayer element rendered above the game world.

### 3.7 Pixel Art Constraints and Sizing

**Widget dimensions:**

| Component | Width (px) | Height (px) | Notes |
|-----------|-----------|------------|-------|
| Total widget | 32 | 96 | Includes bowl frame art, fill area, and base |
| Bowl frame (top lip) | 32 | 10 | Decorative rim; varies with bowl shape art |
| Fill area | 16 | 64 | The internal space that fills; centered in bowl |
| Chaos fill zone | 16 | 35 | Bottom 55% of fill area: `floor(64 × 0.55) = 35px` |
| Social fill zone | 16 | 29 | Top 45% of fill area: `64 - 35 = 29px` |
| Cap line | 16 | 1 | At y = (bowl_fill_origin_y + 29)px from fill top |
| Bowl base | 32 | 22 | Foot and bottom curve of bowl |

**Pixel constraints:**
- All artwork is authored at 1:1 pixel scale (no sub-pixel geometry)
- Fill heights are always integer pixel values (see §4 for quantization formula)
- No smoothing, no antialiasing, no bilinear filtering
- Animation frame counts must be multiples of 4 frames for consistent timing at 60fps
- At 2× display scale (default window), the widget renders at 64×192px on screen —
  clearly legible at normal viewing distance

**Nearest-neighbor compliance:**
- The fill layers are drawn as solid rectangles (chaos fill, social fill) within the
  fill area. The bowl frame art is a sprite overlay drawn on top. This approach (solid
  fill + sprite frame) keeps the fill area renderer entirely in integer-pixel space.
- The sparkle animation (social fill zone invitation) uses whole-pixel dot placement —
  no sub-pixel positions. Sparkle dot positions cycle through a pre-authored 16-entry
  lookup table of `(x, y)` offsets within the social zone bounds.

**Art pipeline note**: The bowl sprite is a single 32×96px Aseprite source file with
layers for: bowl frame, fill area mask (used by the renderer to clip fill rectangles),
cap line, and bowl base. The fill area mask is a pure white rectangle matching the fill
area dimensions above. The renderer draws chaos fill and social fill as colored
rectangles clipped to this mask, then composites the bowl frame sprite on top.

### 3.8 Audio

System 23 communicates to the audio system via emitted signals only — it never calls
audio functions directly. All audio cues are triggered by `meter_state` transitions.

**Ambient state layers** (each state maintains one ambient audio layer while active):

| Meter State | Ambient Layer | Character |
|-------------|---------------|-----------|
| COLD | None | Silence — only game-world audio |
| WARMING | `chaos_meter_warming_ambient` | Subtle low-frequency resonance; barely audible; chaos is building |
| HOT | `chaos_meter_hot_ambient` | The warming hum, but textured differently — a compressed, "packed" sound; suggests something full and settled |
| CONVERGING | `chaos_meter_converging_ambient` | Two textures blending: the chaos hum is present but a warm overtone begins layering in |
| TIPPING | `chaos_meter_tipping_ambient` | Both layers at higher intensity; an anticipatory quality |
| FEEDING | `chaos_meter_feeding_ambient` | Replaced by one-shot FEEDING cue on entry (see below) |

**One-shot transition cues** (fire once on state entry):

| Transition | Cue Name | Description |
|------------|----------|-------------|
| Any → CONVERGING | `chaos_meter_cap_reached` | A small, satisfying "thud/thwump" — something clicking into place. Communicates the chaos section is full without being alarming. |
| TIPPING → FEEDING | `chaos_meter_feeding_imminent` | A short, warm rising musical motif. 2–3 notes. Anticipation, not alarm. |
| Any → COLD (on level reset) | `chaos_meter_reset` | Optional soft "whoosh" as the bowl empties — only on level transition, not during play |

**Signal interface** (System 23 emits these; Audio System subscribes):
```
signal meter_state_changed(old_state: MeterState, new_state: MeterState)
signal meter_fill_updated(chaos_fill: float, social_fill: float, meter_value: float)
```
The Audio System subscribes to `meter_state_changed` and manages ambient layer
transitions independently. System 23 does not know or care how the Audio System
implements fade-in/fade-out between layers.

**Accessibility**: All ambient audio layers must respond to the player's music/ambient
volume settings. The one-shot cues respond to SFX volume settings. If the player has
muted ambient audio, the state layers are silent; the UI still functions correctly.

### 3.9 Transition Animations

**Core principle**: At 720×540 with nearest-neighbor filtering, sub-pixel interpolation
produces visual artifacts. All fill heights must be integer pixel values. All animations
operate in whole-pixel space.

**Fill level display — "fill chase" pattern:**

The displayed fill does not snap instantly to the target value from System 13. It uses
a fill chase interpolation: the displayed fill value tracks the target value at
`fill_chase_speed` per second, then is quantized to integer pixels before drawing.

This creates a smooth "filling" motion without sub-pixel rendering. The fill never
jumps; it flows upward. Fast changes (a REACTING event adds chaos) produce a quick but
smooth rise. Slow changes (passive proximity goodwill) produce a gentle creep.

Social fill _can_ decrease (goodwill falls when NPCs enter CLOSED_OFF or chaos events
cost goodwill). The chase interpolation works in both directions — the fill can drain
smoothly as well as rise. This makes goodwill loss visible as a gentle receding, not a
sudden drop. Players who watch the bowl during a CLOSED_OFF state will see the amber
layer slowly recede.

**State visual changes:**

| Change Type | Transition Approach |
|-------------|---------------------|
| Fill texture noise cycle acceleration (entering HOT) | Noise cycle rate increases from 8–12 frames to 4–6 frames per cell shift. Immediate on HOT entry. |
| Fill texture HOT → CONVERGING (turbulent → packed) | 4-frame cross-dissolve between turbulent noise sprite and packed noise sprite. Both sprites are pre-authored in the bowl's Aseprite layers. |
| Cap line brightening (entering CONVERGING) | Instant single-pixel color swap on state entry |
| Social zone sparkle animation start (CONVERGING) | Begin cycling through sparkle lookup table immediately on CONVERGING entry |
| Bowl frame warm glow (FEEDING) | 3-frame fade-in of glow overlay sprite (pre-authored 32×96 layer with amber inner-edge pixels) |
| Feeding vibration (FEEDING) | Every 16 frames: widget moves 1px up, 1px down, 1px up, returns to origin. 4 frames total. Loop until state exits. |
| State exit (any state back to lower state) | Reverse the entering transitions. Glow fade-out: 3 frames. Sparkles stop cycling immediately. Texture transitions: 4 frames back. |

**Hard snaps that are intentional:**
- Cap line brightening: instant. Subtlety is appropriate here; a 4-frame transition
  would make it feel like a bug, not a state change.
- Social zone sparkle activation/deactivation: immediate start/stop on state entry/exit.
  The sparkles are at low density — activating them is not jarring.

### 3.10 State Palette Reference

Full color specification for all state-dependent visuals:

| Element | State | Color | Hex |
|---------|-------|-------|-----|
| Bowl frame / base | All | Warm dark grey | `#3A3028` |
| Bowl interior (empty background) | All | Deep charcoal | `#1A1520` |
| Chaos fill (active, WARMING/HOT) | WARMING, HOT | Animated indigo | `#2D1F5E` with noise (faster cycle in HOT) |
| Chaos fill (packed, CONVERGING+) | CONVERGING/TIPPING | Dense indigo | `#221848` (static) |
| Social fill | CONVERGING+ | Warm amber | `#E8A042` with sparkles |
| Cap line (default) | HOT-approaching | Warm cream | `#C8B090` |
| Cap line (brightened) | CONVERGING/TIPPING | Bright warm white | `#F5E6C8` |
| Social zone sparkles | CONVERGING/TIPPING | Bright amber | `#FFD166` |
| Bowl inner glow | FEEDING | Bright amber | `#FFD166` |
| COLD fill (chaos, minimal) | COLD | Deep indigo (small fill) | `#2D1F5E` |

**Colorblind mode (mandatory):**
Color alone must never be the only differentiator. The chaos/social split is also
communicated by:
- **Texture**: chaos fill uses a coarse noise pattern; social fill is smooth with
  sparkle particles. These are visually distinct in greyscale.
- **Position**: chaos fill is always the bottom layer; social fill is always above it.
  Position is color-independent.
- **Motion**: the HOT plateau sparkle animation is in the social zone only. Even in
  greyscale, a static bottom zone and an animated upper zone communicate the distinction.

All state palette colors above have been chosen with deuteranopia/protanopia
consideration: indigo and amber are not in the red/green confusion range. For tritanopia
(blue/yellow confusion), the texture differentiation is the primary read.

### 3.11 Accessibility

| Requirement | Implementation |
|-------------|----------------|
| Reduced motion | Disable sparkle animation, bowl vibration, fill texture animation. Fill height still updates correctly. Cap line brightening remains (static color). |
| Colorblind mode | Texture + position differentiation is primary. See §3.10. |
| Audio volume | All cues respond to player volume settings. UI functions correctly at zero volume. |
| Interactive elements | None — this widget is display-only. No input handling required. |
| Scalable text | No text in this widget. N/A. |
| Minimum legibility | At 1× display scale (720×540 native), the 32×96px widget must be legible — QA to confirm at minimum scale. |

---

## 4. Formulas

### 4.1 Fill Height Quantization

The displayed fill height for each component is derived from the live values provided
by System 13, interpolated by the fill chase, then quantized to integer pixels.

```
# Called every frame
# Inputs from System 13 (read-only):
#   chaos_fill: float [0.0–0.55]
#   social_fill: float [0.0–0.45]

# Fill chase interpolation (updates display_chaos_fill and display_social_fill):
display_chaos_fill += (chaos_fill - display_chaos_fill) * fill_chase_speed * delta
display_social_fill += (social_fill - display_social_fill) * fill_chase_speed * delta

# Clamp to avoid floating-point overshoot:
display_chaos_fill = clamp(display_chaos_fill, 0.0, chaos_fill_cap)      # chaos_fill_cap = 0.55
display_social_fill = clamp(display_social_fill, 0.0, social_fill_weight)  # social_fill_weight = 0.45

# Quantize to integer pixels:
chaos_display_px = max(0, floor(display_chaos_fill / chaos_fill_cap * chaos_zone_pixel_height))
social_display_px = max(0, floor(display_social_fill / social_fill_weight * social_zone_pixel_height))
```

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| `chaos_fill` | float | 0.0–0.55 | System 13 | Live chaos component from Chaos Meter |
| `social_fill` | float | 0.0–0.45 | System 13 | Live social component from Chaos Meter |
| `display_chaos_fill` | float | 0.0–0.55 | Internal | Lerped display value for chaos fill |
| `display_social_fill` | float | 0.0–0.45 | Internal | Lerped display value for social fill |
| `fill_chase_speed` | float | 1.0–8.0 | tuning knob | Lerp rate per second. Default: `4.0` |
| `chaos_fill_cap` | float | 0.55 | System 13 constant | Must match System 13's `chaos_fill_cap` |
| `social_fill_weight` | float | 0.45 | System 13 constant | Must match System 13's `social_fill_weight` |
| `chaos_zone_pixel_height` | int | 35 | tuning knob | Pixel height of chaos fill zone. Default: `floor(fill_pixel_height * 0.55)` |
| `social_zone_pixel_height` | int | 29 | tuning knob | Pixel height of social fill zone. Default: `fill_pixel_height - chaos_zone_pixel_height` |
| `fill_pixel_height` | int | 64 | tuning knob | Total pixel height of usable fill area. Default: `64` |

**Expected output ranges:**

| Scenario | chaos_display_px | social_display_px | Total filled |
|----------|-----------------|------------------|-------------|
| COLD (fresh level, no actions) | 0 | 0 | 0 / 64px |
| After 5 REACTING events (chaos ≈ 0.42) | `floor(0.42/0.55 × 35) = 26px` | 0 | 26 / 64px |
| HOT plateau (chaos = 0.55) | `floor(1.0 × 35) = 35px` | 0 | 35 / 64px |
| HOT + moderate goodwill (social = 0.20) | 35px | `floor(0.20/0.45 × 29) = 12px` | 47 / 64px |
| FEEDING (meter = 0.98, chaos = 0.55, social = 0.43) | 35px | `floor(0.43/0.45 × 29) = 27px` | 62 / 64px |
| Full (chaos = 0.55, social = 0.45) | 35px | 29px | 64 / 64px |

**Example — entering HOT state (chaos capped):**
```
chaos_fill = 0.55, chaos_fill_cap = 0.55, chaos_zone_pixel_height = 35
display_chaos_fill approaches 0.55 over fill_chase frames
chaos_display_px = floor(0.55 / 0.55 * 35) = floor(1.0 * 35) = 35px

social_fill = 0.0, social_display_px = 0

Bowl shows: bottom 35px indigo (packed), top 29px empty (with sparkle animation).
```

**Example — levity rub raises social fill visibly:**
```
# Before rub (TIPPING approaching): social_fill = 0.30
social_display_px = floor(0.30 / 0.45 * 29) = floor(19.3) = 19px

# After charm rub in VULNERABLE with levity (goodwill +0.135 → social_fill +0.081):
# social_fill → 0.30 + 0.081 = 0.381
# display value chases at fill_chase_speed = 4.0; after 0.25s:
# display_social_fill ≈ 0.38
social_display_px = floor(0.38 / 0.45 * 29) = floor(24.5) = 24px

# Net visual change: 5px rise in 0.25s — clearly visible, clearly meaningful.
```

### 4.2 Draw Order

Each frame, the widget draws in this order:
1. **Fill background**: the bowl interior (charcoal `#1A1520`), clipped to fill area mask
2. **Chaos fill rectangle**: solid `chaos_display_px` tall, from bottom of fill area upward, with noise texture overlay
3. **Social fill rectangle**: solid `social_display_px` tall, from `chaos_zone_pixel_height` upward (NOT from chaos_display_px — the social zone always starts at the same y position, aligned with the cap)
4. **Cap line**: 1-pixel line at the chaos/social boundary — always drawn at the fixed cap position, regardless of fill level
5. **Sparkle particles** (if CONVERGING or above): 1-pixel dots drawn at current frame positions within social zone bounds
6. **Bowl frame sprite**: composited on top of all fill layers, providing the bowl visual frame
7. **Inner glow overlay** (if FEEDING): amber overlay sprite, 3-frame fade-in

**Note on social fill draw position**: The social fill rectangle always originates from
the fixed cap line position (y = `chaos_zone_pixel_height` pixels from the bottom of the
fill area), not from the current chaos fill height. This means when chaos_display_px
is below 35 (e.g., during WARMING), there is a gap between the chaos fill top and the
social fill bottom — filled by the charcoal background. This gap correctly communicates
"there is more room in the chaos zone too." The social fill zone is spatially distinct
from the chaos fill zone always.

### 4.3 State Transition Logic

```
# Called when System 13's meter_state changes
func on_meter_state_changed(old_state: MeterState, new_state: MeterState) -> void:
    emit_signal("meter_state_changed", old_state, new_state)
    match new_state:
        MeterState.HOT:
            set_chaos_noise_cycle_rate(FAST)  # 4-6 frames per cell (vs. 8-12 in WARMING)
        MeterState.CONVERGING:
            begin_chaos_texture_transition(TURBULENT, PACKED, 4)  # 4 frames
            set_cap_line_bright(true)
            start_social_sparkle_animation()
            set_sparkle_density(sparkle_density_hot)
            set_sparkle_cycle_period(sparkle_cycle_period_hot)
        MeterState.TIPPING:
            set_sparkle_cycle_period(sparkle_cycle_period_tipping)
        MeterState.FEEDING:
            begin_bowl_glow_fade_in(3)  # 3 frames
            start_feeding_vibration()
            set_sparkle_density(sparkle_density_feeding)
            set_sparkle_cycle_period(sparkle_cycle_period_feeding)
        MeterState.COLD, MeterState.WARMING:
            set_chaos_noise_cycle_rate(NORMAL)  # 8-12 frames per cell
            begin_chaos_texture_transition(PACKED, TURBULENT, 4)
            set_cap_line_bright(false)
            stop_social_sparkle_animation()
            stop_bowl_glow()
            stop_feeding_vibration()
```

---

## 5. Edge Cases

**Q: `chaos_fill` decreases below `chaos_fill_cap` during play (e.g., if a future system
reduces chaos_fill). How does the UI respond?**

A: The fill chase interpolation handles decreasing values identically to increasing
values. `display_chaos_fill` chases downward at the same `fill_chase_speed`. The chaos
fill drains smoothly. As of System 13 §3.1 rule 3, `chaos_fill` is cumulative and
non-decreasing within a session — so this case cannot occur in MVP. However, if System
13 ever introduces decay, the UI handles it correctly without modification.

**Q: `social_fill` drops rapidly (e.g., NPC enters CLOSED_OFF, goodwill decays). Does
the social layer drain visibly?**

A: Yes — this is the intended behavior and a critical design signal. As goodwill decays
during CLOSED_OFF, `social_fill` decreases every frame. The fill chase interpolation
tracks this decrease smoothly. The player sees the amber layer recede in real time. This
is the meter retreat described in System 13 §5 — the UI communicates the penalty
without any text or popup. The player watches the bowl drain and understands: something
went wrong.

**Q: `meter_state` skips states — e.g., jumps from COLD directly to CONVERGING. Does
the UI handle state skips?**

A: State transitions fire for each new state value, regardless of how many states were
skipped. If `meter_state` changes from COLD to CONVERGING in one frame (hypothetically —
this cannot happen with continuous fill, but could if a debug tool forces a value), the
transition logic for CONVERGING fires. The intermediate visual states (WARMING → HOT)
are not triggered. The chaos texture transition may not play. This is acceptable —
debug-forced states are not player-facing, and natural play cannot skip states because
fill is continuous.

**Q: `meter_value` hits 1.0 but FED has not yet triggered (NPC in non-checked state —
see System 13 §5). The UI shows FEEDING state. Is this correct?**

A: Yes. The UI's contract is to display `meter_state` as provided by System 13. System
13 §4.7 assigns `MeterState.FEEDING` when `meter_value >= 0.95`. The UI shows FEEDING
state whenever System 13 says FEEDING — regardless of whether the NPC has fired the
FED cutscene yet. This is correct behavior: the player's progress is real, FED is
genuinely imminent, and the FEEDING visual signal accurately represents that. The UI
does not need to know about NPC internal state.

**Q: Both NPCs are active, one enters CLOSED_OFF while the other has high goodwill. The
meter drops slightly but not to HOT. Which state does the UI show?**

A: System 13 computes `meter_state` from `meter_value` (the combined fill) and provides
it each frame. System 23 displays exactly that state. If the combined fill remains above
0.55 (e.g., one NPC at high goodwill partially compensates), the UI might show CONVERGING
even while one NPC's goodwill is draining. This is correct — the player's aggregate
progress is still in CONVERGING. The NPC's body language (CLOSED_OFF visual tier) is the
signal for "this specific NPC is unavailable." The meter shows overall progress.

**Q: Level start — `level_chaos_baseline > 0` (e.g., Vet's Office at 0.15). The bowl
starts partially filled. Does the chaos fill animate from 0 up to 0.15, or does it
snap to 0.15 instantly?**

A: On level initialization, `display_chaos_fill` is set directly to `level_chaos_baseline`
without chase interpolation — it begins at the correct value. No "fill animation from
empty to baseline" plays on level start. The bowl appears at baseline fill on the first
rendered frame of the level. This avoids a misleading "chaos is building" signal before
the player has done anything. The initial fill is ambient context, not earned progress.

**Q: The player minimizes the window or alt-tabs. Does the meter UI continue running?**

A: Godot pauses processing by default when the window loses focus (depending on project
settings). System 23 follows the engine's pause behavior. When the window regains focus,
`display_chaos_fill` and `display_social_fill` snap to current values (not resume from
where they were), preventing a visible "catching up" animation on window focus.
Implementation: on `_notification(NOTIFICATION_WM_FOCUS_IN)`, set `display_chaos_fill =
chaos_fill` and `display_social_fill = social_fill` directly before the next frame draws.

**Q: Widget rendering at 1× display scale (720×540 native — minimum spec). Is a 32×96px
widget legible?**

A: At 1× scale, the widget renders at its native 32×96px. This is approximately 1.3%
of viewport width and 17.8% of viewport height — visible but not dominant. The fill
layers at 16px wide are the minimum for legibility in nearest-neighbor pixel art.
QA must verify legibility at 1× scale as part of acceptance testing (AC-UI-09).
If 1× is deemed too small, the widget can be scaled 2× independent of the display
scale — but this must be an explicit design decision, as it doubles the screen
footprint at 1× display mode.

**Q: Player reaches overwhelm FED on their first playthrough, before ever seeing the
FEEDING visual state. Does the anti-signal still communicate?**

A: On a first overwhelm win, the player has no reference for what the FEEDING state looks
like — the absence of a signal they've never witnessed communicates nothing directly.
However, the half-full bowl at level end still reads as "incomplete" — the bowl metaphor
inherently suggests fullness is the goal, and a half-full bowl at the end of a level is
visually unresolved regardless of prior exposure. The training level (Apartment) has the
lowest overwhelm thresholds (Michael: 8 events), making pure-chaos overwhelm slow enough
that players are likely to discover charm interactions before accumulating 8 chaos events.
If playtesting reveals that first-playthrough overwhelm wins feel ambiguous rather than
"wrong," the brief-surge alternative (see §3.5 flag) can serve as a retrospective teaching
signal — a compressed FEEDING flash before the cutscene that gives the player a glimpse
of what they'll recognize they're missing on subsequent overwhelm runs.

**Q: `chaos_fill_cap` or `social_fill_weight` are changed via tuning. Does the widget
adapt?**

A: `chaos_zone_pixel_height` and `social_zone_pixel_height` are computed from
`chaos_fill_cap` at widget initialization using `floor(fill_pixel_height * chaos_fill_cap)`.
If `chaos_fill_cap` is changed in the data file, the widget must be reinitialized for the
new value to take effect. This is correct behavior — tuning knob changes require a level
reload anyway. The invariant `chaos_fill_cap + social_fill_weight = 1.0` (System 13 §3.1)
means both zones always sum to `fill_pixel_height`. No pixel is wasted or double-counted.

---

## 6. Dependencies

### This System Depends On

| System | # | Direction | Interface Specification |
|--------|---|-----------|------------------------|
| **Chaos Meter** | 13 | UI reads Chaos Meter | **Reads every frame**: `meter_value: float [0.0–1.0]`, `chaos_fill: float [0.0–0.55]`, `social_fill: float [0.0–0.45]`, `meter_state: MeterState`. All reads are non-mutating. System 23 writes nothing to System 13. Godot implementation: exposed via a `ChaosMeterData` Resource or direct signal subscription. See §6.3 for the exact read contract. |
| **Viewport / Rendering Config** | 2 | UI conforms to viewport spec | All widget dimensions and positions are authored in world-space pixels at 720×540 native resolution. Widget is a CanvasLayer element. Nearest-neighbor filtering on all textures. No post-processing. |
| **Audio Event System** | (TBD) | UI signals Audio | System 23 emits `meter_state_changed(old_state, new_state)` signal. The Audio System subscribes and manages ambient layers and one-shot cues. System 23 never calls audio functions directly. The Audio Event System number is TBD (not yet GDD'd). |
| **Accessibility Settings** | (TBD) | UI reads prefs | Reads `accessibility_reduced_motion: bool` to disable sparkle and vibration animations. Reads audio volume settings (handled by the Audio System). |

### Systems That Depend On This

| System | # | Direction | What They Need |
|--------|---|-----------|----------------|
| **Feeding Cutscene System** | 19 | Cutscene reads UI state | System 19 may query whether the FEEDING visual state was active at the moment the FED transition fired — to determine if the overwhelm path (no FEEDING signal) vs. charm path (FEEDING signal was active) visual distinction should affect the cutscene intro frame. This is a Vertical Slice dependency — System 19 is Full Vision scope. For MVP, no dependency. |

### 6.3 Read Contract with System 13

System 23 reads the following values from System 13 on every `_process` frame:

```gdscript
# These are the only values System 23 reads from System 13
var meter_value: float   # 0.0–1.0 — combined meter (informational only; UI uses chaos_fill + social_fill directly)
var chaos_fill: float    # 0.0–chaos_fill_cap — chaos component
var social_fill: float   # 0.0–social_fill_weight — live social component
var meter_state: MeterState  # 6-state enum from System 13 §4.7

# System 23 does NOT read from System 13:
# - chaos_event_count
# - NPC goodwill values
# - feeding_path_type
# - NPC names or identities
# - Any NPC behavioral state
```

The read is a direct property read on the `ChaosMeter` node (or equivalent). No method
calls, no signals for the fill values — just property reads each frame.

### 6.4 Bidirectional Notes

System 23 is a terminal consumer. It writes nothing. No other system reads values from
System 23 (until System 19 in Vertical Slice scope). There are no circular dependencies.

**Frame execution order** (from System 12 GDD §6, Circular Dependency Resolution):
Input → Traversal → NPC → Social → **Chaos Meter (13) → Chaos Meter UI (23)**

System 23 reads the fully-updated values from System 13 at the end of each frame, after
all game logic has run. This means the displayed fill always reflects the current frame's
state — no 1-frame lag between game logic and display.

---

## 7. Tuning Knobs

All knobs are in `assets/data/chaos_meter_ui_config.tres`. No hardcoded values in
implementation.

### Fill Display Knobs

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `fill_chase_speed` | feel | `4.0` | `1.0–12.0` | Fill moves toward target value faster; more responsive, less "fluid" | Fill lags behind target value more; smoother motion, but feedback delay increases |
| `fill_pixel_height` | feel | `64` | `48–80` | Taller fill area; more visual precision in fill height | Shorter fill area; less visual precision; may affect legibility |
| `chaos_zone_pixel_height` | curve | `floor(fill_pixel_height * chaos_fill_cap)` | Must equal `floor(fill_pixel_height * chaos_fill_cap)` | — | — |
| `social_zone_pixel_height` | curve | `fill_pixel_height - chaos_zone_pixel_height` | Must equal `fill_pixel_height - chaos_zone_pixel_height` | — | — |

> ⚠️ `chaos_zone_pixel_height` and `social_zone_pixel_height` are **derived from**
> System 13's `chaos_fill_cap`. They must be updated any time System 13's cap is
> changed. Hardcoding them independently of `chaos_fill_cap` is a bug.

### Widget Layout Knobs

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `meter_margin_right` | feel | `8` | `4–20` | Widget moves further left from screen right edge | Widget closer to right edge; may clip |
| `meter_margin_bottom` | feel | `8` | `4–20` | Widget moves further up from screen bottom edge | Widget closer to bottom edge; may clip |
| `meter_widget_width` | feel | `32` | `24–40` | Wider widget; more prominent; check art asset size | Narrower widget; less legible at 1× scale |
| `meter_widget_height` | feel | `96` | `80–112` | Taller widget; check art asset size | Shorter widget; smaller fill area |

### Animation Timing Knobs

| Knob | Category | Default | Safe Range | Effect of Increase | Effect of Decrease |
|------|----------|---------|------------|-------------------|-------------------|
| `chaos_texture_transition_frames` | feel | `4` | `2–8` | Slower turbulent→packed texture crossfade | Faster crossfade; snappier |
| `sparkle_cycle_period_hot` | feel | `48` | `24–96` | Slower sparkle cycle in HOT state; more subtle | Faster sparkle; more active; could feel distracting |
| `sparkle_cycle_period_tipping` | feel | `32` | `16–48` | Slower sparkle in TIPPING | Faster sparkle; high intensity |
| `sparkle_density_hot` | feel | `3` | `1–6` | More simultaneous sparkles in HOT; more active invitation | Fewer sparkles; more subtle |
| `sparkle_density_feeding` | feel | `7` | `6–12` | More sparkles in FEEDING; higher escalation | Fewer; calmer FEEDING signal |
| `sparkle_cycle_period_feeding` | feel | `24` | `12–36` | Slower sparkle cycle in FEEDING; less intense | Faster sparkle; maximum escalation |
| `feeding_glow_fade_frames` | feel | `3` | `2–6` | Slower glow fade-in on FEEDING entry | Faster glow; punchier |
| `feeding_vibration_interval_frames` | feel | `16` | `8–24` | Less frequent vibration pulse | More frequent; more intense anticipation |

### Color Knobs

> No formal safe ranges — colorblind compliance depends on texture/position/motion
> differentiation, not color values. See §3.10. Tune within ±20% luminance/saturation.

| Knob | Default | Notes |
|------|---------|-------|
| `color_chaos_fill_warm` | `#2D1F5E` | Active chaos fill (WARMING). Deep indigo. |
| `color_chaos_fill_packed` | `#221848` | Packed chaos fill (HOT+). Slightly darker/denser. |
| `color_social_fill` | `#E8A042` | Amber. Warm food-tone. |
| `color_sparkle` | `#FFD166` | Bright amber sparkle. |
| `color_cap_line_default` | `#C8B090` | Warm cream separation line. |
| `color_cap_line_bright` | `#F5E6C8` | Brightened cap line (CONVERGING state). |
| `color_bowl_glow` | `#FFD166` | Inner bowl glow (FEEDING). |
| `color_bowl_interior` | `#1A1520` | Background inside fill area. |

All color knobs are safe to tune within ±20% luminance/saturation without breaking
colorblind accessibility — the texture differentiation between chaos and social fill
remains the primary accessibility channel regardless of color values.

---

## 8. Acceptance Criteria

All criteria are verifiable by a QA tester. A **debug overlay** is required for
numeric verification — it should display `chaos_fill`, `social_fill`, `meter_value`,
and `meter_state` from System 13 alongside the rendered widget.

---

**AC-UI-01: Chaos fill rises when chaos events fire**
- [ ] Trigger a REACTING event on Michael; confirm `chaos_fill` increases in debug overlay
- [ ] Confirm `chaos_display_px` increases within `1.0 / fill_chase_speed` seconds (default: 0.25s)
- [ ] Confirm the visible chaos fill layer (bottom indigo layer) rises proportionally
- [ ] Confirm rise is smooth (no instant snap) — the fill chases the value at chase speed

---

**AC-UI-02: Social fill rises with goodwill and falls with goodwill loss**
- [ ] Build Michael's goodwill via charm; confirm `social_fill` increases and amber
      layer rises visibly in the widget
- [ ] Trigger a CLOSED_OFF state; allow goodwill to decay; confirm `social_fill`
      decreases and amber layer visibly recedes over time
- [ ] Confirm social fill tracks `social_fill` from System 13 within 1 frame (no
      lag greater than `1.0 / fill_chase_speed` seconds)

---

**AC-UI-03: Chaos fill caps at 55% of fill area and social fill starts from correct position**
- [ ] Force `chaos_fill = 0.55` via debug; confirm `chaos_display_px = 35` (or the
      correct `floor(fill_pixel_height * chaos_fill_cap)` value)
- [ ] Confirm chaos fill does not grow beyond 35px regardless of additional chaos events
- [ ] Confirm the social fill zone always starts at the cap line position (y = 29px
      from fill top), NOT from the current chaos fill height
- [ ] Confirm the cap line is visible between the two zones at all times when both
      zones have any fill

---

**AC-UI-04: CONVERGING state visual changes are correct (chaos capped)**
- [ ] Enter CONVERGING state (chaos_fill = 0.55, meter_state = CONVERGING); confirm:
  - [ ] Chaos fill texture transitions from animated noise to static packed noise within 4 frames
  - [ ] Cap line color brightens to `#F5E6C8`
  - [ ] Social zone sparkle animation begins cycling in the empty social fill area
  - [ ] Bowl frame color does NOT change (remains `#3A3028`)
  - [ ] No text, no arrows, no tutorial appears
- [ ] Separately: enter HOT state (chaos_fill ≈ 0.42, meter_state = HOT); confirm:
  - [ ] Chaos noise cycle rate increases (faster animation, NOT packed/static)
  - [ ] Cap line does NOT brighten
  - [ ] No sparkle animation starts

---

**AC-UI-05: Additional chaos events in CONVERGING state do not move the chaos fill**
- [ ] With meter in CONVERGING state (`chaos_fill = 0.55`), trigger 5 additional REACTING events
- [ ] Confirm `chaos_display_px` remains at 35px throughout
- [ ] Confirm the chaos fill visual remains static (packed texture, no movement)
- [ ] Confirm no visual signal suggests the meter is progressing

---

**AC-UI-06: FEEDING state visual escalation is correct**
- [ ] Force `meter_state = FEEDING` via debug; confirm:
  - [ ] Bowl inner glow overlay fades in within 3 frames
  - [ ] Sparkle density increases (≥ 6 sparkles active simultaneously)
  - [ ] Bowl vibration begins (1px up/down pulse every 16 frames)
  - [ ] Audio event `meter_state_changed(TIPPING, FEEDING)` is emitted (confirm in
        debug signal log)
  - [ ] No red color appears anywhere in the widget

---

**AC-UI-07: Chaos overwhelm path does NOT trigger FEEDING visual**
- [ ] Set up overwhelm scenario: force `chaos_event_count = 8` on Michael with
      `meter_value ≈ 0.55` (HOT state) and Michael in checked state
- [ ] Confirm FED triggers (level ends or feeding cutscene begins)
- [ ] Confirm: at no point during the overwhelm sequence did `meter_state` reach FEEDING
- [ ] Confirm: bowl glow never appeared, bowl vibration never started
- [ ] Confirm: meter was in HOT visual state when the level transition fired

---

**AC-UI-08: Fill display initializes to level_chaos_baseline without animation**
- [ ] Load a level with `level_chaos_baseline = 0.15` (e.g., Vet's Office)
- [ ] Confirm: on the FIRST rendered frame, `chaos_display_px` already reflects 0.15
      (approximately `floor(0.15/0.55 × 35) = 9px`)
- [ ] Confirm: no fill-from-zero animation plays on level start; bowl starts at baseline

---

**AC-UI-09: Widget is legible at 1× display scale**
- [ ] Set display to 1× scale (720×540 native or equivalent)
- [ ] Run through COLD → WARMING → HOT → CONVERGING → TIPPING → FEEDING state sequence
- [ ] Confirm: QA tester can distinguish chaos fill (bottom) from social fill (top)
      without debug overlay, at 1× scale, at 60cm viewing distance
- [ ] Confirm: cap line is visible between zones at 1× scale when both fills are partially active
- [ ] Confirm: sparkle animation is visible in social zone during CONVERGING state at 1× scale

---

**AC-UI-10: Colorblind accessibility — texture distinction is primary channel**
- [ ] Run widget through all states with a greyscale filter applied (simulate colorblind)
- [ ] Confirm: chaos fill and social fill are distinguishable by texture alone
      (coarse noise vs. smooth with sparkles)
- [ ] Confirm: HOT plateau is identifiable (bottom zone static, top zone animated)
      without relying on color difference
- [ ] Confirm: cap line is visible in greyscale

---

**AC-UI-11: Reduced motion mode disables animations, preserves fill accuracy**
- [ ] Enable `accessibility_reduced_motion = true` in settings
- [ ] Trigger HOT → CONVERGING transition; confirm: sparkle animation does NOT start
- [ ] Force FEEDING state; confirm: bowl vibration does NOT start
- [ ] Confirm: fill heights (`chaos_display_px`, `social_display_px`) still update
      correctly with reduced motion enabled
- [ ] Confirm: cap line brightening on CONVERGING entry DOES still occur (static color
      change; not an animation)

---

**AC-UI-12: Audio signals fire on state transitions**
- [ ] Monitor audio signal bus in debug; run through all 6 state transitions in sequence
- [ ] Confirm: `meter_state_changed(old, new)` emits on each transition
- [ ] Confirm: entering CONVERGING fires `chaos_meter_cap_reached` one-shot cue signal
- [ ] Confirm: entering FEEDING fires `chaos_meter_feeding_imminent` one-shot cue signal
- [ ] Confirm: no audio signals fire when fill values change without a state transition
      (e.g., social_fill increasing within CONVERGING state)

---

**AC-UI-13: Widget does not modify any game state**
- [ ] Audit System 23 implementation: confirm zero writes to System 13, NpcState,
      or any other game-state object
- [ ] Confirm System 23 reads are all property reads (no method calls with side effects)
- [ ] Confirm all signals System 23 emits are display signals only (audio, nothing else)

---

## Resolved Questions (Session 009)

| Question | Decision | Session |
|----------|----------|---------|
| Chaos overwhelm visual: abrupt cut from HOT vs. brief surge? | **Abrupt cut accepted.** Ready to validate in playtesting. | 009 |
| Diegetic vs. HUD bowl? | **Both.** HUD corner bowl for MVP (this spec). Diegetic world bowls added post-MVP — NPCs see empty bowls on the ground and bowls appear in levels after successful feeding per NPC. NPCs noticing empty bowls informs their behavior. See DI-003 below. | 009 |
| BONNIE visual reaction at FEEDING? | Out of scope for System 23 — Traversal/Animation System domain. Flag for vertical slice. | 009 |

## Open Questions

| Question | Recommendation | Priority |
|----------|---------------|----------|
| Audio one-shot for entering CONVERGING: "thud/thwump" tone — confirm with audio-director that this does not accidentally read as a negative sound (penalty signal). The CONVERGING state is not a punishment — it signals chaos is full and social is now live. | Flagged for audio-director review when audio direction sprint begins. | Pre-implementation audio review |

---

## DI-003 — Deferred Design Idea: Diegetic Food Bowls

**Source**: User decision, Session 009
**Scope**: Post-MVP (requires level design, NPC behavior, and environmental art systems)

The HUD food bowl (this spec) serves as the primary progress indicator for MVP. Post-MVP,
the design expands to include **physical food bowls in the game world**:

- Each level contains one or more visible empty food bowls on the ground
- When an individual NPC successfully feeds BONNIE, their associated bowl appears filled
  in the environment
- NPCs can **notice** empty bowls on their own — an empty bowl in their line of sight
  informs their behavior (e.g., Michael seeing an empty bowl might increase his likelihood
  of feeding BONNIE even at lower overwhelm thresholds)
- This creates a secondary environmental storytelling layer: the bowls are physical
  evidence of progress that persists in the world

**Dependencies**: Level Design (System 20+), NPC Perception (System 9 extensions),
Environmental Art pipeline, Feeding Cutscene System (System 19).
**Priority**: Vertical Slice or later. Do not implement during MVP sprint.
