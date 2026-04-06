# Code Review Agent

Reviews code against **FAFCAS** (Factual, Accurate, Fair, Complete, Actionable, Specific) rubric.

## FAFCAS Rubric

| Dimension | What It Measures |
|-----------|------------------|
| **Factual** | Claims backed by evidence (tests, benchmarks, docs) |
| **Accurate** | Correct technical assertions, no false positives |
| **Fair** | Balanced assessment, acknowledges strengths |
| **Complete** | All aspects reviewed (logic, security, perf, docs) |
| **Actionable** | Specific suggestions with clear next steps |
| **Specific** | Points to exact lines, files, or patterns |

## Quick Start

```bash
cd agents/code-review-agent

# Check status
just status

# Review current changes
just analyze HEAD~1..HEAD incremental

# Generate report
just report

# Show scores
just scores

# Show full report
just show-report
```

## Request/Response Pattern

### 1. Create Request

```bash
echo '{"target":"HEAD~1..HEAD","scope":"incremental","mode":"both","threshold":"medium"}' \
  > markers/request/payload.jsonl
```

### 2. Run Agent

```bash
just review
```

### 3. Read Results

```bash
cat markers/done/report.md    # Full FAFCAS report
cat markers/done/summary.json # JSON scores
cat markers/done/analysis.jsonl # Raw findings
```

## Coordinate Protocol

| Command | Purpose |
|---------|---------|
| `coordinate.sh poll` | Check for pending requests |
| `coordinate.sh running` | Mark as RUNNING |
| `coordinate.sh complete` | Mark as DONE |
| `coordinate.sh error <msg>` | Mark as ERROR |
| `coordinate.sh idle` | Mark as IDLE |
| `coordinate.sh reset` | Clear all state |

## Output Files

```
markers/done/
├── report.md        # FAFCAS report (Markdown)
├── summary.json     # Scores (JSON)
├── analysis.jsonl   # Raw findings (JSONL)
└── patches/         # Auto-hardening patches
    ├── removals.lst
    ├── review.lst
    └── security.lst
```

## Analysis Findings

The agent detects:

| Type | Description | Severity |
|------|-------------|----------|
| `debug` | console.log, debugger, print statements | Low-Medium |
| `marker` | TODO, FIXME, HACK, XXX | Medium |
| `security` | Potential secret exposure | High |
| `async` | Async pattern detection | Low |

## Auto-Hardening

| Threshold | Auto-fixes |
|-----------|------------|
| `low` | Nothing |
| `medium` | Debug code only |
| `high` | Debug + markers |
| `all` | Everything except security |

**Security issues are NEVER auto-fixed.** They are flagged for human review.

## Integration

### Mount in any silo

```bash
cd my-silo
ln -s ../agents/code-review-agent agents/code-review
cd agents/code-review
just review
```

### GitHub Actions

```yaml
- name: Code Review
  run: |
    echo '{"target":"${{ github.sha }}","scope":"incremental","mode":"review"}' \
      > agents/code-review-agent/markers/request/payload.jsonl
    cd agents/code-review-agent && just review
    cat markers/done/report.md >> $GITHUB_STEP_SUMMARY
```

## Architecture

```
code-review-agent/
├── .agent              # Agent manifest
├── request-schema.json # Input schema
├── justfile            # Interface
├── scripts/
│   ├── coordinate.sh   # Parent communication
│   ├── analyze.sh      # Diff analysis
│   ├── harden.sh      # Auto-hardening
│   └── report.sh      # FAFCAS report
└── markers/
    ├── request/        # Input
    ├── done/          # Output
    ├── error/         # Errors
    └── state/         # Current state
```
