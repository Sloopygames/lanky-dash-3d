# Cadence Rules

## Purpose

Define when lightweight governance, deep governance, exploration, repair, integration, and promotion occur during long-running recursive loops.

## Default Cadence

```text
Every cycle:
- Explorer proposal
- Governor light audit
- Repair or integration decision

Every 3–5 cycles:
- Deep Governor Audit

Every major artifact mutation:
- Promotion Gate

Every document graph change:
- Context Mapper refresh
- Governor Baseline refresh
```

## Cycle Types

### Light Cycle

Use for normal iteration.

```text
Explorer → Governor Light Audit → Integrator or Repair
```

Runs every cycle.

### Repair Cycle

Use after a failed light audit.

```text
Governor Light Audit → Explorer Repair → Governor Light Audit
```

Maximum default retries: 2.

### Expansion Cycle

Use when a candidate is valid but creatively weak.

```text
Governor Light Audit → Explorer Expansion → Governor Light Audit
```

Maximum default expansions before deep audit: 3.

### Deep Audit Cycle

Use periodically or on trigger.

```text
Candidate Artifact Set → Deep Governor Audit
```

Default frequency: every 3–5 light cycles.

### Promotion Cycle

Use only after deep audit passes.

```text
Deep Governor Audit → Promotion Gate
```

## Escalation Triggers

Run Deep Governor Audit immediately if any occur:

- repeated light audit failure
- unresolved reference affecting core artifact
- parent document changes
- child document added or removed
- core mechanic changed
- architecture changed
- canon drift detected
- contradiction spans multiple artifacts
- evidence provenance mismatch
- artifact size or context exceeds stable operating bounds

## Retry Bounds

Default retry bounds:

| Loop | Max retries |
|---|---:|
| light audit repair | 2 |
| expansion without deep audit | 3 |
| unresolved reference recovery | 1 |
| promotion repair loop | 2 |
| full loop before human review | 5 |

## Stop Conditions

Stop and report if:

- retry bound exceeded
- missing input blocks admissibility
- task intent cannot be resolved
- trust boundary violation persists
- evidence cannot be produced
- artifact graph cannot be reconstructed
- deep audit fails twice on the same issue class

## Cadence Principle

Use light governance to prevent local drift.

Use deep governance to prevent accumulated corruption.

Use promotion gates to protect trusted state.
