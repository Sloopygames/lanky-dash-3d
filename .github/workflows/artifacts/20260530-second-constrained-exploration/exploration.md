# Exploration Artifact

Task id: 20260530-second-constrained-exploration

## Objective

Run a second constrained exploration pass for all target profiles without claiming convergence:
- Max emotional intensity
- Max strategic depth
- Max replayability with lowest implementation risk

## Focus Extension: Style, Rare Events, and Emotional Amplification

### Orthogonal novelty dimensions

1. Visual abstraction level
- Flat iconographic, cel-shaded toy, stylized realism, collage surreal, neon vector minimal.
2. Surface energy density
- Calm readable lanes to high-noise kinetic VFX and texture turbulence.
3. Rhythm pressure profile
- Steady groove, wave burst pacing, and sudden spike windows.
4. Arithmetic semantics expression
- Gates as signs, creatures, graffiti glyphs, or diegetic machinery.
5. Boss emotional framing
- Comic relief, terror pressure, heroic duel, absurd spectacle.
6. Audio architecture
- Melody-led uplift, kick-driven rush, breakbeat syncopation, crowd-hype stabs.
7. Event rarity topology
- Frequent micro-surprises, uncommon tactical twists, ultra-rare spectacle events.
8. Player agency locus
- Route planning agency, timing mastery agency, build/loadout agency.
9. World coherence strategy
- Hard biome boundaries, soft gradients, narrative contamination across transitions.
10. Recoverability curve
- Punishing collapse, clutch rescue windows, rebound multipliers.

### Exponential probability table for random and rare events

Use exponentially decaying rarity buckets to keep surprising moments memorable while preserving readability.

Parameters:
- p0 = 0.18 (common surprise baseline)
- Decay ratio r = 0.42
- Probability per opportunity: p_n = p0 * r^n

| Tier | Event class | p_n per event roll | Approx one hit every N rolls | Intended use |
|---|---|---:|---:|---|
| T0 | Common micro-variation | 0.180000 | 6 | lane graffiti swaps, tiny confetti pops |
| T1 | Uncommon detail burst | 0.075600 | 13 | bonus crowd cheer, brief palette pulse |
| T2 | Rare tactical twist | 0.031752 | 31 | temporary gate volatility window |
| T3 | Very rare spectacle | 0.013336 | 75 | mini meteor shower outside track |
| T4 | Ultra-rare explosive setpiece | 0.005601 | 179 | chain-reaction boss intro detonation |
| T5 | Mythic run-defining moment | 0.002352 | 425 | biome rupture with synchronized bass drop |

Operational notes:
- Run independent rolls at controlled hooks: biome entry, boss prelude, combo milestones, near-miss streaks.
- Add pity timer for T4/T5: guaranteed promotion by one tier if no T3+ event in M hooks.
- Add anti-cluster cooloff: after T3+, reduce T3+ chance for next K hooks to protect readability.

### Candidate trajectories (safe, hybrid, radical)

#### Trajectory S (safe): "Festival Runner"
- Novelty:
  - Adds high-frequency joyful details and occasional fireworks without changing core lane logic.
- Player impact:
  - More delight per minute, better emotional uplift, low frustration increase.
- Coherence with identity:
  - Strong. Arithmetic growth and boss smash stay central.
- Implementation risk:
  - Low.
- Governance re-audit needs:
  - Medium: verify visual clutter ceilings and frame-time impact.

Key additions:
- Happy-hardcore light pass (higher BPM lead layer, cleaner kicks, brighter supersaw chords).
- T0-T2 event usage only in first release slice.
- Smooth biome transition blending over 6-10s with lane readability lock.

#### Trajectory H (hybrid): "Euphoria-Then-Chaos"
- Novelty:
  - Contrasts bright uplifting sections with rare coherent explosive ruptures.
- Player impact:
  - Strong memorable spikes, stronger stream/share moments, clutch storytelling.
- Coherence with identity:
  - Strong if rupture windows preserve lane telegraphs.
- Implementation risk:
  - Medium.
- Governance re-audit needs:
  - High: fairness under rare events, deterministic seed consistency.

Key additions:
- T0-T4 enabled.
- Rare explosive events tied to mastery triggers (high combo, near-boss threshold).
- Boss intros gain synchronized audiovisual shock moments.

