# Gamma-Loop Protocol

**Self-correcting automation for silos.**

---

## The Gap

> We built `tidy-first-agent` first to discover what a gamma-loop requires.

The philosophical briefs explain *why* gamma-loops exist. This playbook defines *how* to implement one.

---

## Definition

> **Gamma-Loop:** An internal feedback mechanism that maintains protocol tone by detecting drift and triggering corrections without human intervention.

### In Biological Terms

```
Alpha (Command) → Execute task
    ↓
Gamma (Monitor) → Check constraints
    ↓
Adjust ← If drift detected
```

### In Silo Terms

```
Agent does work
    ↓
Gamma-loop checks: constraints, thresholds, staleness
    ↓
If drift: archive, flag, prune, report
```

---

## What Gamma-Loop Monitors

| Aspect | What It Checks | Action |
|--------|----------------|--------|
| **Entropy** | File count, complexity | Archive oldest |
| **Staleness** | Age of issues/briefs | Flag for review |
| **Orphaned** | Untracked files, empty dirs | Clean up |
| **Compliance** | Missing docs, broken links | Report |
| **Health** | Error rates, failure patterns | Alert |

---

## tidy-first-agent: The Prototype

`tidy-first-agent` is our first gamma-loop implementation.

### What It Monitors

```bash
just agents tidy check
```

| Resource | Threshold | Action |
|----------|-----------|--------|
| Briefs | > 30 files | Archive oldest |
| Debriefs | > 20 files | Archive oldest |
| td issues | stale > 14 days | Flag |
| Git branches | merged, not pruned | Prune |

### Architecture

```
tidy-first-agent/
├── justfile          # Commands: check, status, run
├── src/              # Implementation
│   └── tidy-first-agent.ts
├── CSP.md            # Constraint specification
└── schedules/       # Cron configs
```

### Key Insight

> We didn't know what gamma-loop needed until we built `tidy-first-agent`.

Building first → discovering requirements → formalizing protocol.

---

## Gamma-Loop Protocol

### 1. Observe

```bash
# Check current state
gamma-check
```

Collect metrics:
- File counts
- Age distributions
- Error patterns
- Threshold violations

### 2. Evaluate

```bash
# Compare to constraints
gamma-evaluate
```

| Condition | Severity | Action |
|-----------|----------|--------|
| Within thresholds | OK | Log, done |
| Approaching threshold | Warning | Flag |
| Exceeded threshold | Alert | Archive/clean |
| Unknown state | Error | Report |

### 3. Act

```bash
# Apply corrections
gamma-act
```

Actions (in order of preference):
1. **Archive** — Move to archive, don't delete
2. **Flag** — Mark for human review
3. **Prune** — Remove safe orphans
4. **Report** — Escalate if unresolved

### 4. Report

```bash
# Summarize actions
gamma-report
```

Report includes:
- What changed
- What needs attention
- What requires human input

---

## Protocol Commands

```bash
# Full gamma-loop cycle
gamma: gamma-check && gamma-evaluate && gamma-act && gamma-report

# Individual steps
gamma-check      # Observe
gamma-evaluate   # Compare to constraints
gamma-act        # Apply corrections
gamma-report     # Summarize
```

---

## Integration with Agents

### tidy-first-agent as Gamma-Loop

```bash
# Cron: run gamma-loop daily
0 8 * * * just agents tidy run

# Cron: full gamma-loop weekly
0 9 * * 1 just agents tidy run-full
```

### Adding a New Gamma-Loop

1. **Define constraints** in `CSP.md`
2. **Implement checks** in `src/`
3. **Add commands** to `justfile`
4. **Register** in `manifest.json`

```bash
agents/
├── tidy-first-agent/     # Gamma-loop for workspace
└── my-gamma-agent/      # Your new gamma-loop
    ├── justfile
    ├── manifest.json    # commands: ["check", "run"]
    └── CSP.md           # Constraints
```

---

## Constraint Specification (CSP.md)

