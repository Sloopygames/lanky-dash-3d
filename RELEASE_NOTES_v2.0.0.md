# Lanky Dash v2.0.0 Release Notes

## Highlights

- Three-sprint systems expansion completed.
- New mission, combo, and risk/reward gameplay layers.
- Daily seeded challenge mode with per-day best tracking.
- New boss telegraph and dodge-bonus patterning.
- New hazards and pickups for deeper run variety.
- Adaptive quality and in-game debug telemetry.
- Mobile settings, handedness layout, and quick share support.

## Gameplay

- Added mission cards (3 per run) with bonus score rewards.
- Added combo multiplier scoring and overcharge state behavior.
- Added volatile gates and shield pickups.
- Added new hazard archetypes: sweeper and crusher.
- Added anti-repeat spawn director and expanded archetype queue.
- Added biome progression with distance-based transitions.
- Added boss pattern types with telegraphed dodge windows.
- Rebalanced progression:
  - Start power increased to improve early consistency.
  - Positive/negative gate values adjusted for smoother curve.
  - Boss threshold scaling softened.
  - Boss cadence tightened gradually later in runs.

## Systems and UX

- Added settings for touch mode (drag/swipe), dead zone, and handedness.
- Added cosmetic cycling with persisted profile save.
- Added changelog panel (NEW button).
- Added share summary action from HUD and game over.
- Added achievement/meta star tracking.
- Added save migration path via consolidated v2 save key.

## Performance and Diagnostics

- Added adaptive quality scaler based on moving frame-time average.
- Added debug panel with runtime telemetry and spawn summaries.
- Added event hooks for tuning and balancing analysis.

## Notes

- This release is save-compatible with prior best score tracking via migration path.
- Daily challenge uses UTC date seeding for deterministic runs.