#### Trajectory R (radical): "Mythic Collapse Ladder"
- Novelty:
  - Ultra-rare world-state fractures with temporary rule distortions and asymmetrical reward windows.
- Player impact:
  - Massive memorability and emergent narrative, plus heightened risk of overwhelm.
- Coherence with identity:
  - Medium unless distortion windows are short and arithmetic goals remain legible.
- Implementation risk:
  - High.
- Governance re-audit needs:
  - Critical: identity drift, accessibility, motion comfort, exploit prevention.

Key additions:
- Full T0-T5 table enabled with strict cooloffs.
- Temporary "fracture" modifiers (lane gravity wobble, gate sign inversion feints).
- Event-driven boss variants that alter one mechanic only.

### Wide art-style exploration set

1. Toybox Pop Clay
- Rounded geo, hand-painted gradients, chunky outlines, playful debris.
2. Neo-Arcade Vector
- Clean geometric lanes, emissive edge lines, minimal but punchy color blocks.
3. Sticker Bomb Collage
- Layered decals, cutout textures, animated paper tears, absurd humor accents.
4. Bubblegum Mecha
- Cute industrial gates, candy alloy surfaces, mascot hazard bots.
5. Hyperflat Sports Broadcast
- Bold overlays, instant replays for boss smashes, dynamic lower-third stats.
6. Dream Pastel Vapor Toy
- Soft fog, iridescent rails, gentle bloom with high contrast gates.
7. Carnival Night Rave
- LED rigs, confetti cannons, crowd silhouettes, stage-like boss arenas.
8. Inked Comic Impact
- Halftone shadows, speed lines, freeze-frame impact cards.
9. Biolum Jungle Synth
- Organic neon flora, spores, glowing arithmetic glyphs.
10. Retro Futurist Chrome Pop
- Reflective candy chrome, checker floors, synth race nostalgia.
11. Glitch Graffiti Metro
- Spray textures, scanline glitches, rebellious math signage.
12. Storybook Monster Parade
- Whimsical creature hazards, hand-inked outlines, fairy-tale palette.

### Prioritized top-5 styles for direct implementation

Selection criteria:
- High novelty per cost.
- Strong fit with happy-hardcore direction.
- Clear lane/gate readability.
- Compatible with existing cute 3/4 framing and current UI language.

1. Carnival Night Rave
- Why top:
  - Best fit for happy-hardcore energy and explosive event framing.
- Emotional target:
  - Joyful hype and festival adrenaline.
- Replayability vector:
  - Event stage variations and crowd-reactive moments.

2. Toybox Pop Clay
- Why top:
  - Maximum charm and broad appeal with low cognitive burden.
- Emotional target:
  - Delight, attachment, playful triumph.
- Replayability vector:
  - Collectible prop sets and biome toy themes.

3. Neo-Arcade Vector
- Why top:
  - Best readability for high-speed arithmetic choices.
- Emotional target:
  - Flow-state confidence and precision mastery.
- Replayability vector:
  - Colorway packs and rule-set variants.

4. Inked Comic Impact
- Why top:
  - Makes boss-smash moments iconic and screenshot-worthy.
- Emotional target:
  - Heroic impact and exaggerated catharsis.
- Replayability vector:
  - Procedural panel frames for major events.

5. Bubblegum Mecha
- Why top:
  - Adds personality depth without destabilizing core mechanics.
- Emotional target:
  - Empowered playful aggression.
- Replayability vector:
  - Hazard bot families and boss archetype remixes.

### Smooth transitions between levels and styles

Transition stack:
1. Palette interpolation
- Use 3-phase lerp: sky/fog first, props second, gate accent last.
2. Geometry handoff zones
- 120-180m "blend corridors" where both biome prop grammars coexist.
3. Audio stem crossfades
- Kick and bass remain stable; lead and FX morph over 8-16 bars.
4. Event gating
- Disable T3+ events during first 4s of transitions to preserve onboarding clarity.
5. Camera continuity
- Keep camera profile fixed during transitions; no simultaneous camera and style jumps.

### Happy-hardcore music direction (directable in current procedural audio)

