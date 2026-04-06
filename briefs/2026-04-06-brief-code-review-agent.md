# Brief: Code Review Agent

## Context

**Problem:** We have EPICs 1-8 complete. Need to harden the codebase and ensure FAFCAS (Factual, Accurate, Fair, Complete, Actionable, Specific) compliance.

**Approach:** Build a code-review-agent that:
1. Reviews PRs/changes against FAFCAS rubric
2. Hardens code (flensing dead code, improving structure)
3. Reports adherence/non-adherence
4. Can be run as a sub-agent via just-silo

## What Is FAFCAS?

| Principle | Code Review Application |
|-----------|------------------------|
| **Factual** | Claims backed by evidence (tests, benchmarks, docs) |
| **Accurate** | No false positives, correct technical assertions |
| **Fair** | Balanced assessment, acknowledges strengths |
| **Complete** | All aspects reviewed (logic, security, perf, docs) |
| **Actionable** | Specific suggestions with clear next steps |
| **Specific** | Points to exact lines, files, or patterns |

## Agent Design

### Agent Silo Structure

```
code-review-agent/
├── .agent              # Agent manifest (role, inputs, outputs)
├── .silo               # Silo integration
├── instructions.md     # Detailed behavior
├── rubric.json         # FAFCAS scoring rubric
├── analyze.sh         # Core analysis script
├── harden.sh           # Auto-hardening (flense, etc.)
├── report.sh           # FAFCAS compliance report
├── coordinate.sh       # Parent/peer communication
└── markdowns/          # Output templates
```

### .agent Manifest

```json
{
  "name": "code-review-agent",
  "role": "Code reviewer and hardener",
  "version": "0.1.0",
  "inputs": {
    "target": "git diff, PR number, or file path",
    "scope": "full | incremental | single",
    "mode": "review | harden | both"
  },
  "outputs": {
    "report": "FAFCAS compliance report",
    "patches": "Optional hardening patches",
    "summary": "Human-readable summary"
  },
  "parent_communication": "via marker files in markers/",
  "silo_integration": "self | mount | standalone"
}
```

## Core Scripts

### analyze.sh

Inputs:
- Target (diff, PR, file)
- Scope

Outputs:
- Structured analysis (JSONL)
- Findings per FAFCAS dimension

### harden.sh

Inputs:
- Analysis findings
- Auto-fix threshold

Outputs:
- Patches (rejects or applies)
- Hardening report

### report.sh

Inputs:
- Analysis + hardening results

Outputs:
- FAFCAS score (1-5 per dimension)
- Detailed findings
- Action items

## Coordination Protocol

### Parent → Agent

```
markers/review_request   # Contains: target, scope, mode, priority
markers/review_done      # Contains: agent-id, status, output-path
markers/review_error     # Contains: agent-id, error, retries
```

### Agent → Parent

```
markers/analysis_complete/  # Results ready
markers/harden_complete/    # Patches ready
markers/report_complete/    # FAFCAS report ready
```

## FAFCAS Scoring

### Per-Findings Scoring

| Score | Description |
|-------|-------------|
| 5 | Exceeds expectations |
| 4 | Meets FAFCAS fully |
| 3 | Meets FAFCAS mostly |
| 2 | Partially meets |
| 1 | Does not meet |

### Aggregate Scoring

- **Average**: Overall FAFCAS score
- **Minimum**: Lowest dimension (blocking issues)
- **Weighted**: Custom weights per dimension

## Implementation Phases

### Phase 1: Reviewer (MVP)
- [ ] Create agent scaffold
- [ ] Basic diff analysis
- [ ] FAFCAS rubric
- [ ] Report generation

### Phase 2: Hardener
- [ ] Flensing (dead code removal)
- [ ] Structure improvements
- [ ] Patch generation

### Phase 3: Integration
- [ ] Coordinate.sh for parent comms
- [ ] Just-silo integration
- [ ] CI/CD hook

## Success Criteria

- [ ] Can review a PR and generate FAFCAS-compliant report
- [ ] Can auto-harden trivial issues
- [ ] Can be mounted in any silo
- [ ] Coordinate protocol works with parent agent

## Open Questions

1. How do we handle multi-file PRs?
2. What's the auto-hardening threshold?
3. How do we handle language-specific concerns?
4. Integration with GitHub PR review API?

## Related

- `briefs/2026-04-06-brief-silo-cadence.md` — Agent cadence
- `briefs/2026-04-06-brief-rate-limiting.md` — Resource management
- `playbooks/silo-agent-playbook.md` — Agent mounting pattern
