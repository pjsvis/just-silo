# Just-Silo Framework Overview

**A framework for building silos that convert stuff into things.**

---

## The Core Idea

```
STUFF → SILO → THINGS
```

| Term | Meaning |
|------|---------|
| **Stuff** | Raw, unprocessed, chaotic input |
| **Silo** | The machine that converts |
| **Things** | Abstracted, structured, usable output |

**The silo reduces entropy.** It takes chaos and produces order.

---

## The Conversion Process

```
┌─────────────────────────────────────────────────────────────┐
│                        THE SILO                               │
│                                                             │
│  STUFF                                                      │
│  (raw, chaotic, high entropy)                               │
│       ↓                                                      │
│  ┌─────────────────────────────────────────────────────┐   │
│  │                   PROCESS                              │   │
│  │  • Abstract (extract key concepts)                   │   │
│  │  • Structure (organize into format)                   │   │
│  │  • Validate (check against schema)                    │   │
│  │  • Deliver (output as things)                       │   │
│  └─────────────────────────────────────────────────────┘   │
│       ↓                                                      │
│  THINGS                                                     │
│  (structured, usable, low entropy)                          │
│                                                             │
│  Entropy: HIGH → LOW ✅                                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Framework Components

| Component | Purpose | Key Files |
|-----------|---------|-----------|
| **Silo Template** | The machine | `template/basic/` |
| **Agents** | Automate workflows | `agents/` |
| **Gamma-Loop** | Improve over time | Internal to agents |
| **Logs** | Measure conversion | `logs/` |
| **Playbooks** | Capture patterns | `playbooks/` |

---

## Entropy: The Key Metric

> **Entropy** measures chaos. Less entropy = more order.

### Definition

```
Entropy = -Σ p(x) * log(p(x))

Where x = outcome type (success, partial, failure)
```

### Why It Matters

| Entropy | State | Result |
|----------|-------|--------|
| High | Chaos | Stuff stays stuff |
| Low | Order | Things emerge |

### Conversion Effectiveness

```
Entropy Reduction = (entropy_in - entropy_out) / entropy_in

Example: (0.95 - 0.45) / 0.95 = 52% reduction
```

---

## Logs: Surface Key Events

The silo logs capture conversion events:

```
logs/
├── conversion.log      # What converted
├── entropy.log        # Entropy measurements
├── adjustments.log    # Gamma-loop changes
└── errors.log         # Failures
```

### Conversion Log Format

```json
{
  "timestamp": "2026-04-07T10:00:00Z",
  "stuff": "raw-data.json",
  "things": "structured.json",
  "entropy_in": 0.95,
  "entropy_out": 0.45,
  "reduction": 0.52,
  "duration_ms": 1200
}
```

### What Logs Reveal

| Question | Log | Filter |
|----------|-----|--------|
| What converted well? | `conversion.log` | `reduction > 0.5` |
| What struggled? | `conversion.log` | `reduction < 0.2` |
| Is entropy decreasing? | `entropy.log` | `grep trend` |
| Did gamma-loop help? | `adjustments.log` | `grep threshold` |

---

## The Gamma-Loop: Internal Improvement

The gamma-loop is **not a verb**. It runs inside each agent.

```
Agent runs workflow
       ↓
Gamma-loop observes
       ↓
Patterns detected
       ↓
Adjustments made
       ↓
Next run better
       ↓
Entropy decreases over time ✅
```

---

## The Tuning Process

**The recipe emerges from the data, not from guessing.**

### Phase 1: Log Everything

```
just tidy  # logs everything
```

### Phase 2: Filter

```
grep "threshold" logs/entropy.log
grep "archived" logs/conversion.log
```

### Phase 3: Observe Pattern

```
"Archive happens every Monday after agent work"
```

### Phase 4: Tune

```
Adjust cron timing → Archive Friday instead
```

### Phase 5: Verify

```
just tidy  # logs show entropy decreased
```

---

## Example: Brief-to-Playbook Silo

### The Problem (Stuff)

```
Raw notes from meeting (5000 words, unorganized)
```

### The Process

```
1. Extract key concepts (abstract)
2. Structure into brief format
3. Validate against schema
4. Persist to playbook
```

### The Outcome (Things)

```
Brief: 500 words, organized, actionable
Playbook: Pattern documented for reuse
```

### The Entropy Reduction

```
entropy_in: 0.92 (raw notes)
entropy_out: 0.31 (playbook)
reduction: 66%
```

---

## Framework for Building Silos

### 1. Define the Conversion

```
STUFF: What comes in?
THINGS: What comes out?
```

### 2. Create the Silo

```bash
cp -r template/basic my-silo
cd my-silo
just silo-verify
```

### 3. Implement the Process

```
justfile: Define verbs
schema.json: Define structure
queries.json: Define filters
```

### 4. Run and Measure

```
just harvest  # Convert stuff
just process  # Transform
just flush    # Output things
just logs     # Measure entropy
```

### 5. Improve with Gamma-Loop

```
Gamma-loop observes patterns
       ↓
Adjustments made
       ↓
Entropy decreases
```

---

## The Value Proposition

| What You Get | Why It Matters |
|--------------|----------------|
| **Repeatable process** | Consistent quality |
| **Measurable entropy** | Proof it's working |
| **Improving over time** | Gamma-loop tunes automatically |
| **Patterns in logs** | Recipes emerge from data |

---

## Key Principles

1. **Stuff → Things** — The silo converts, not just stores
2. **Entropy as metric** — Measure the conversion effectiveness
3. **Logs reveal patterns** — Filter and observe, don't guess
4. **Gamma-loop improves** — Internal, automatic, silent
5. **Recipes emerge** — The data tells you what works

---

## Summary

> The silo is entropy reduction made operational.

**Just-silo gives you:**
- A template for building conversion machines
- Agents that automate the workflow
- A gamma-loop that improves over time
- Logs that prove entropy is decreasing
- Filters that reveal conversion patterns

**The reveal:** You don't pre-define the recipe. You log, filter, and the recipe emerges.

---

## Related

- `Silo-Manual.md` — How silos work
- `Silo-Philosophy.md` — Why we built this
- `playbooks/gamma-loop-protocol.md` — Internal improvement
- `playbooks/agents-playbook.md` — Agent patterns