Core spec:
- BPM target: 168-178.
- Rhythmic base: four-on-the-floor kick with offbeat open hat.
- Bass: rolling octave bass with sidechain ducking.
- Harmony: bright major/minor modal interchange, short euphoric chord loops.
- Leads: supersaw/pluck hooks with octave doubles.
- FX: risers, uplifters, snare builds before boss impacts.

Adaptive mapping:
- Normal segments: full groove at medium density.
- Pulse/clutch windows: add ride layer and lead arpeggio intensity.
- Boss prelude: HPF sweep + snare rush + vocal-chop style synth stab.
- Smash success: one-bar "euphoria hit" chord burst.
- Failure: quick harmonic drop, then immediate hopeful rebuild motif.

### Random details and rare explosive events

Micro-random details (T0-T1):
- Billboard jokes that reflect recent gate choices.
- Tiny spectator mascots doing contextual cheers.
- Lane-edge props that react to near misses.

Rare explosive events (T3-T5):
- Chain Firework Spine:
  - Trackside fireworks launch in arithmetic pattern matching recent combo.
- Boss Arena Blackout Flash:
  - 0.7s blackout then neon silhouette reveal with bass slam.
- Biome Fracture Bloom:
  - Ground crack emits color wave; next 8s has altered gate silhouettes only.
- Meteor Confetti Rain:
  - Non-lethal sky event synchronized to chorus drop.

Safety constraints for explosive events:
- Never hide active hazard telegraph geometry.
- Never alter collision boxes during spectacle.
- Cap simultaneous post-processing passes per quality tier.

### Emotional targets, emergent opportunities, replayability vectors

Emotional targets:
- Uplifted momentum.
- Clutch relief.
- Dominance catharsis on smash.
- Rare awe during spectacle tiers.

Emergent behavior opportunities:
- Players route intentionally to farm event-trigger states.
- Near-miss specialists create "risk artist" playstyle.
- Combo hunters learn transition timing to chain T2-T3 opportunities.

Replayability vectors:
- Style rotation with continuity-preserving transitions.
- Event memory economy: players chase mythic-tier moments.
- Variant deck + style pairings produce fresh yet coherent runs.

### Governance re-audit recommendations

Audit required:
1. Performance and comfort envelope under style/event stacking.
2. Determinism check when exponential rolls interact with adaptive triggers.
3. Readability audit during transition corridors and explosive events.
4. Fairness audit on event-triggered reward multipliers.

Severity guidance:
- Safe trajectory S: Medium gate.
- Hybrid trajectory H: High gate.
- Radical trajectory R: Critical gate.

## Constraints

- Preserve core identity: fast 3-lane arithmetic size-runner with hazard dodge and boss smash payoff.
- Stay admissible to current repo systems and release context.
- Generate safe, hybrid, and radical trajectories per profile.
- Include escalation paths, novelty, player impact, coherence rationale, implementation risk, and governance re-audit needs.
- Produce cross-profile synthesis and a 30-day implementation sequence with checkpoints.

## Candidate Solution

### A) Emotional Intensity profile candidates

#### A1 Safe trajectory: "Pressure Crescendo"
- Core loop deltas:
  - Add short "danger pulses" every 20-30s: brief speed spike, denser hazards, brighter VFX/audio stingers.
  - Add near-miss scoring burst (hazard pass within a small lateral threshold).
  - Add boss approach "heartbeat" ramp (camera bob + bass pulse) in final 5s pre-impact.
- Escalation path options:
  - Option 1: fixed cadence pulses by distance.
  - Option 2: adaptive pulses triggered when player has high combo or overcharge.
  - Option 3: biome-specific pulse signatures (ice = slippery-feel camera drift, lava = heavy hit-pause emphasis).
- Novelty:
  - Emotional pacing layer without changing lane/math fundamentals.
- Player impact:
  - Higher tension variance, clearer "calm vs panic" rhythm, stronger boss payoff anticipation.
- Coherence rationale:
  - Fits existing speed-up, hit-pause, screen shake, overcharge, and telegraph systems.
- Implementation risk:
  - Low.
- Governance re-audit needs:
  - Verify readability during spikes (telegraph integrity).
  - Verify mobile comfort with camera/screen effects limits.

