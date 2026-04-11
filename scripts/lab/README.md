# @scripts/lab — Experimental Scripts

**Tier 0:** Raw experiments. No guarantees.

---

## Purpose

Scripts in `lab/` are experiments. Agents try ideas here without affecting production code.

---

## Rules

| Rule | Rationale |
|------|------------|
| `@` prefix naming | `@experiment.sh`, `@draft-*.sh` |
| No review required | Experiments are cheap |
| Promote when stable | Move to `scripts/` |
| Archive if abandoned | Gamma-loop cleans stale experiments |

---

## Promotion Pathway

```
@scripts/lab/transform.sh    # Experiment
        ↓
scripts/transform.sh         # Stable
        ↓
src/transform.ts            # Production (if needed)
```

---

## Examples

```
scripts/lab/
├── @entropy-viz.sh          # Trying visualization
├── @jq-playground.sh        # Testing jq patterns
└── @prompt-experiment.sh     # Trying prompts
```

---

## Gamma-Loop Integration

During tidy phase, the agent checks:
- What experiments are stale (>30 days)?
- What experiments are stable enough to promote?
- Archive abandoned experiments to `archive/lab/`

---

## See Also

- `scratch/` — Agent scratchpad (private workspace)
- `playbooks/lessons-learned.md` — Collected wisdom
