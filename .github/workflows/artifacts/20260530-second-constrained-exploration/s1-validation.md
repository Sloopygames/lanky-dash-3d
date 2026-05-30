# S1 Validation

Task id: 20260530-second-constrained-exploration
Pack: S1 (A1 Pressure Crescendo, B1 Route Signaling 2.0, C1 Variant Deck Rotation)
Status: In progress

## Approval Receipt

- Human approval received: 2026-05-30.
- Effect: deferred human gate is cleared for continuing automation and evidence capture.
- Note: promotion remains metric-gated; threshold tables must still be populated.

## Implementation Evidence (Current)

Recent implementation commits relevant to S1 evidence capture:
1. c10e063 - Add dynamic art-style blending, rare event tiers, and happy-hardcore music.
2. e67c33b - Extend exploration artifact with style/event matrix and title metadata update.

Key code anchors for S1 instrumentation and behavior checks:
1. Missions and progression hooks: [index.html](index.html#L977), [index.html](index.html#L1032), [index.html](index.html#L1047)
2. Spawn and anti-repeat director: [index.html](index.html#L1134), [index.html](index.html#L1135), [index.html](index.html#L1178)
3. Boss telegraph/dodge windows: [index.html](index.html#L1232), [index.html](index.html#L1352), [index.html](index.html#L1766)
4. Telemetry and debug outputs: [index.html](index.html#L968), [index.html](index.html#L1016), [index.html](index.html#L1846)

This section confirms S1 mechanisms are implemented and instrumentable. Threshold rows remain data-pending.

## Validation Scope

Validate S1 execution metrics against governance-approved thresholds before release promotion.

## Thresholds (Authoritative)

1. Median distance lift >= 10% versus baseline over 30 runs.
2. Hazard-hit rate delta <= +5% versus baseline.
3. Boss clear rate for first 3 bosses between 55% and 75%.
4. p95 frame time <= 22 ms on target profile.

## Measurement Setup

- Sample size:
  - Baseline: 30 runs
  - S1 enabled: 30 runs
- Seed policy:
  - fixed deterministic seed set for comparability
- Device profile:
  - define target profile id and browser build before capture
- Build config:
  - record enabled flags: pulse, route signals, variant deck

## Automated Run Protocol (No Manual Math)

1. Capture baseline packet
- Start from same browser/device profile and fixed seed set.
- Run 30 baseline sessions.
- Export telemetry snapshots and summary CSV/JSON.

2. Capture S1 packet
- Enable S1 feature flags only.
- Run same fixed seed set for 30 sessions.
- Export telemetry snapshots and summary CSV/JSON.

3. Compute metrics
- Use same extraction script/notebook for baseline and S1 packets.
- Populate table values and pass/fail cells directly from computed outputs.

4. Trigger evaluation
- Populate stop/recover log from computed trigger checks.
- Record any fallback action activation and timestamp.

5. Governance packet
- Attach computed metrics and raw telemetry references.
- Submit this updated file for final governance pass.

## Baseline vs S1 Comparison Table

| Metric | Baseline | S1 | Delta | Threshold | Pass/Fail |
|---|---:|---:|---:|---|---|
| Median distance | TBD | TBD | TBD | >= +10% | TBD |
| Hazard-hit rate | TBD | TBD | TBD | <= +5% | TBD |
| Boss clear rate (first 3) | TBD | TBD | TBD | 55%-75% | TBD |
| p95 frame time (ms) | TBD | TBD | TBD | <= 22 ms | TBD |

## Readability and Comfort Checks

| Check | Baseline | S1 | Guardrail | Pass/Fail |
|---|---:|---:|---|---|
| Boss fail reason tagged unreadable | TBD | TBD | <= 20% | TBD |
| Motion-discomfort feedback | TBD | TBD | no regression | TBD |

## Stop/Recover Trigger Log

| Trigger | Observed | Threshold | Action Taken | Owner |
|---|---|---|---|---|
| S1 readability regression | TBD | unreadable > 20% | TBD | Gameplay |
| S1 performance regression | TBD | p95 > 22 ms (3 sessions) | TBD | Runtime |

## Evidence Bundle

Attach or link:
1. Seeded run summary exports
2. Debug telemetry snapshots
3. Baseline/S1 metric extraction sheet
4. Notes on any fallback action activation

## Decision

- S1 promotion decision: TBD
- Conditions to promote:
  - All four primary thresholds pass
  - No active stop/recover trigger
  - Governance confirms no blocking gaps in validation evidence

## Sign-off

- Gameplay: Approved (human), pending metric packet attachment
- Runtime: TBD
- UX: TBD
- Governance: TBD
