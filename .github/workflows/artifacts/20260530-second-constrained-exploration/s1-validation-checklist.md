# S1 Validation Checklist

Task id: 20260530-second-constrained-exploration
Status: Active

## Preflight

- [ ] Target branch and commit hash recorded.
- [ ] Device profile and browser version recorded.
- [ ] Fixed seed set selected and frozen.
- [ ] S1 flags explicitly documented.

## Baseline Collection

- [ ] 30 baseline runs completed.
- [ ] Baseline telemetry packet exported.
- [ ] Baseline summary metrics generated.

## S1 Collection

- [ ] 30 S1-enabled runs completed.
- [ ] S1 telemetry packet exported.
- [ ] S1 summary metrics generated.

## Metric Computation

- [ ] Median distance delta computed.
- [ ] Hazard-hit rate delta computed.
- [ ] First-3-boss clear rate computed.
- [ ] p95 frame time computed.

## Threshold Evaluation

- [ ] All four threshold pass/fail cells filled in s1-validation.md.
- [ ] Readability/comfort checks filled.
- [ ] Stop/recover trigger log filled.
- [ ] Any fallback actions documented.

## Evidence Attachment

- [ ] Seeded run summary links attached.
- [ ] Debug telemetry snapshot links attached.
- [ ] Baseline vs S1 extraction sheet linked.
- [ ] Notes on anomalies and reruns attached.

## Governance Close

- [ ] Final governance audit run on completed s1-validation.md.
- [ ] Pass/fail recorded.
- [ ] Promotion decision updated in closeout artifact.
