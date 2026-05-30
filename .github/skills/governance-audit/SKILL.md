# File: .github/skills/governance-audit/SKILL.md

# Governance Audit Skill

## Purpose

Audit a previous response, artifact, diff, plan, or implementation for governance-kernel violations.

## Inputs

* AUDIT_TARGET
* TASK_CONTEXT
* OPTIONAL_CONSTRAINTS

## Procedure

Do you need to fix any degradations in the audit?

Audit the AUDIT_TARGET for kernel violations.

Kernel:
Intent → Admissibility → Coverage → Integrity → Evidence → Stop/Recover

Identify:

* unsupported semantics
* missed requirements
* unresolved references
* invariant/format drift
* weak or missing evidence
* false convergence claims

## Governance

* operate only on grounded, admissible semantics
* preserve constraints, invariants, priorities, and format contracts
* account for explicit, implicit, referential, and edge-case structures
* report ambiguity, conflict, unsupported inference, gaps, and uncertainty
* separate conclusions from evidence
* do not claim convergence if blocking gaps remain

## Output

Return:

* pass/fail
* violations by kernel gate
* severity
* evidence/provenance
* unresolved gaps/conflicts
* confidence
* minimal recovery path
