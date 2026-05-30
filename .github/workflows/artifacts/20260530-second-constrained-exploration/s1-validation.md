# S1 Validation

Task id: 20260530-second-constrained-exploration
Pack: S1 (A1 Pressure Crescendo, B1 Route Signaling 2.0, C1 Variant Deck Rotation)
Status: In progress

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

- Gameplay: TBD
- Runtime: TBD
- UX: TBD
- Governance: TBD
