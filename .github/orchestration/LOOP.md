# Recursive Agent Orchestration Loop

## Purpose

Define the long-running governed loop for evolving artifact sets, such as game design documents, source code, prompts, or implementation plans.

The loop separates creative expansion from governance enforcement.

## Core Loop

```text
Context Mapper
→ Governor Baseline
→ Explorer
→ Governor Light Audit
→ Integrator
→ repeat for bounded cycles
→ Deep Governor Audit
→ Promotion Gate
→ repeat
```

## Roles

### Context Mapper

Reads the parent artifact and referenced child artifacts.

Produces:
- document graph
- canonical source list
- unresolved references
- artifact authority map
- initial constraints

### Governor Baseline

Establishes the governance frame before exploration begins.

Produces:
- invariants
- constraints
- hard requirements
- ambiguity surfaces
- contradiction list
- admissibility boundaries

### Explorer

Generates candidate improvements, mechanics, designs, decompositions, or repairs.

Produces:
- candidate trajectories
- rationale
- assumptions
- affected artifacts
- risks
- governance audit targets

### Governor Light Audit

Runs every cycle.

Checks:
- Intent
- Admissibility
- Coverage
- Integrity
- Evidence
- Stop/Recover

Produces:
- pass/fail
- kernel violations
- severity
- evidence
- minimal repair

### Integrator

Merges surviving candidates into candidate artifacts.

Produces:
- candidate artifact update
- change summary
- source-to-change trace
- unresolved gaps

### Deep Governor Audit

Runs periodically or on escalation trigger.

Checks:
- accumulated drift
- document graph consistency
- canon preservation
- unresolved conflicts
- repeated light-audit failures
- promotion eligibility

### Promotion Gate

Determines whether candidate state can become trusted state.

Produces:
- promote/reject/defer
- failed gates
- required repairs
- final confidence

## Standard Cycle

```text
1. Read current trusted state.
2. Build or refresh context map.
3. Establish baseline governance.
4. Explorer proposes candidate changes.
5. Governor performs light audit.
6. If light audit fails:
   - route to repair branch.
7. If light audit passes:
   - route to integration branch.
8. Integrator updates candidate artifacts.
9. Repeat for bounded cycle count.
10. Run deep governor audit.
11. Promotion gate approves or rejects candidate state.
```

## Loop Invariants

- Explorer proposes.
- Governor audits.
- Integrator merges only auditable candidates.
- Promotion Gate alone promotes trusted state.
- Audit does not mutate the artifact it evaluates.
- Candidate state cannot self-promote.
- Blocking gaps prevent convergence claims.

## Runtime Kernel

All loop stages preserve:

```text
Intent → Admissibility → Coverage → Integrity → Evidence → Stop/Recover
```

## Required Outputs Per Cycle

Each cycle must emit:

- cycle ID
- cycle type (light | repair | expansion | deep-audit | promotion)
- active agent
- input artifact references
- output artifact references
- branch decision (PASS | REPAIR | EXPAND | ESCALATE | BLOCK | PROMOTE)
- branch trigger condition
- audit result by kernel gate
- severity
- evidence/provenance references
- unresolved gaps
- minimal recovery path
- confidence
- next agent
- promotion status
- cycle artifact references (exploration/repair/audit/integration/promotion artifacts as applicable)
