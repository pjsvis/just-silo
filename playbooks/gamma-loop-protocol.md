# Gamma-Loop Protocol

**Knowledge persistence control loop for agents.**

---

## The Core Insight

> We named it "tidy-first-agent" because we were tidying the workspace. But the *real* purpose is **knowledge persistence** — ensuring lessons don't die with the session.

---

## Definition

> **Gamma-Loop:** The control loop that activates after work completes, extracts lessons learned, and persists them to `debriefs/` and `playbooks/`.

### The Loop

```
Agent does work
    ↓
Gamma-loop activates
    ↓
What drifted? What worked? What failed?
    ↓
Lessons identified
    ↓
Persisted to: debriefs/ + playbooks/
    ↓
Knowledge survives the session
```

---

## Why "Gamma"?

From neurophysiology:
- **Alpha** = initial activation (the work)
- **Gamma** = high-frequency monitoring (maintaining state)

The gamma-loop maintains **knowledge state** — it ensures learning persists, not just the code.

---

## Each Agent Has a Gamma-Loop

| Agent | Domain | Gamma-Loop Persists To |
|-------|--------|------------------------|
| tidy-first-agent | Workspace hygiene | `briefs/archive/`, `debriefs/` |
| code-review-agent | Reviews | `playbooks/code-review/` |
| docs-agent | Documentation | `playbooks/*.md` |
| compliance-agent | Regulations | `playbooks/compliance/` |

---

## tidy-first-agent's Gamma-Loop

tidy-first-agent was built first to discover what gamma-loops need.

### What It Learned

| Discovery | Implication |
|-----------|------------|
| Files accumulate | Need threshold-based archiving |
| Old briefs become stale | Need age-based flagging |
| Lessons aren't captured | Need debrief template |
| Process drifts silently | Need observability |

### Its Gamma-Loop

```bash
Work completes
    ↓
Gamma-loop: "What changed?"
    ↓
Exceeded thresholds? → Archive oldest
    ↓
Lessons learned? → Write debrief
    ↓
Persisted to: debriefs/
```

---

## The Gamma-Loop Verb

We debate the verb without touching code:

```justfile
# Vocabulary options
gamma          # The concept verb
lessons        # What it produces
reflect        # The action
persist        # The outcome
debrief        # The mechanism
```

### Recommendation

| Verb | Purpose |
|------|---------|
| `gamma` | Run all agent gamma-loops |
| `gamma-check` | What needs persisting? |
| `gamma-save` | Persist lessons |
| `lessons` | Show lessons learned |

---

## Gamma-Loop Specification

Each agent's gamma-loop is defined in `CSP.md`:

```markdown
# CSP: My Agent

## Gamma-Loop

| Trigger | Action | Persists To |
|---------|--------|-------------|
| Session end | Write debrief | debriefs/ |
| Threshold exceeded | Archive + log | briefs/archive/ |
| Lesson learned | Write playbook | playbooks/ |
| Process drift | Flag for review | td issues |
```

---

## Gamma-Loop Protocol

### 1. Observe

```bash
# What happened this session?
gamma-check
```

Questions:
- What worked?
- What failed?
- What drifted from protocol?
- What needs documenting?

### 2. Extract

```bash
# What are the lessons?
gamma-extract
```

For each lesson:
- What was the context?
- What was the decision?
- What's the pattern?

### 3. Persist

```bash
# Write to debriefs/
gamma-save

# Write to playbooks/
gamma-save --playbook "lessons-patterns.md"
```

### 4. Verify

```bash
# Did it persist?
lessons
```

---

## DeBrief Format

```markdown
# DeBrief: [What Happened]

**Date:** YYYY-MM-DD
**Agent:** agent-name
**Session:** session-id

## What We Did

## What Worked

## What Was Tricky

## Lessons Learned

## Related

- debriefs/YYYY-MM-DD-*.md
- playbooks/*.md
```

---

## Playbook Pattern

```markdown
# Playbook: [Topic]

**Context:** When this situation arises...

**Pattern:** Do this...

**Why:** This works because...

**Related:**
- debriefs/YYYY-MM-DD-*.md
```

---

## Adding a Gamma-Loop to an Agent

1. Add `CSP.md` with gamma-loop section
2. Implement `gamma-check`, `gamma-save` commands
3. Define `persists-to` in `manifest.json`

