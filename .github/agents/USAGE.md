# Agent Invocation Playbook

This file defines a repeatable way to invoke repository agents and skills.

## Agent Roles

- Exploration Operator: proposes candidates and repairs only.
- Governance Auditor: audits outputs and blocks unsafe promotion.

Source files:
- .github/agents/exploration-operator/AGENT.md
- .github/agents/exploration-operator/PROMPT.md
- .github/agents/governance-auditor/AGENT.md
- .github/agents/governance-auditor/PROMPT.md
- .github/skills/governance-audit/SKILL.md

## Invocation Contract

Use this 4-step loop for every non-trivial task.

1. Explore
2. Audit
3. Repair
4. Re-audit

Promotion to implementation is allowed only after governance pass with no blocking gaps.

## Copy-Paste Invocation Templates

### 1) Exploration Call

Run exploration-operator.

TASK:
<describe objective>

CONSTRAINTS:
<explicit constraints, format, boundaries>

DELIVER:
- candidate solution
- rationale
- assumptions
- affected files/components
- risks
- unresolved gaps
- recommended governance audit target

### 2) Governance Audit Call

Run governance-auditor on AUDIT_TARGET:
<reference exploration output>

TASK_CONTEXT:
<original task>

OPTIONAL_CONSTRAINTS:
<extra constraints if any>

Use kernel:
Intent -> Admissibility -> Coverage -> Integrity -> Evidence -> Stop/Recover

Return:
- pass/fail
- violations by gate
- severity
- evidence/provenance
- unresolved gaps/conflicts
- confidence
- minimal recovery path

### 3) Repair Call (only if fail)

Run exploration-operator using governance findings.

INPUT:
- failing audit report
- original task context

GOAL:
Produce minimal repair candidate that closes blocking findings without broad refactor.

RETURN:
- repaired candidate
- delta vs prior candidate
- residual risks
- audit target for re-check

### 4) Promotion Gate

If audit result is pass and no blocking gaps remain:
- proceed to implementation/release activity

Else:
- repeat Repair -> Re-audit loop

## Blocking Policy

Default policy:
- Critical: block
- High: block
- Medium: requires explicit acceptance
- Low: may defer with reason

## Artifact Convention

Store per-task artifacts under:
- .github/workflows/artifacts/<task-id>/exploration.md
- .github/workflows/artifacts/<task-id>/audit.md
- .github/workflows/artifacts/<task-id>/repair.md

Task id format:
- YYYYMMDD-short-slug

## Minimum Evidence Rule

Any conclusion that affects promotion must cite specific evidence from:
- repository files
- command output
- explicit user constraints

Do not claim convergence if blocking gaps remain.
