# Governance Recovery Validation Checklist

## Scope

- save migration
- camera label integrity
- adaptive quality stop/recover
- first-person fallback behavior
- audio recovery fallback

## Evidence Targets

- `index.html` save load path reads `lankydash_save_v2` first, then probes legacy keys.
- Camera HUD label is updated through `syncCameraLabel()` and includes current biome segment.
- Resize keeps quality mode-consistent pixel ratio.
- Sustained frame-time spikes trigger recovery path.
- Audio recovery path attempts unlock, then mutes after timeout.

## Manual Runtime Checks

1. Existing player data migration:
- Seed localStorage with one legacy key and no v2 key.
- Launch game.
- Confirm values appear in HUD/profile state.
- Confirm `lankydash_save_v2` is written.

2. Camera label integrity:
- Cycle camera with `C` in each biome.
- Confirm label format: `CAM: <PROFILE> • <BIOME>`.
- Confirm no label flicker or stale profile name while transitioning biome segments.

3. Adaptive quality and resize:
- Stress framerate (high particle density / boss + effects).
- Confirm quality enters low mode near soft threshold and hard-recovery kicks on sustained spikes.
- Resize window while low mode is active.
- Confirm pixel ratio remains low-mode aligned.

4. First-person recover fallback:
- Enter first-person camera.
- Force sustained high frame-time spikes.
- Confirm auto-fallback to `cute34` with recovery toast.

5. Audio stop/recover:
- While running and unmuted, force audio context interruption/suspension.
- Confirm unlock attempts occur.
- If state remains non-running past timeout, confirm auto-mute fallback.

## Stop/Recover Thresholds

- Soft quality degrade trigger: fps moving average > 22 ms.
- Hard recovery trigger: fps moving average > 26 ms sustained for > 2.2 s.
- Recovery cooldown after forced actions: 3.0 s.
- Audio fallback mute trigger: non-running audio context sustained for > 2.2 s during active run.

## Exit Criteria

- All checks pass with no console errors.
- No gameplay fairness regression (lane hit width, spawn cadence, collision semantics unchanged).
- Governance re-audit returns pass with no blocking gaps.
