# Gamma-Loop Playbook

## The Pattern

Whenever we learn a lesson, we capture it.

```
Develop → Verb → Document → Tidy
```

---

## The Gamma-Loop

**Gamma** = the third letter. After alpha (first attempt), beta (iteration), gamma (learning).

### The Cycle

1. **Develop** — Figure it out. Get it working.
2. **Verb** — Add `just` verbs. Make it repeatable.
3. **Document** — Write playbook, brief, or debrief.
4. **Tidy** — Prune dead verbs, stale docs, old briefs.

### When to Run

- End of every session
- When a pattern emerges
- Before starting something new

---

## How It Works

### 1. Develop

```
cd new-thing
# Figure it out
command --that --works
```

### 2. Verb

```bash
# Add to justfile
do-thing ARG:
    command --that --works {{ARG}}
```

### 3. Document

Create a playbook:
```bash
# playbooks/new-thing-playbook.md
# How to use the thing
```

Or update an existing one.

### 4. Tidy

```bash
just tidy
```

Prune:
- Dead verbs
- Stale docs
- Old briefs without follow-up
- Unused scripts

---

## Telemetry Logging

The gamma-loop measures entropy to track improvement over time.

### Metrics Logged

| Metric | File | Purpose |
|--------|------|---------|
| Workflow runs | `telemetry/runs.jsonl` | Activity tracking |
| Entropy scores | `telemetry/entropy.jsonl` | Improvement measurement |
| Adjustments | `telemetry/adjustments.jsonl` | Change tracking |

### Entropy Calculation

```
Entropy = -Σ p(x) * log(p(x))

Where x = outcome type (success, partial, failure)
```

### Interpretation

| Entropy Range | Interpretation |
|---------------|----------------|
| 0.0 - 0.3 | Low entropy — process is stable |
| 0.3 - 0.6 | Moderate — some variability |
| 0.6 - 1.0 | High — process needs attention |

---

## See Also

- `playbooks/gamma-loop-protocol.md` — Full protocol specification
- `scripts/gamma-loop.sh` — Gamma-loop automation script
- `debriefs/` — Retrospective storage
