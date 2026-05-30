# Branching Rules

## Purpose

Define how the recursive orchestration loop routes outputs based on governance findings, creative value, and artifact state.

## Branch Categories

```text
PASS
REPAIR
EXPAND
ESCALATE
BLOCK
PROMOTE
```

## Branch Rules

### PASS

Use when:

- no blocking governance violations exist
- artifact remains coherent
- evidence is adequate
- unresolved gaps are non-blocking

Route:

```text
Governor Light Audit → Integrator
```

### REPAIR

Use when:

- candidate is valuable but has fixable violations
- unsupported claims can be grounded
- missing requirements can be added
- format or integrity drift is localized

Route:

```text
Governor Light Audit → Explorer Repair → Governor Light Audit
```

### EXPAND

Use when:

- candidate is valid but underdeveloped
- idea is coherent but creatively weak
- design space remains too narrow
- artifact needs more alternatives

Route:

```text
Governor Light Audit → Explorer Expansion
```

### ESCALATE

Use when:

- light audit repeatedly fails
- canon drift is detected
- document graph changes
- core mechanic changes
- major architecture changes
- contradictions span multiple artifacts
- unresolved references affect key requirements

Route:

```text
Governor Light Audit → Deep Governor Audit
```

### BLOCK

Use when:

- source references are missing
- task intent is unresolved
- candidate depends on fabricated context
- evidence is insufficient
- trust boundary is violated
- convergence would be false

Route:

```text
Any Agent → Stop/Recover
```

### PROMOTE

Use when:

- deep audit passes
- promotion gate passes
- candidate is traceable
- no blocking gaps remain
- trusted-state mutation is authorized

Route:

```text
Deep Governor Audit → Promotion Gate → Trusted State
```

## Failure-to-Branch Map

| Failure | Branch |
|---|---|
| Unsupported semantics | REPAIR or BLOCK |
| Missed requirements | REPAIR |
| Unresolved references | ESCALATE or BLOCK |
| Invariant drift | REPAIR or ESCALATE |
| Weak evidence | REPAIR |
| False convergence | BLOCK |
| Repeated light-audit failure | ESCALATE |
| Valid but boring candidate | EXPAND |
| Novel but unstable candidate | REPAIR |
| Valid and high-value candidate | PASS |
| Fully audited candidate | PROMOTE |

## Branch Output Contract

Every branch decision must include:

- cycle ID
- branch name
- trigger condition
- kernel gate(s) implicated
- severity
- evidence/provenance references
- decision artifact reference
- next agent
- minimal recovery path
- confidence
- promotion impact status (not-eligible | candidate-eligible | escalate-required | blocked)