#### A2 Hybrid trajectory: "Clutch State Drama"
- Core loop deltas:
  - Introduce "clutch state" when POWER is near next boss threshold (within configurable margin).
  - In clutch state, gate distribution biases toward high-volatility choices (+big, -big).
  - Successful boss smash from clutch grants cinematic reward window (slow-mo chain smash bonus).
- Escalation path options:
  - Option 1: clutch only before boss segments.
  - Option 2: clutch can trigger in normal segments after repeated hazard hits.
  - Option 3: stacked clutch tiers with risk multipliers.
- Novelty:
  - Dynamic drama tied directly to arithmetic growth target.
- Player impact:
  - Strong comeback fantasy and memorable "just enough" runs.
- Coherence rationale:
  - Extends existing overcharge/risk-reward mechanics and boss thresholds.
- Implementation risk:
  - Medium.
- Governance re-audit needs:
  - Validate fairness of adaptive gate bias.
  - Check anti-snowball safeguards and deterministic daily-seed consistency.

#### A3 Radical trajectory: "Rage Corridor"
- Core loop deltas:
  - Trigger a short single-lane lock corridor after major failure (e.g., big shrink hit).
  - Player can only influence timing/mini-dodge windows while rebuilding POWER through timed micro-gates.
  - Corridor exits into immediate boss or mini-boss "revenge smash" attempt.
- Escalation path options:
  - Option 1: corridor appears once per run.
  - Option 2: appears per biome finale.
  - Option 3: player-opt-in by taking a volatile gate.
- Novelty:
  - Temporary control-grammar break to produce high emotional compression.
- Player impact:
  - Extreme highs/lows; memorable failure-recovery stories.
- Coherence rationale:
  - Still arithmetic growth + dodge + smash, but with punctuated mode shift.
- Implementation risk:
  - High.
- Governance re-audit needs:
  - Confirm identity preservation under lane-lock mode.
  - Validate accessibility and frustration thresholds.

### B) Strategic Depth profile candidates

#### B1 Safe trajectory: "Route Signaling 2.0"
- Core loop deltas:
  - Improve pre-read of upcoming 2-3 gate/hazard interactions with subtle lane forecast indicators.
  - Add explicit expected-value hinting via iconography tiers (low/med/high swing risk).
  - Add mission-aware route highlights (non-forcing) that match current mission cards.
- Escalation path options:
  - Option 1: passive indicators only.
  - Option 2: indicators unlock with combo tiers.
  - Option 3: daily mode hides one indicator channel for mastery tension.
- Novelty:
  - Strategic clarity rather than new systems.
- Player impact:
  - Better planning quality, fewer "unreadable" losses, deeper lane commitment decisions.
- Coherence rationale:
  - Reinforces existing route-choice tension and mission systems.
- Implementation risk:
  - Low.
- Governance re-audit needs:
  - Ensure no over-assist that trivializes decisions.
  - Validate UI legibility on mobile.

#### B2 Hybrid trajectory: "Loadout Math"
- Core loop deltas:
  - Pre-run selection of one of three modifiers (examples: gate bias, hazard immunity window, combo retention on hit).
  - Modifier has explicit downside and interacts with mission/daily constraints.
  - In-run micro-upgrades appear at biome transitions (choose 1 of 2 branch perks).
- Escalation path options:
  - Option 1: one pre-run modifier only.
  - Option 2: modifier + one biome branch choice.
  - Option 3: rotating weekly modifier pool.
- Novelty:
  - Adds medium-horizon planning across run phases.
- Player impact:
  - Distinct build identities and stronger intentional play.
- Coherence rationale:
  - Leverages existing meta stars/achievements and biome progression.
- Implementation risk:
  - Medium.
- Governance re-audit needs:
  - Balance for dominant strategies.
  - Daily-seed parity/fairness across loadouts.

#### B3 Radical trajectory: "Two-Layer Economy"
- Core loop deltas:
  - Split growth into POWER (smash) and FOCUS (tactical resource from precision dodges).
  - FOCUS can be spent for lane-snap, gate reroll, or boss shield break timing.
  - Bosses require both threshold (POWER) and tactical spend windows (FOCUS).