```json
{
  "name": "my-agent",
  "type": "agent",
  "gamma-loop": {
    "triggers": ["session-end", "threshold-exceeded"],
    "persists-to": ["debriefs/", "playbooks/"]
  }
}
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| Lessons in memory | Lost on crash | Always persist |
| No debrief template | Inconsistent | Use standard format |
| Lessons not actionable | Noise | Specific, contextual |
| Gamma-loop optional | Drift inevitable | Make it required |

---

## Design Principles

1. **Every agent has a gamma-loop** — No agent is complete without knowledge persistence
2. **Lessons outlast sessions** — The code changes; the learning persists
3. **Structured format** — Consistent debriefs enable pattern detection
4. **Verifiable** — `lessons` command shows what was learned

---

## Related

- `brief-gamma-loop-01.md` — Philosophy (why gamma)
- `brief-gamma-loop-02.md` — Alpha-Gamma decoupling
- `silo-gamma-loop-03.md` — Baby→Adult maturation
- `agents/tidy-first-agent/` — First gamma-loop implementation
- `playbooks/agents-playbook.md` — Agent patterns

---

## Status

- [x] Define gamma-loop concept
- [x] Prototype: tidy-first-agent
- [x] Document specification
- [ ] Implement: gamma-* commands
- [ ] Add gamma-loop to code-review-agent
- [ ] Add gamma-loop to docs-agent

---

## The Revelation

> We built tidy-first-agent to discover what gamma-loop requires.

The discovery: **Knowledge doesn't persist automatically.** It must be extracted, structured, and saved — by design.

The gamma-loop is the nervous system of the agent. Without it, the agent works but doesn't learn.

---

## IMPORTANT: Gamma-Loop is Internal

The gamma-loop is **not a verb**. It is an **internal process** that runs automatically after each workflow.

### User-Facing Verbs

```justfile
tidy        # Run the job (gamma-loop runs inside)
```

### What the User Sees

```
just tidy
    ↓
Job executes
    ↓
Gamma-loop runs internally (user doesn't invoke)
    ↓
Agent improved for next run
```

### What the User Doesn't See

```
Gamma-loop observes
    ↓
Patterns detected
    ↓
Adjustments made to CSP.md
    ↓
Logged for entropy measurement
```

---

## Logging for Entropy Measurement

**Logging is a key component for entropy measurement.**

### What We Log

| Metric | What It Measures | Why |
|--------|----------------|-----|
| `runs.log` | Workflow execution frequency | Activity entropy |
| `adjustments.log` | Gamma-loop changes | Improvement rate |
| `thresholds.log` | Threshold changes over time | Calibration entropy |
| `errors.log` | Failures and retries | Failure entropy |
| `entropy.log` | Calculated entropy per run | Overall entropy |

### Log Format

```json
{
  "timestamp": "2026-04-07T10:00:00Z",
  "workflow": "tidy",
  "run": 42,
  "gamma-loop": {
    "observed": "threshold_exceeded",
    "adjusted": "archive_threshold: 30 → 35",
    "entropy_before": 0.72,
    "entropy_after": 0.68
  }
}
```

### Entropy Calculation

```
Entropy = -Σ p(x) * log(p(x))

Where x = outcome type (success, partial, failure)
```

### Why Logging Matters

1. **Measure improvement** — Is entropy decreasing over time?
2. **Detect drift** — Is entropy increasing? Something is wrong.
3. **Tune thresholds** — Real data tells us what thresholds work.
4. **Correlate with events** — What caused entropy spikes?

### Implementation Note

```bash
# Each agent should log to:
agents/<name>-agent/logs/
    runs.log
    adjustments.log
    entropy.log
```

---

## The Feedback Loop: Complete Picture

```
┌─────────────────────────────────────────────────────────────┐
│                        WORKFLOW                             │
│  Cron/WatchExec triggers tidy                               │
│                         ↓                                   │
│  Job executes                                              │
│                         ↓                                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              GAMMA-LOOP (Internal)                   │   │
│  │  1. Observe: What happened?                           │   │
│  │  2. Measure: Calculate entropy for this run          │   │
│  │  3. Learn: What patterns emerge?                     │   │
│  │  4. Adjust: Tweak thresholds if needed             │   │
│  │  5. Log: Record for entropy tracking                │   │
│  └─────────────────────────────────────────────────────┘   │
│                         ↓                                   │
│  Agent improved for next run                               │
│                         ↓                                   │
│  Entropy decreases over time ✅                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Anti-Pattern: External Gamma-Loop

❌ **Wrong:** Making gamma-loop a verb users must invoke.

❌ **Wrong:** Separate command for "improvement mode."

✅ **Right:** Gamma-loop runs automatically inside each agent.

---

## Key Insight

> The gamma-loop is why the agent improves. Without logging, we can't measure if it's working.

**Entropy measurement requires:**

1. Log every workflow run
2. Calculate entropy per run
3. Track entropy over time
4. Adjust based on real data

The gamma-loop without logging is like a thermostat without a temperature sensor.