Each gamma-loop should have a `CSP.md` defining:

```markdown
# Constraints

| Resource | Threshold | Action |
|----------|-----------|--------|
| briefs/ | > 30 | archive oldest |
| debriefs/ | > 20 | archive oldest |
| td issues | stale > 14d | flag |

# Protocols

- Never delete, only archive
- Preserve git history
- Log all actions
```

---

## Anti-Patterns

| Anti-Pattern | Problem | Solution |
|--------------|---------|----------|
| **Delete on sight** | Data loss | Archive instead |
| **No logging** | Untraceable | Log every action |
| **No thresholds** | Infinite growth | Define constraints |
| **No human flag** | Automation surprises | Flag edge cases |

---

## Design Principles

1. **Archive, don't delete** — Reversibility
2. **Log everything** — Audit trail
3. **Threshold-based** — Predictable behavior
4. **Flag edge cases** — Human judgment for ambiguity
5. **Idempotent** — Safe to run multiple times

---

## Related

- `brief-gamma-loop-01.md` — Why gamma-loop (philosophy)
- `brief-gamma-loop-02.md` — Alpha-Gamma decoupling
- `silo-gamma-loop-03.md` — Baby→Adult maturation
- `agents/tidy-first-agent/` — First gamma-loop implementation
- `playbooks/agents-playbook.md` — Agent patterns

---

## Status

- [x] Define protocol (this doc)
- [x] Prototype: tidy-first-agent
- [ ] Implement: gamma-* commands
- [ ] Integrate: tidy-first-agent as gamma-loop
- [ ] Extend: Add more gamma-loops

---

## Lesson Learned

> We built `tidy-first-agent` to discover what gamma-loop requires.

Building first → discovering requirements → formalizing protocol.

This is the **Reveal** pattern applied to protocols. Don't pre-define. Let the implementation reveal the requirements.

---

## Specifying a Gamma-Loop

Each gamma-loop is defined in `CSP.md`. Here's the template:

```markdown
# CSP: My Gamma-Loop

## Mission
Brief description of what this gamma-loop monitors.

---

## Thresholds

| Resource | Auto-Archive | Flag |
|----------|--------------|------|
| files | > N | > days |

---

## Auto-Actions (Safe)

| Action | Trigger | Safety |
|--------|---------|--------|
| Archive | Threshold | ✅ Reversible |
| Prune | Condition | ✅ Safe |

---

## Human-Actions (Unsafe)

| Action | Creates |
|--------|---------|
| Delete | Decision brief |
| Refactor | Refactor brief |

---

## Integration Points

- on flag → other-agent
- on archive → log td
- on error → report
```

### Example: Adding Code Quality Gamma-Loop

```bash
mkdir -p agents/code-quality-agent
```

```json
// manifest.json
{
  "name": "code-quality-agent",
  "type": "gamma-loop",
  "commands": ["check", "run"],
  "constraints": "CSP.md"
}
```

```markdown
# CSP: code-quality-agent

## Thresholds

| Resource | Auto-Fix | Flag |
|----------|----------|------|
| TODO | — | > 5 |
| Broken links | — | Any |
| Large files | > 1MB | — |
```

---

## Gamma-Loop Test Pattern

```bash
# 1. Create test data
for i in $(seq 1 10); do
  echo "test" > "test-$i.txt"
done

# 2. Run gamma-loop
just gamma

# 3. Verify action
ls test-*.txt  # Should be archived

# 4. Cleanup
rm -f archive/test-*.txt
```

---

## Current Implementation

| Agent | Type | Status |
|-------|------|--------|
| tidy-first-agent | gamma-loop | ✅ Working |

**Tested:** Threshold enforcement (archived 5 briefs when > 30).

---

## Adding More Gamma-Loops

1. Create `agents/<name>-agent/`
2. Add `CSP.md` with thresholds
3. Add `manifest.json` with `type: "gamma-loop"`
4. Add `justfile` with commands
5. Register in `agents/README.md`