- Escalation path options:
  - Option 1: FOCUS for one ability only.
  - Option 2: unlock second spend option after distance milestone.
  - Option 3: biome-specific spend mechanics.
- Novelty:
  - Converts reaction loop into resource timing strategy loop.
- Player impact:
  - High depth and replay theorycrafting; steeper cognitive load.
- Coherence rationale:
  - Keeps core smash fantasy while expanding decision surface.
- Implementation risk:
  - High.
- Governance re-audit needs:
  - Cognitive load audit for fast-run identity.
  - Rule clarity and tutorial burden assessment.

### C) Replayability low-risk profile candidates

#### C1 Safe trajectory: "Variant Deck Rotation"
- Core loop deltas:
  - Create lightweight weekly "variant deck" toggles that remix existing systems (hazard frequency weights, gate value bands, boss cadence knobs).
  - Keep deterministic daily seed but apply deck as a visible ruleset tag.
- Escalation path options:
  - Option 1: 3 curated decks/month.
  - Option 2: player vote between 2 decks weekly.
  - Option 3: seasonal deck bundles tied to cosmetics.
- Novelty:
  - Freshness through parameter orchestration, not new mechanics.
- Player impact:
  - Frequent novelty with high familiarity and low relearn cost.
- Coherence rationale:
  - Aligns with current seeded mode, anti-repeat spawn director, and tuning hooks.
- Implementation risk:
  - Low.
- Governance re-audit needs:
  - Verify deck combinations avoid impossible/degenerate runs.
  - Confirm score comparability policy per deck.

#### C2 Hybrid trajectory: "Objective Chains"
- Core loop deltas:
  - Extend mission cards into 2-step chains (complete A to reveal B for bonus multiplier).
  - Chain categories rotate daily: precision, aggression, efficiency.
  - Add run-summary "path badges" for completed chain archetypes.
- Escalation path options:
  - Option 1: one chain active at a time.
  - Option 2: parallel optional chain.
  - Option 3: streak bonus for multi-day chain completion.
- Novelty:
  - Structured short-term goals with minimal engine changes.
- Player impact:
  - More return motivation and run-to-run narrative.
- Coherence rationale:
  - Builds directly on existing mission/achievement systems.
- Implementation risk:
  - Low to medium.
- Governance re-audit needs:
  - Validate chain objectives do not force anti-fun play.
  - Ensure UI discoverability in fast HUD context.

#### C3 Radical trajectory: "Ghost Rival Seasons"
- Core loop deltas:
  - Add asynchronous ghost rivals (best route traces + key event markers).
  - Players race personal best ghost or curated seasonal rival ghosts.
  - Ghost challenges add optional rewards and streak ladders.
- Escalation path options:
  - Option 1: personal ghost only.
  - Option 2: seeded daily top ghost packs.
  - Option 3: seasonal boss gauntlet ghost league.
- Novelty:
  - Social-comparative replay without synchronous multiplayer.
- Player impact:
  - Strong repeat drive and mastery loop.
- Coherence rationale:
  - Compatible with daily seed and share summary direction.
- Implementation risk:
  - Medium to high (data model, replay fidelity, anti-cheat concerns).
- Governance re-audit needs:
  - Data integrity/provenance, fairness, and privacy handling.
  - Replay determinism validation.

### D) Cross-profile synthesis

#### Shared mechanics usable across all three profiles
- Telegraph quality layer:
  - Better timing/readability cues improve emotional spikes, strategic planning, and replay trust.
- Segment "state modifiers":
  - Reusable pipeline for pulse states, clutch states, and deck variants.
- Mission-aware scoring hooks:
  - Same event bus can feed intensity rewards (near-miss), strategic rewards (efficient routing), replay rewards (chains).
- Boss prelude package:
  - Unified pre-boss window for emotional build-up, tactical prep, and objective opportunities.

#### Conflicts and tradeoffs
- Intensity vs readability:
  - More effects/speed can erode strategic clarity.
- Strategic complexity vs run immediacy:
  - Added economies/loadouts may slow pick-up-and-play identity.
- Replay novelty vs implementation risk:
  - Ghost systems and major mode shifts increase technical governance burden.
- Determinism vs adaptive drama:
  - Dynamic biasing must not break daily-seed comparability.

