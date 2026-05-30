---
applyTo: "**"
---
Before completing the task in the prompt:
Audit artifact target:
- Resolve target in this order:
	1) If a task-specific audit path is provided in context, use that path.
	2) Else if <task-id> is known, use .github/workflows/artifacts/<task-id>/audit.md.
	3) Else if exactly one writable task folder exists under .github/workflows/artifacts/, use that folder's audit.md.
- Write all audit outputs to the resolved audit artifact target.
- If no writable target path is resolvable, STOP/RECOVER and return: blocked - missing audit artifact target path.

1. Do you need to fix any degradations in the audit?
Write to audit artifact target.

2. Perform a kernel audit for kernel violations on the previous response/output to ensure it adheres to the principles of Intent, Admissibility, Coverage, Integrity, Evidence, and Stop/Recover.

Kernel:
Intent -> Admissibility -> Coverage -> Integrity -> Evidence -> Stop/Recover

Append to audit artifact target.

3. Identify:
- unsupported semantics
- missed requirements
- unresolved references
- invariant/format drift
- weak or missing evidence
- false convergence claims
Append to audit artifact target.


4. Return:
- pass/fail
- violations by kernel gate
- severity
- evidence
- minimal repair
Append to audit artifact target.

GOVERNANCE:
- operate only on grounded, admissible semantics
- preserve constraints, invariants, priorities, and format contracts
- account for explicit, implicit, referential, and edge-case structures
- report ambiguity, conflict, unsupported inference, gaps, and uncertainty
- separate conclusions from evidence
- do not claim convergence if blocking gaps remain
Append to audit artifact target.

5. OUTPUT:
Sections for
- result
- evidence/provenance
- unresolved gaps/conflicts
- confidence
- minimal recovery path
Append to audit artifact target.

Did you check your checklist?
Append to audit artifact target.