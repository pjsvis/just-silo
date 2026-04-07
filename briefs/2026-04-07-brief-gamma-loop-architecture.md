# Brief: Gamma Loop Architecture for just-silo

**Date:** 2026-04-07
**Status:** Implemented
**Issue:** td-3f095e

## Summary

Gamma Loops are the self-monitoring and self-correction mechanisms in just-silo. They enable silos to maintain their own hygiene without human intervention.

## Concept

A **Gamma-Loop** is the internal feedback mechanism that:
1. Monitors the Silo state
2. Detects drift from expected conditions
3. Applies corrections automatically
4. Escalates to human when needed

## Existing Implementation: tidy-first-agent

The `tidy-first-agent` is the canonical gamma-loop implementation:

```
tidy-first-agent/
├── src/tidy-first-agent    # Main loop script
├── justfile                # Entry verbs
├── CSP.md                  # Constraint policy
├── manifest.json           # Agent manifest
└── schedules/             # Cron definitions
```

### What it monitors:
| Resource | Threshold | Action |
|----------|-----------|--------|
| Briefs | > 30 files | Archive oldest |
| Debriefs | > 20 files | Archive oldest |
| td issues | stale > 14 days | Flag for review |
| Git branches | merged | Prune |

## Gamma Loop Pattern

To add a gamma-loop to any silo:

```just
# Gamma-Loop: Self-monitoring recipe
gamma-check:
    @echo "Checking silo state..."
    @./scripts/gamma-check.sh

gamma-correct:
    @echo "Applying corrections..."
    @./scripts/gamma-correct.sh

gamma-status:
    @echo "Gamma status:"
    @./scripts/gamma-status.sh
```

## Gamma Loop Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    SILO                                │
│                                                         │
│  ┌─────────────┐    ┌─────────────┐    ┌───────────┐ │
│  │  Executor   │───▶│  Gamma-Loop │◀───│  Monitor  │ │
│  │  (Alpha)    │    │  (Self-     │    │  (Sense)  │ │
│  │             │◀───│   Tune)     │───▶│           │ │
│  └─────────────┘    └─────────────┘    └───────────┘ │
│         ▲                  │                    │      │
│         │                  ▼                    │      │
│         │           ┌─────────────┐            │      │
│         └───────────│  Escalate   │◀───────────┘      │
│                     │  (Human)    │                   │
│                     └─────────────┘                   │
└─────────────────────────────────────────────────────────┘
```

## Self-Modification Boundaries

Gamma loops can modify:
- ✅ **Archivable data** (briefs, logs)
- ✅ **State files** (status.json)
- ✅ **Marker files** (agent coordination)

Gamma loops MUST NOT modify:
- ❌ **Source code**
- ❌ **.silo manifest**
- ❌ **Justfiles (without approval)**
- ❌ **Credentials/secrets**

## Safety Rails

1. **Git checkpointing:** Archive before modify
2. **Constraint policy:** CSP.md defines limits
3. **Audit trail:** All changes logged to `gamma-log.jsonl`
4. **Escalation threshold:** Human review for complex issues

## Integration with tidy-first-agent

The tidy-first-agent is the "root" gamma-loop for the main silo:

```bash
# Invoke gamma-loop
just agents-tidy "run --full"

# Check gamma status
just agents-tidy "status"
```

## Future: Sub-Silo Gamma Loops

Each agent can have its own gamma-loop:

```
agent/
├── src/gamma-loop     # Agent-specific monitoring
├── constraints.md     # Agent limits
└── escalate.md        # Escalation criteria
```

## Metrics

Track gamma-loop health:

```bash
just trend-show   # Shows gamma activity
```

## Related

- `agents/tidy-first-agent/` - Canonical gamma-loop implementation
- `playbooks/gamma-loop-playbook.md` - Usage patterns