#### Modular feature-pack strategy
- Ship together (high synergy, low risk):
  - Pack S1: Pressure Crescendo (A1) + Route Signaling 2.0 (B1) + Variant Deck Rotation (C1).
  - Why: all use existing systems with parameter/control-surface expansion.
- Ship separately (needs focused balancing):
  - Pack S2: Clutch State Drama (A2) + Objective Chains (C2) + Loadout Math (B2).
  - Why: all alter reward/decision curves and require anti-snowball plus dominance tuning.
- Isolate behind experimental flag:
  - Pack X: Rage Corridor (A3), Two-Layer Economy (B3), Ghost Rival Seasons (C3).
  - Why: high identity, fairness, and complexity risk.

#### 30-day implementation sequence with checkpoints
- Days 1-5 (Checkpoint C1: instrumentation readiness)
  - Add telemetry counters for near-miss, route forecast usage, deck ruleset attribution.
  - Define balancing guardrails and fail-safe toggles.
- Days 6-12 (Checkpoint C2: safe pack prototype)
  - Implement A1 + B1 + C1 as config-driven toggles.
  - Internal playtest for readability and pacing variance.
- Days 13-18 (Checkpoint C3: governance pre-audit)
  - Run deterministic seed regression set across baseline vs safe pack.
  - Tune telegraph thresholds and camera/VFX comfort limits.
- Days 19-24 (Checkpoint C4: hybrid pack slice)
  - Implement A2, C2, and B2 minimum slice with conservative defaults.
  - Evaluate score inflation, mission conflict rates, and loadout pick-rate concentration.
- Days 25-30 (Checkpoint C5: release candidate gate)
  - Lock S1 for release consideration.
  - Keep S2 behind opt-in flag pending governance signoff.
  - Produce audit targets and rollback plan.

### E) Governance re-audit recommendation matrix by candidate

| Candidate | Profile | Risk | Required Re-audit Focus | Suggested Severity Gate |
|---|---|---|---|---|
| A1 Pressure Crescendo | Emotional | Low | Telegraph readability, camera comfort, motion sensitivity | Medium |
| A2 Clutch State Drama | Emotional | Medium | Fairness of dynamic gate bias, anti-snowball behavior, seed comparability | High |
| A3 Rage Corridor | Emotional | High | Identity drift, frustration thresholds, accessibility | Critical |
| B1 Route Signaling 2.0 | Strategy | Low | Over-assist risk, decision trivialization, HUD clarity | Medium |
| B2 Loadout Math | Strategy | Medium | Dominant strategy emergence, loadout parity in daily mode | High |
| B3 Two-Layer Economy | Strategy | High | Cognitive load, tutorial burden, rules coherence under speed | Critical |
| C1 Variant Deck Rotation | Replayability | Low | Degenerate deck combos, leaderboard comparability policy | Medium |
| C2 Objective Chains | Replayability | Low-Med | Anti-fun objective forcing, scoring inflation | Medium |
| C3 Ghost Rival Seasons | Replayability | Med-High | Replay determinism, data integrity, privacy/fairness | High |

## Rationale

This pass prioritizes breadth with bounded risk: each profile includes a safe path for fast admissible gains, a hybrid path for moderate novelty, and a radical path to map upper-bound opportunity space. The cross-profile packs are arranged to maximize shared implementation surfaces and defer high-governance-risk candidates behind explicit gates.

## Assumptions

- Core gameplay stack in README and release notes is current and stable.
- Existing architecture can support additional config-driven tuning toggles.
- Governance status for this task is tracked explicitly in the paired artifact [audit.md](.github/workflows/artifacts/20260530-second-constrained-exploration/audit.md), and promotion uses that artifact only.
- No convergence is claimed; this is exploration input for governance.

## Affected Files/Components

- index.html systems likely touched in future implementation:
  - spawn director and gate/hazard pacing logic
  - boss threshold and prelude presentation logic
  - HUD indicators and mission surfaces
  - telemetry/debug panel event hooks
- game.json metadata may remain unchanged for this exploration phase.

## Risks

- Emotional and strategic additions can conflict on readability if stacked.
- Replay variants may fragment score comparability without policy.
- Radical candidates risk identity drift from fast-lane arithmetic runner DNA.
- Deterministic seed guarantees may be weakened by adaptive systems if not constrained.

