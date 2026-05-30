# S1 Implementation Plan

Task id: 20260530-second-constrained-exploration
Pack: S1 (A1 Pressure Crescendo, B1 Route Signaling 2.0, C1 Variant Deck Rotation)

## Scope

Implement S1 as configuration-driven features with kill switches and telemetry attribution.

## Work Breakdown

1. Telemetry and attribution
- Add event tags for:
  - near-miss triggers
  - route-forecast indicator visibility/usage
  - active variant-deck id
  - boss-fail reason bucket (including unreadable)
- Add summary counters to debug panel output.

2. Pressure Crescendo (A1)
- Add pulse scheduler (distance-based default, optional adaptive mode off by default).
- Add configurable pulse profile:
  - speed scalar
  - hazard density scalar
  - VFX intensity scalar
  - audio stinger id
- Add kill switch: `feature.pulse.enabled`.

3. Route Signaling 2.0 (B1)
- Add 2-3 row look-ahead forecast indicators.
- Add risk-tier icon overlay per lane (low/medium/high volatility expectation).
- Add mission-aware non-forcing hints.
- Add kill switch: `feature.routeSignals.enabled`.

4. Variant Deck Rotation (C1)
- Add ruleset deck object with named variants and parameter overrides.
- Apply deck id to seeded runs and expose in HUD/debug.
- Add comparability policy flag for scoreboards by deck id.
- Add kill switch: `feature.variantDeck.enabled`.

5. Governance safety hooks
- Implement stop/recover triggers from exploration artifact table.
- Add automatic fallback actions:
  - disable pulse intensity layer on readability trigger
  - force low-quality branch on perf trigger

## Acceptance Criteria

S1 thresholds (from exploration artifact):
1. Median distance lift >= 10% versus baseline over 30 runs.
2. Hazard-hit delta <= +5% versus baseline.
3. Boss clear rate for first 3 bosses between 55% and 75%.
4. p95 frame time <= 22 ms on target profile.

## Verification Artifacts

1. Baseline vs S1 comparison table
- Include: distance median, hazard-hit rate, first-3-boss clear rate, p95 frame time.

2. Deterministic seed regression log
- Fixed seed set run for baseline and S1 with deck attribution.

3. Governance checkpoint evidence
- C3 pre-audit packet
- C5 release-candidate packet

## Rollout Strategy

1. Phase 1: internal default-off deployment
2. Phase 2: S1 opt-in flag enabled for test cohort
3. Phase 3: default-on if all acceptance criteria pass

## Owners

- Gameplay systems: Gameplay
- Runtime/performance safeguards: Runtime
- UX readability and comfort: UX
- Governance evidence packet assembly: Governance

## Close Condition

S1 is closed when all acceptance criteria pass and governance confirms no blocking gaps for S1 promotion.
