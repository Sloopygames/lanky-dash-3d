# Promotion Rules

## Purpose

Define when candidate artifacts may become trusted artifacts.

Promotion is the only authorized transition from candidate state into trusted state.

## State Model

```text
TRUSTED / RELEASE state
CANDIDATE / TEST state
AUDIT state
```

## Promotion Rule

A candidate may be promoted only if:

```text
baseline context resolved
∧ light audits passed
∧ deep audit passed
∧ evidence is traceable
∧ no blocking gaps remain
∧ trust boundaries preserved
∧ retry bounds not exceeded
∧ promotion gate approves
```

## Non-Promotion Conditions

Do not promote if:

- unresolved references remain
- unsupported claims remain
- requirements are missed
- evidence is weak or missing
- artifact graph cannot be reconstructed
- audit has mutation authority
- candidate self-approves
- trusted state was modified outside promotion gate
- convergence is claimed despite blocking gaps

## Promotion Gate Inputs

Promotion Gate receives:

- candidate artifact set
- parent document
- document graph
- latest light audit
- latest deep audit artifact reference (path + cycle ID)
- latest deep audit result summary
- evidence map
- unresolved gaps list
- change summary
- retry history

## Promotion Gate Outputs

Return:

- promote / reject / defer
- failed gates
- evidence summary
- unresolved blocking issues
- required repair
- confidence
- deep-audit artifact reference used for this decision
- promotion decision artifact reference
- promoted artifact references, if approved

## Promotion Severity

| Severity | Meaning | Promotion |
|---|---|---|
| S0 | no issue | allowed |
| S1 | minor non-blocking issue | allowed with note |
| S2 | repairable issue | defer |
| S3 | blocking issue | reject |
| S4 | trust-boundary violation | reject and escalate |

## Trusted-State Discipline

- Only the Promotion Gate may authorize trusted-state updates.
- Audit agents may not mutate trusted state.
- Exploration agents may not mutate trusted state.
- Integrator may only produce candidate state.
- Candidate artifacts must remain distinguishable from trusted artifacts.

## Final Acceptance Gate

```text
validator coverage
∧ evidence coverage
∧ audit pass
∧ semantic coverage
∧ retry bound not exceeded
∧ no unauthorized candidate-to-trusted flow
∧ evidence provenance matches current cycle
∧ audit has no mutation authority
∧ promotion gate approves
```