## Unresolved Gaps

- Exact implementation cost and code hot spots were not estimated line-by-line.
- No empirical telemetry benchmarks are attached yet for checkpoint thresholds.
- Candidate pack S2 balancing model is still conceptual.
- Ghost replay feasibility depends on current simulation determinism quality.

## Evidence Annex

### Claim-to-source mapping

1. Missions/goal plumbing already exists and can support Objective Chains (C2).
- Source anchors:
  - [index.html](index.html#L977) mission pool
  - [index.html](index.html#L1032) mission progress tick
  - [index.html](index.html#L1047) mission roll logic

2. Spawn director and anti-repeat logic already exist and can support Variant Deck Rotation (C1).
- Source anchors:
  - [index.html](index.html#L1134) recent archetype memory
  - [index.html](index.html#L1135) archetype chooser
  - [index.html](index.html#L1178) row spawning entry

3. Boss telegraph and dodge windows already exist and can support Clutch/Boss-intensity tuning (A1/A2).
- Source anchors:
  - [index.html](index.html#L1232) boss type and telegraph setup
  - [index.html](index.html#L1352) boss resolve flow
  - [index.html](index.html#L1766) telegraph/dodge window updates

4. Telemetry/debug infrastructure exists for governance evidence collection.
- Source anchors:
  - [index.html](index.html#L968) telemetry state
  - [index.html](index.html#L1016) event emission
  - [index.html](index.html#L1846) adaptive quality and debug reporting

5. Current release baseline and system scope are documented.
- Source anchors:
  - [README.md](README.md)
  - [RELEASE_NOTES_v2.0.0.md](RELEASE_NOTES_v2.0.0.md)

### Pack-level measurable checkpoints

1. S1 acceptance thresholds
- Median distance lift >= 10% versus baseline deck over 30 runs.
- Hazard-hit rate delta <= +5% versus baseline.
- Boss clear rate for first 3 bosses between 55% and 75%.
- p95 frame time <= 22 ms on target profile.

2. S2 acceptance thresholds
- No single loadout pick rate > 60% over 50 runs (dominance guardrail).
- Score inflation <= 15% versus S1 median.
- Mission-chain abandonment increase <= 8% versus S1.

3. X experimental thresholds (prototype-only)
- Crash-free session rate >= 99.0%.
- Unwinnable-state repro count = 0 in deterministic replay set.
- Accessibility complaint rate does not regress versus S2 baseline sample.

## Stop/Recover Threshold Table

| Pack | Trigger | Threshold | Measurement Window | Fallback Action | Owner |
|---|---|---|---|---|---|
| S1 | Readability regression | Boss fail reason tagged unreadable > 20% | 30-run batch | Disable pulse intensity modifier and revert to baseline telegraph timing | Gameplay |
| S1 | Performance regression | p95 frame time > 22 ms for 3 consecutive sessions | Per-device nightly run | Auto-force low quality and disable extra VFX burst layer | Runtime |
| S2 | Dominant strategy collapse | Any B2 loadout pick rate > 60% | 50-run sample | Remove top loadout from rotation and rebalance downsides | Design |
| S2 | Reward inflation | Median score > 15% above S1 without distance lift | 50-run sample | Reduce chain multipliers and clutch bias weights by 20% | Design |
| X | Determinism drift | Replay checksum mismatch > 0 in fixed seed suite | CI + nightly | Keep X behind flag, block merge, and revert last X change-set | Engineering |
| X | Accessibility regression | Motion-discomfort feedback > baseline + 10% | Weekly feedback cohort | Force comfort preset and disable highest camera effect tier | UX |

## Recommended Governance Audit Target

Audit target: this file as the complete second constrained exploration pass.

Primary audit lens:
- Kernel gates: Intent -> Admissibility -> Coverage -> Integrity -> Evidence -> Stop/Recover.

Priority order:
1. A3, B3, C3 (high-risk radicals)
2. A2, B2, C2 (hybrids)
3. A1, B1, C1 (safe baseline)

Promotion condition:
- Only S1 candidates should be considered for near-term implementation promotion if governance returns pass with no blocking gaps.
